import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/city_model.dart';
import '../models/weather_model.dart';
import '../models/daily_forecast_model.dart';
import '../models/weather_details_model.dart';

/// Exceção genérica para erros na camada de serviço da API climática.
class WeatherApiException implements Exception {
  final String message;
  final int? statusCode;

  WeatherApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Exceção de rede (falha de conexão ou timeout).
class WeatherNetworkException extends WeatherApiException {
  WeatherNetworkException([super.message = 'Falha de conexão com a internet. Verifique sua rede e tente novamente.']);
}

/// Serviço responsável pela integração com os endpoints REST da Open-Meteo.
class WeatherApiService {
  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 12);

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Busca coordenadas e metadados de uma cidade pelo nome (endpoint de Geocoding).
  Future<City?> searchCity(String cityName) async {
    final query = cityName.trim();
    if (query.isEmpty) return null;

    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(query)}&count=1&language=pt&format=json',
    );

    try {
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw WeatherApiException(
          'Erro ao buscar cidade (Código ${response.statusCode})',
          response.statusCode,
        );
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final results = data['results'] as List<dynamic>?;

      if (results == null || results.isEmpty) {
        return null;
      }

      final firstResult = results[0] as Map<String, dynamic>;
      return City.fromGeocodingJson(firstResult);
    } on SocketException {
      throw WeatherNetworkException();
    } on TimeoutException {
      throw WeatherNetworkException('O tempo de conexão expirou. Tente novamente.');
    } on WeatherApiException {
      rethrow;
    } catch (e) {
      throw WeatherApiException('Erro inesperado ao consultar cidade: $e');
    }
  }

  /// Consulta apenas as condições climáticas atuais de uma coordenada.
  Future<CurrentWeather> getCurrentWeather(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m,surface_pressure',
    );

    try {
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw WeatherApiException(
          'Erro ao obter clima atual (Código ${response.statusCode})',
          response.statusCode,
        );
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final currentData = data['current'] as Map<String, dynamic>?;

      if (currentData == null) {
        throw WeatherApiException('Dados meteorológicos indisponíveis para esta localidade.');
      }

      return CurrentWeather.fromJson(currentData);
    } on SocketException {
      throw WeatherNetworkException();
    } on TimeoutException {
      throw WeatherNetworkException('O tempo de conexão expirou ao consultar previsão.');
    } on WeatherApiException {
      rethrow;
    } catch (e) {
      throw WeatherApiException('Erro inesperado ao obter dados do clima: $e');
    }
  }

  /// Consulta a previsão climática completa (condições atuais + previsão diária de 7 dias)
  /// para uma determinada cidade.
  Future<WeatherDetails> getFullForecast(City city) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=${city.latitude}&longitude=${city.longitude}'
      '&current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m,surface_pressure'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,uv_index_max,sunrise,sunset'
      '&timezone=auto',
    );

    try {
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw WeatherApiException(
          'Erro ao obter previsão detalhada (Código ${response.statusCode})',
          response.statusCode,
        );
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final currentData = data['current'] as Map<String, dynamic>?;
      final dailyData = data['daily'] as Map<String, dynamic>?;

      if (currentData == null || dailyData == null) {
        throw WeatherApiException('Previsão climática incompleta retornada pela API.');
      }

      final currentWeather = CurrentWeather.fromJson(currentData);

      final List<DailyForecast> dailyForecasts = [];
      final times = dailyData['time'] as List<dynamic>? ?? [];
      final count = times.length > 7 ? 7 : times.length;

      for (int i = 0; i < count; i++) {
        dailyForecasts.add(DailyForecast.fromDailyMap(dailyData, i));
      }

      return WeatherDetails(
        city: city,
        current: currentWeather,
        daily: dailyForecasts,
      );
    } on SocketException {
      throw WeatherNetworkException();
    } on TimeoutException {
      throw WeatherNetworkException('Tempo de requisição expirou. Verifique sua conexão.');
    } on WeatherApiException {
      rethrow;
    } catch (e) {
      throw WeatherApiException('Falha ao processar previsão detalhada: $e');
    }
  }
}
