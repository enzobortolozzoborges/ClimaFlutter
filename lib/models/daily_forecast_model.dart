// retornada pela API Open-Meteo.
class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double tempMax;
  final double tempMin;
  final double precipitationSum;
  final double uvIndexMax;
  final String sunrise;
  final String sunset;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationSum,
    required this.uvIndexMax,
    required this.sunrise,
    required this.sunset,
  });

  factory DailyForecast.fromDailyMap(Map<String, dynamic> daily, int index) {
    final times = daily['time'] as List<dynamic>? ?? [];
    final weatherCodes = daily['weather_code'] as List<dynamic>? ?? [];
    final maxTemps = daily['temperature_2m_max'] as List<dynamic>? ?? [];
    final minTemps = daily['temperature_2m_min'] as List<dynamic>? ?? [];
    final precipitations = daily['precipitation_sum'] as List<dynamic>? ?? [];
    final uvs = daily['uv_index_max'] as List<dynamic>? ?? [];
    final sunrises = daily['sunrise'] as List<dynamic>? ?? [];
    final sunsets = daily['sunset'] as List<dynamic>? ?? [];

    DateTime parsedDate = DateTime.now();
    if (index < times.length) {
      final parsed = DateTime.tryParse(times[index].toString());
      if (parsed != null) {
        parsedDate = parsed;
      }
    }

    return DailyForecast(
      date: parsedDate,
      weatherCode: index < weatherCodes.length
          ? (weatherCodes[index] as num).toInt()
          : 0,
      tempMax: index < maxTemps.length
          ? (maxTemps[index] as num).toDouble()
          : 0.0,
      tempMin: index < minTemps.length
          ? (minTemps[index] as num).toDouble()
          : 0.0,
      precipitationSum: index < precipitations.length
          ? (precipitations[index] as num).toDouble()
          : 0.0,
      uvIndexMax:
          index < uvs.length ? (uvs[index] as num).toDouble() : 0.0,
      sunrise: index < sunrises.length ? sunrises[index].toString() : '',
      sunset: index < sunsets.length ? sunsets[index].toString() : '',
    );
  }
}
