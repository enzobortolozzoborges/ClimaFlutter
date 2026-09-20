import 'package:flutter/material.dart';
import '../models/city_model.dart';
import '../models/city_weather_item.dart';
import '../services/weather_api_service.dart';
import '../utils/default_cities.dart';

/// Provider responsável pelo catálogo paginado de cidades (RF01, RF09).
/// Gerencia a cidade de origem do usuário logado (sempre em 1º lugar),
/// paginação de 10 em 10 itens e carregamento concorrente com tolerância a falhas.
class CitiesProvider extends ChangeNotifier {
  final WeatherApiService _apiService;
  String? _originCityName;

  static const int pageSize = 10;

  List<City> _allCities = [];
  final List<CityWeatherItem> _items = [];

  int _currentPage = 0;
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  CitiesProvider(this._apiService, [this._originCityName]) {
    if (_originCityName != null && _originCityName!.isNotEmpty) {
      loadInitial();
    }
  }

  List<CityWeatherItem> get items => List.unmodifiable(_items);
  bool get isLoadingInitial => _isLoadingInitial;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => (_currentPage * pageSize) < _allCities.length;

  /// Atualiza a cidade de origem e recarrega o catálogo caso a cidade tenha mudado.
  void updateOriginCity(String? cityName) {
    if (_originCityName != cityName) {
      _originCityName = cityName;
      loadInitial();
    }
  }

  /// Inicializa o catálogo: resolve a cidade de origem via geocoding,
  /// monta a lista de ~40 cidades e carrega a primeira página (10 cidades).
  Future<void> loadInitial() async {
    _isLoadingInitial = true;
    _errorMessage = null;
    _items.clear();
    _currentPage = 0;
    notifyListeners();

    try {
      final List<City> combinedList = [];

      // 1. Resolve cidade de origem do usuário logado (RF01: sempre primeiro item)
      City? originCity;
      if (_originCityName != null && _originCityName!.trim().isNotEmpty) {
        try {
          originCity = await _apiService.searchCity(_originCityName!.trim());
        } catch (_) {
          // Em caso de falha de rede temporária na geocodificação,
          // cria entrada de fallback com coordenadas de referência
          originCity = City(
            name: _originCityName!.trim(),
            country: 'Brasil',
            latitude: -23.5505,
            longitude: -46.6333,
            isOrigin: true,
          );
        }
      }

      if (originCity != null) {
        combinedList.add(originCity.copyWith(isOrigin: true));
      }

      // 2. Adiciona as 40 cidades padrão (evitando duplicidade com a cidade de origem)
      for (final defaultCity in DefaultCities.list) {
        final isDuplicate = originCity != null &&
            defaultCity.name.trim().toLowerCase() ==
                originCity.name.trim().toLowerCase();
        if (!isDuplicate) {
          combinedList.add(defaultCity);
        }
      }

      _allCities = combinedList;

      // 3. Carrega a primeira página (primeiras 10 cidades)
      await _fetchPage(0);
      _currentPage = 1;
    } on WeatherNetworkException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Falha ao carregar catálogo climático. Tente novamente.';
    } finally {
      _isLoadingInitial = false;
      notifyListeners();
    }
  }

  /// Busca a próxima página de 10 cidades e adiciona à lista existente (RF01).
  Future<void> loadNextPage() async {
    if (_isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      await _fetchPage(_currentPage);
      _currentPage++;
    } catch (e) {
      // Falhas no "Carregar Mais" não quebram o catálogo já carregado
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Executa as requisições de clima atual concorrentes para uma página de cidades.
  Future<void> _fetchPage(int pageIndex) async {
    final startIndex = pageIndex * pageSize;
    final endIndex = (startIndex + pageSize) > _allCities.length
        ? _allCities.length
        : (startIndex + pageSize);

    if (startIndex >= _allCities.length) return;

    final targetCities = _allCities.sublist(startIndex, endIndex);

    // Consulta o clima atual de cada cidade em paralelo para agilidade
    final results = await Future.wait(
      targetCities.map((city) async {
        try {
          final weather = await _apiService.getCurrentWeather(
            city.latitude,
            city.longitude,
          );
          return CityWeatherItem(city: city, weather: weather);
        } catch (e) {
          // Erro individual em uma cidade não compromete a tela (RF01, RF09)
          return CityWeatherItem(
            city: city,
            error: 'Clima temporariamente indisponível',
          );
        }
      }),
    );

    _items.addAll(results);
  }

  /// Atualiza todo o catálogo (Pull-to-refresh).
  Future<void> refresh() async {
    await loadInitial();
  }
}
