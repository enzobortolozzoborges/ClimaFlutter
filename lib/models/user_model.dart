// Modelo que representa o usuário cadastrado no aplicativo.
class User {
  final String name;
  final String email;
  final String passwordHash;
  final String originCity;

  const User({
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.originCity,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'originCity': originCity,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      passwordHash: json['passwordHash'] as String? ?? '',
      originCity: json['originCity'] as String? ?? '',
    );
  }

  User copyWith({
    String? name,
    String? email,
    String? passwordHash,
    String? originCity,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      originCity: originCity ?? this.originCity,
    );
  }
}
