import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

/// Provider responsável pelo gerenciamento de estado de autenticação,
/// cadastro, login, logout e persistência de sessão ativa.
class AuthProvider extends ChangeNotifier {
  final StorageService _storageService;

  User? _currentUser;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._storageService) {
    checkActiveSession();
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Limpa qualquer mensagem de erro pendente.
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Verifica se há uma sessão persistida no SharedPreferences ao abrir o app.
  Future<void> checkActiveSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedEmail = _storageService.getActiveSessionEmail();
      if (savedEmail != null && savedEmail.isNotEmpty) {
        _currentUser = _storageService.findUserByEmail(savedEmail);
      }
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Realiza o login do usuário com e-mail e senha.
  Future<bool> login(String email, String password) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      _errorMessage = 'Por favor, preencha todos os campos.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Pequeno delay para feedback visual suave (RF09)
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final user = _storageService.authenticateUser(cleanEmail, cleanPassword);
      if (user != null) {
        _currentUser = user;
        await _storageService.saveActiveSession(user.email);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'E-mail ou senha incorretos. Verifique suas credenciais.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro ao realizar login. Tente novamente.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Realiza o cadastro de um novo usuário.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String originCity,
  }) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty ||
        originCity.trim().isEmpty) {
      _errorMessage = 'Preencha todos os campos obrigatórios.';
      notifyListeners();
      return false;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _errorMessage = 'Por favor, informe um endereço de e-mail válido.';
      notifyListeners();
      return false;
    }

    if (password.trim().length < 6) {
      _errorMessage = 'A senha deve conter no mínimo 6 caracteres.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Pequeno delay para feedback visual (RF09)
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final user = await _storageService.registerUser(
        name: name,
        email: email,
        password: password,
        originCity: originCity,
      );

      _currentUser = user;
      await _storageService.saveActiveSession(user.email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Encerra a sessão do usuário atual.
  Future<void> logout() async {
    await _storageService.clearActiveSession();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
