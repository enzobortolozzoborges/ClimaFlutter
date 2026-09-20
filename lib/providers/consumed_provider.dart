import 'package:flutter/material.dart';
import '../models/city_model.dart';
import '../services/storage_service.dart';

/// Provider responsável pelo gerenciamento de cidades consultadas (RF06, RF07).
/// Persiste o status de leitura/consulta de forma isolada por usuário.
class ConsumedProvider extends ChangeNotifier {
  final StorageService _storageService;
  String? _currentUserEmail;
  List<City> _consumed = [];

  ConsumedProvider(this._storageService, [this._currentUserEmail]) {
    if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
      _loadConsumed();
    }
  }

  List<City> get consumed => List.unmodifiable(_consumed);
  int get count => _consumed.length;

  /// Atualiza o usuário ativo e recarrega a lista de cidades consultadas.
  void updateCurrentUser(String? email) {
    if (_currentUserEmail != email) {
      _currentUserEmail = email;
      if (email != null && email.isNotEmpty) {
        _loadConsumed();
      } else {
        _consumed = [];
        notifyListeners();
      }
    }
  }

  void _loadConsumed() {
    if (_currentUserEmail == null || _currentUserEmail!.isEmpty) return;
    _consumed = _storageService.getConsumed(_currentUserEmail!);
    notifyListeners();
  }

  /// Verifica se a cidade já foi marcada como consultada.
  bool isConsumed(City city) {
    return _consumed.any(
      (c) =>
          c.name.trim().toLowerCase() == city.name.trim().toLowerCase() &&
          c.country.trim().toLowerCase() == city.country.trim().toLowerCase(),
    );
  }

  /// Define o status de consultada da cidade informada.
  Future<void> setConsumed(City city, bool value) async {
    if (value) {
      if (!isConsumed(city)) {
        _consumed.add(city);
        notifyListeners();
        if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
          await _storageService.saveConsumed(_currentUserEmail!, _consumed);
        }
      }
    } else {
      await removeConsumed(city);
    }
  }

  /// Alterna o status de consultada da cidade.
  Future<void> toggleConsumed(City city) async {
    await setConsumed(city, !isConsumed(city));
  }

  /// Remove uma cidade da lista de consultadas.
  Future<void> removeConsumed(City city) async {
    _consumed.removeWhere(
      (c) =>
          c.name.trim().toLowerCase() == city.name.trim().toLowerCase() &&
          c.country.trim().toLowerCase() == city.country.trim().toLowerCase(),
    );
    notifyListeners();
    if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
      await _storageService.saveConsumed(_currentUserEmail!, _consumed);
    }
  }
}
