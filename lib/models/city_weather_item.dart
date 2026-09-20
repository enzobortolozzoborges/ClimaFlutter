import 'city_model.dart';
import 'weather_model.dart';


// armazenando a cidade, clima atual, e status de carregamento/erro individual.
class CityWeatherItem {
  final City city;
  final CurrentWeather? weather;
  final bool isLoading;
  final String? error;

  const CityWeatherItem({
    required this.city,
    this.weather,
    this.isLoading = false,
    this.error,
  });

  CityWeatherItem copyWith({
    City? city,
    CurrentWeather? weather,
    bool? isLoading,
    String? error,
  }) {
    return CityWeatherItem(
      city: city ?? this.city,
      weather: weather ?? this.weather,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
