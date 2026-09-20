import 'package:flutter/material.dart';
import '../models/daily_forecast_model.dart';
import '../utils/weather_codes.dart';
import 'weather_icon_widget.dart';

/// Item de previsão diária exibido na lista de 7 dias da Tela de Detalhes (RF03, RF10).
class DailyForecastTile extends StatelessWidget {
  final DailyForecast forecast;
  final bool isFirst;

  const DailyForecastTile({
    super.key,
    required this.forecast,
    this.isFirst = false,
  });

  String _formatDayLabel(DateTime date, bool isFirst) {
    if (isFirst) return 'Hoje';

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Amanhã';
    }

    switch (date.weekday) {
      case DateTime.monday:
        return 'Segunda';
      case DateTime.tuesday:
        return 'Terça';
      case DateTime.wednesday:
        return 'Quarta';
      case DateTime.thursday:
        return 'Quinta';
      case DateTime.friday:
        return 'Sexta';
      case DateTime.saturday:
        return 'Sábado';
      case DateTime.sunday:
      default:
        return 'Domingo';
    }
  }

  String _formatDateString(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final info = WeatherCodeHelper.getInfo(forecast.weatherCode);

    final dayTitle = _formatDayLabel(forecast.date, isFirst);
    final dateSubtitle = _formatDateString(forecast.date);

    final semanticText = 'Previsão para $dayTitle, $dateSubtitle: '
        '${info.description}. '
        'Máxima de ${forecast.tempMax.round()} graus, mínima de ${forecast.tempMin.round()} graus. '
        'Precipitação de ${forecast.precipitationSum.toStringAsFixed(1)} milímetros.';

    return Semantics(
      label: semanticText,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Dia e data
              SizedBox(
                width: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      dateSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Ícone e condição
              WeatherIconWidget(
                weatherCode: forecast.weatherCode,
                size: 38,
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (forecast.precipitationSum > 0)
                      Text(
                        '💧 ${forecast.precipitationSum.toStringAsFixed(1)} mm',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Temperaturas Máx e Mín
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${forecast.tempMax.round()}°',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${forecast.tempMin.round()}°',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
