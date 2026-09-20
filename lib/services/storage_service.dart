import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/city_model.dart';

/// Serviço de armazenamento local baseado em SharedPreferences.
/// Gerencia persistência de usuários, sessão ativa e dados isolados por usuário
/// (favoritos e cidades consultadas).
class StorageService {
  static const String _keyUsers = 'app_users';
  static const String _keyActiveSession = 'app_active_session_email';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  /// Cria e inicializa a instância do serviço com SharedPreferences.
  static Future<StorageService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // ==========================================
  // SEGURANÇA E HASH
  // ==========================================

  /// Gera o hash SHA-256 da senha informada.
  static String hashPassword(String password) {
    final bytes = utf8.encode(password.trim());
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ==========================================
  // GERENCIAMENTO DE USUÁRIOS
  // ==========================================

  /// Retorna a lista de todos os usuários cadastrados.
  List<User> _getAllUsers() {
    final rawJson = _prefs.getString(_keyUsers);
    if (rawJson == null || rawJson.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Salva ou atualiza a lista de usuários cadastrados.
  Future<void> _saveAllUsers(List<User> users) async {
    final rawJson = jsonEncode(users.map((u) => u.toJson()).toList());
    await _prefs.setString(_keyUsers, rawJson);
  }

  /// Busca um usuário pelo e-mail (case-insensitive).
  User? findUserByEmail(String email) {
    final normalized = email.trim().toLowerCase();
    final users = _getAllUsers();
    try {
      return users.firstWhere(
        (u) => u.email.trim().toLowerCase() == normalized,
      );
    } catch (_) {
      return null;
    }
  }

  /// Registra um novo usuário no SharedPreferences.
  /// Lança Exception caso o e-mail já esteja em uso.
  Future<User> registerUser({
    required String name,
    required String email,
    required String password,
    required String originCity,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final existingUser = findUserByEmail(normalizedEmail);

    if (existingUser != null) {
      throw Exception('Já existe um usuário cadastrado com este e-mail.');
    }

    final newUser = User(
      name: name.trim(),
      email: normalizedEmail,
      passwordHash: hashPassword(password),
      originCity: originCity.trim(),
    );

    final users = _getAllUsers();
    users.add(newUser);
    await _saveAllUsers(users);

    return newUser;
  }

  /// Autentica o usuário pelo e-mail e senha.
  /// Retorna o [User] caso as credenciais estejam corretas, ou nulo.
  User? authenticateUser(String email, String password) {
    final user = findUserByEmail(email);
    if (user == null) return null;

    final computedHash = hashPassword(password);
    if (user.passwordHash == computedHash) {
      return user;
    }
    return null;
  }

  // ==========================================
  // SESSÃO ATIVA (RF07 baseline)
  // ==========================================

  /// Salva o e-mail do usuário atualmente conectado.
  Future<void> saveActiveSession(String email) async {
    await _prefs.setString(_keyActiveSession, email.trim().toLowerCase());
  }

  /// Retorna o e-mail do usuário com sessão ativa, se houver.
  String? getActiveSessionEmail() {
    return _prefs.getString(_keyActiveSession);
  }

  /// Encerra a sessão ativa (Logout).
  Future<void> clearActiveSession() async {
    await _prefs.remove(_keyActiveSession);
  }

  // ==========================================
  // DADOS ESPECÍFICOS POR USUÁRIO (RF06, RF07)
  // ==========================================

  String _favoritesKey(String userEmail) => 'favorites_${userEmail.trim().toLowerCase()}';
  String _consumedKey(String userEmail) => 'consumed_${userEmail.trim().toLowerCase()}';

  /// Carrega a lista de cidades favoritas para o usuário informado.
  List<City> getFavorites(String userEmail) {
    final rawJson = _prefs.getString(_favoritesKey(userEmail));
    if (rawJson == null || rawJson.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((item) => City.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Persiste a lista de cidades favoritas para o usuário informado.
  Future<void> saveFavorites(String userEmail, List<City> favorites) async {
    final rawJson = jsonEncode(favorites.map((c) => c.toJson()).toList());
    await _prefs.setString(_favoritesKey(userEmail), rawJson);
  }

  /// Carrega a lista de cidades consultadas para o usuário informado.
  List<City> getConsumed(String userEmail) {
    final rawJson = _prefs.getString(_consumedKey(userEmail));
    if (rawJson == null || rawJson.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((item) => City.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Persiste a lista de cidades consultadas para o usuário informado.
  Future<void> saveConsumed(String userEmail, List<City> consumed) async {
    final rawJson = jsonEncode(consumed.map((c) => c.toJson()).toList());
    await _prefs.setString(_consumedKey(userEmail), rawJson);
  }
}
