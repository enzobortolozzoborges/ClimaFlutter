// Modelo que representa os dados climáticos atuais retornados pela API Open-Meteo.
class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final int relativeHumidity;
  final int weatherCode;
  final double windSpeed;
  final double surfacePressure;
  final String time;

  const CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.weatherCode,
    required this.windSpeed,
    required this.surfacePressure,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final temp = (json['temperature_2m'] as num?)?.toDouble() ?? 0.0;
    return CurrentWeather(
      temperature: temp,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? temp,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      surfacePressure:
          (json['surface_pressure'] as num?)?.toDouble() ?? 1013.25,
      time: json['time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature_2m': temperature,
      'apparent_temperature': apparentTemperature,
      'relative_humidity_2m': relativeHumidity,
      'weather_code': weatherCode,
      'wind_speed_10m': windSpeed,
      'surface_pressure': surfacePressure,
      'time': time,
    };
  }
}
