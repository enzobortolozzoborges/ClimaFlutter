import 'city_model.dart';
import 'weather_model.dart';
import 'daily_forecast_model.dart';

// Modelo que encapsula os detalhes completos do clima de uma cidade,.
class WeatherDetails {
  final City city;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  const WeatherDetails({
    required this.city,
    required this.current,
    required this.daily,
  });
}
