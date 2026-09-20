/// Modelo que representa uma cidade com sua localização geográfica
/// e indicador se é a cidade de origem do usuário logado.
class City {
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final bool isOrigin;

  const City({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.isOrigin = false,
  });

  City copyWith({
    String? name,
    String? country,
    double? latitude,
    double? longitude,
    bool? isOrigin,
  }) {
    return City(
      name: name ?? this.name,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOrigin: isOrigin ?? this.isOrigin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'isOrigin': isOrigin,
    };
  }

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isOrigin: json['isOrigin'] as bool? ?? false,
    );
  }

  factory City.fromGeocodingJson(Map<String, dynamic> json, {bool isOrigin = false}) {
    final country = json['country'] as String? ?? (json['country_code'] as String? ?? '');
    return City(
      name: json['name'] as String? ?? '',
      country: country,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isOrigin: isOrigin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is City &&
        other.name.trim().toLowerCase() == name.trim().toLowerCase() &&
        other.country.trim().toLowerCase() == country.trim().toLowerCase();
  }

  @override
  int get hashCode => name.trim().toLowerCase().hashCode ^ country.trim().toLowerCase().hashCode;

  @override
  String toString() => '$name ($country)';
}
