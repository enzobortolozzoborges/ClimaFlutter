import 'package:flutter/material.dart';

/// Informações visuais e textuais para um código de clima WMO.
class WeatherConditionInfo {
  final String iconCode;
  final String description;
  final IconData fallbackIcon;

  const WeatherConditionInfo({
    required this.iconCode,
    required this.description,
    required this.fallbackIcon,
  });

  /// Retorna a URL oficial do ícone OpenWeatherMap
  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}

/// Utilitário para mapear códigos WMO (World Meteorological Organization)
/// da API Open-Meteo para ícones do OpenWeatherMap e descrições em português.
class WeatherCodeHelper {
  static const Map<int, WeatherConditionInfo> _wmoMap = {
    0: WeatherConditionInfo(
      iconCode: '01d',
      description: 'Céu limpo',
      fallbackIcon: Icons.wb_sunny,
    ),
    1: WeatherConditionInfo(
      iconCode: '01d',
      description: 'Predominantemente limpo',
      fallbackIcon: Icons.wb_sunny_outlined,
    ),
    2: WeatherConditionInfo(
      iconCode: '02d',
      description: 'Parcialmente nublado',
      fallbackIcon: Icons.cloud_queue,
    ),
    3: WeatherConditionInfo(
      iconCode: '03d',
      description: 'Nublado',
      fallbackIcon: Icons.cloud,
    ),
    45: WeatherConditionInfo(
      iconCode: '50d',
      description: 'Nevoeiro',
      fallbackIcon: Icons.blur_on,
    ),
    48: WeatherConditionInfo(
      iconCode: '50d',
      description: 'Nevoeiro com geada',
      fallbackIcon: Icons.ac_unit,
    ),
    51: WeatherConditionInfo(
      iconCode: '09d',
      description: 'Garoa leve',
      fallbackIcon: Icons.grain,
    ),
    53: WeatherConditionInfo(
      iconCode: '09d',
      description: 'Garoa moderada',
      fallbackIcon: Icons.grain,
    ),
    55: WeatherConditionInfo(
      iconCode: '09d',
      description: 'Garoa densa',
      fallbackIcon: Icons.grain,
    ),
    56: WeatherConditionInfo(
      iconCode: '09d',
      description: 'Garoa congelante leve',
      fallbackIcon: Icons.ac_unit,
    ),
    57: WeatherConditionInfo(
      iconCode: '09d',
      description: 'Garoa congelante densa',
      fallbackIcon: Icons.ac_unit,
    ),
    61: WeatherConditionInfo(
      iconCode: '10d',
      description: 'Chuva leve',
      fallbackIcon: Icons.water_drop,
    ),
    63: WeatherConditionInfo(
      iconCode: '10d',
      description: 'Chuva moderada',
      fallbackIcon: Icons.water_drop_outlined,
    ),
    65: WeatherConditionInfo(
      iconCode: '10d',
      description: 'Chuva forte',
      fallbackIcon: Icons.thunderstorm,
    ),
    66: WeatherConditionInfo(
      iconCode: '13d',
      description: 'Chuva congelante leve',
      fallbackIcon: Icons.ac_unit,
    ),
    67: WeatherConditionInfo(
      iconCode: '13d',
      description: 'Chuva congelante forte',
      fallbackIcon: Icons.ac_unit,
    ),
    71: WeatherConditionInfo(
      iconCode: '13d',
      description: 'Neve leve',
      fallbackIcon: Icons.snowing,
    ),
    73: WeatherConditionInfo(
      iconCode: '13d',
      description: 'Neve moderada',
      fallbackIcon: Icons.snowing,
    ),
    75: WeatherConditionInfo(
      iconCode: '13d',
      description: 'Neve forte',
      fallbackIcon: Icons.ac_unit,
    ),
    77: WeatherConditionInfo(
      iconCode: '13d',
      description: 'Grãos de neve',
      fallbackIcon: Icons.ac_unit,
    ),
    80: WeatherConditionInfo(
      iconCode: '09d',
      description: 'Pancadas de chuva leves',
      fallbackIcon: Icons.shower,
    ),
    81: WeatherConditionInfo(
      iconCode: '09d',
      description: 'Pancadas de chuva moderadas',
      fallbackIcon: Icons.shower,
    ),
    82: WeatherConditionInfo(
      iconCode: '09d',
      description: 'Pancadas de chuva violentas',
      fallbackIcon: Icons.thunderstorm,
    ),
    85: WeatherConditionInfo(
      iconCode: '13d',
      description: 'Pancadas de neve leves',
      fallbackIcon: Icons.snowing,
    ),
    86: WeatherConditionInfo(
      iconCode: '13d',
      description: 'Pancadas de neve fortes',
      fallbackIcon: Icons.ac_unit,
    ),
    95: WeatherConditionInfo(
      iconCode: '11d',
      description: 'Tempestade',
      fallbackIcon: Icons.flash_on,
    ),
    96: WeatherConditionInfo(
      iconCode: '11d',
      description: 'Tempestade com granizo leve',
      fallbackIcon: Icons.flash_on,
    ),
    99: WeatherConditionInfo(
      iconCode: '11d',
      description: 'Tempestade com granizo forte',
      fallbackIcon: Icons.flash_on,
    ),
  };

  /// Retorna as informações mapeadas para o código WMO fornecido.
  /// Se o código for nulo ou desconhecido, retorna um padrão amigável.
  static WeatherConditionInfo getInfo(int? code) {
    if (code == null) {
      return const WeatherConditionInfo(
        iconCode: '02d',
        description: 'Tempo estável',
        fallbackIcon: Icons.cloud_outlined,
      );
    }
    return _wmoMap[code] ??
        const WeatherConditionInfo(
          iconCode: '02d',
          description: 'Tempo variável',
          fallbackIcon: Icons.cloud_outlined,
        );
  }
}
