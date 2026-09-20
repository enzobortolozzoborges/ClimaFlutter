import 'package:flutter_test/flutter_test.dart';
import 'package:clima_flutter/models/city_model.dart';
import 'package:clima_flutter/models/user_model.dart';
import 'package:clima_flutter/models/weather_model.dart';
import 'package:clima_flutter/models/daily_forecast_model.dart';
import 'package:clima_flutter/services/storage_service.dart';
import 'package:clima_flutter/utils/weather_codes.dart';
import 'package:clima_flutter/utils/default_cities.dart';

void main() {
  group('Modelos e Utilitários - Testes Unitários', () {
    test('City model serialization e equality', () {
      const city1 = City(
        name: 'Curitiba',
        country: 'Brasil',
        latitude: -25.4278,
        longitude: -49.2731,
        isOrigin: true,
      );

      final json = city1.toJson();
      final city2 = City.fromJson(json);

      expect(city1, equals(city2));
      expect(city2.isOrigin, isTrue);
      expect(city2.name, 'Curitiba');
      expect(city2.country, 'Brasil');
    });

    test('User model e hash de senha', () {
      final hash1 = StorageService.hashPassword('senha123');
      final hash2 = StorageService.hashPassword('senha123');
      final hash3 = StorageService.hashPassword('outrasenha');

      expect(hash1, equals(hash2));
      expect(hash1, isNot(equals(hash3)));

      final user = User(
        name: 'Enzo',
        email: 'enzo@teste.com',
        passwordHash: hash1,
        originCity: 'Curitiba',
      );

      final json = user.toJson();
      final restored = User.fromJson(json);

      expect(restored.name, 'Enzo');
      expect(restored.email, 'enzo@teste.com');
      expect(restored.originCity, 'Curitiba');
    });

    test('CurrentWeather model parsing', () {
      final mockData = {
        'temperature_2m': 22.5,
        'apparent_temperature': 23.0,
        'relative_humidity_2m': 65,
        'weather_code': 1,
        'wind_speed_10m': 14.2,
        'surface_pressure': 1012.0,
        'time': '2026-09-20T15:00',
      };

      final current = CurrentWeather.fromJson(mockData);
      expect(current.temperature, 22.5);
      expect(current.apparentTemperature, 23.0);
      expect(current.relativeHumidity, 65);
      expect(current.weatherCode, 1);
      expect(current.windSpeed, 14.2);
    });

    test('DailyForecast model parsing', () {
      final mockDaily = {
        'time': ['2026-09-20'],
        'weather_code': [0],
        'temperature_2m_max': [26.0],
        'temperature_2m_min': [14.0],
        'precipitation_sum': [0.0],
        'uv_index_max': [6.0],
        'sunrise': ['2026-09-20T06:00'],
        'sunset': ['2026-09-20T18:00'],
      };

      final daily = DailyForecast.fromDailyMap(mockDaily, 0);
      expect(daily.tempMax, 26.0);
      expect(daily.tempMin, 14.0);
      expect(daily.weatherCode, 0);
      expect(daily.precipitationSum, 0.0);
    });

    test('WeatherCodeHelper mapeia códigos WMO e URLs do OpenWeatherMap', () {
      final clearSky = WeatherCodeHelper.getInfo(0);
      expect(clearSky.iconCode, '01d');
      expect(clearSky.description, 'Céu limpo');
      expect(clearSky.iconUrl, 'https://openweathermap.org/img/wn/01d@2x.png');

      final rain = WeatherCodeHelper.getInfo(61);
      expect(rain.iconCode, '10d');
      expect(rain.description, 'Chuva leve');
      expect(rain.iconUrl, 'https://openweathermap.org/img/wn/10d@2x.png');

      final unknown = WeatherCodeHelper.getInfo(9999);
      expect(unknown.description, isNotEmpty);
      expect(unknown.iconUrl, isNotEmpty);
    });

    test('DefaultCities contém 40 cidades', () {
      expect(DefaultCities.list.length, equals(40));
    });
  });
}
