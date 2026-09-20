import 'package:flutter/material.dart';
import '../models/city_model.dart';
import '../services/storage_service.dart';

/// Provider global que gerencia o estado das cidades favoritas (RF04, RF05, RF06).
/// Persiste e recupera os dados de forma isolada por usuário logado.
class FavoritesProvider extends ChangeNotifier {
  final StorageService _storageService;
  String? _currentUserEmail;
  List<City> _favorites = [];

  FavoritesProvider(this._storageService, [this._currentUserEmail]) {
    if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
      _loadFavorites();
    }
  }

  List<City> get favorites => List.unmodifiable(_favorites);
  int get count => _favorites.length;

  /// Atualiza o usuário ativo e recarrega os favoritos correspondentes.
  void updateCurrentUser(String? email) {
    if (_currentUserEmail != email) {
      _currentUserEmail = email;
      if (email != null && email.isNotEmpty) {
        _loadFavorites();
      } else {
        _favorites = [];
        notifyListeners();
      }
    }
  }

  void _loadFavorites() {
    if (_currentUserEmail == null || _currentUserEmail!.isEmpty) return;
    _favorites = _storageService.getFavorites(_currentUserEmail!);
    notifyListeners();
  }

  /// Verifica se uma cidade já está nos favoritos.
  bool isFavorite(City city) {
    return _favorites.any(
      (c) =>
          c.name.trim().toLowerCase() == city.name.trim().toLowerCase() &&
          c.country.trim().toLowerCase() == city.country.trim().toLowerCase(),
    );
  }

  /// Alterna o status de favorito da cidade informada.
  Future<void> toggleFavorite(City city) async {
    if (isFavorite(city)) {
      await removeFavorite(city);
    } else {
      await addFavorite(city);
    }
  }

  /// Adiciona uma cidade à lista de favoritos e persiste no armazenamento local.
  Future<void> addFavorite(City city) async {
    if (!isFavorite(city)) {
      _favorites.add(city);
      notifyListeners();
      if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
        await _storageService.saveFavorites(_currentUserEmail!, _favorites);
      }
    }
  }

  /// Remove uma cidade da lista de favoritos e atualiza o armazenamento local.
  Future<void> removeFavorite(City city) async {
    _favorites.removeWhere(
      (c) =>
          c.name.trim().toLowerCase() == city.name.trim().toLowerCase() &&
          c.country.trim().toLowerCase() == city.country.trim().toLowerCase(),
    );
    notifyListeners();
    if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
      await _storageService.saveFavorites(_currentUserEmail!, _favorites);
    }
  }
}
