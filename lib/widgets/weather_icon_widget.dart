import 'package:flutter/material.dart';
import '../utils/weather_codes.dart';

/// Widget de ícone do clima que consome as imagens oficiais do OpenWeatherMap
/// com fallback seguro (errorBuilder e loadingBuilder) e suporte à acessibilidade (RF01, RF10).
class WeatherIconWidget extends StatelessWidget {
  final int? weatherCode;
  final double size;
  final String? customSemanticLabel;

  const WeatherIconWidget({
    super.key,
    required this.weatherCode,
    this.size = 48,
    this.customSemanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final info = WeatherCodeHelper.getInfo(weatherCode);
    final label = customSemanticLabel ?? 'Condição climática: ${info.description}';
    final theme = Theme.of(context);

    return Semantics(
      label: label,
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          info.iconUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: size * 0.5,
                height: size * 0.5,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Placeholder resiliente que não quebra a interface (RF01, RF10)
            return Icon(
              info.fallbackIcon,
              size: size * 0.8,
              color: theme.colorScheme.primary,
            );
          },
        ),
      ),
    );
  }
}
