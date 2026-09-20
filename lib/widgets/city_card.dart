import 'package:flutter/material.dart';
import '../models/city_weather_item.dart';
import '../utils/weather_codes.dart';
import 'weather_icon_widget.dart';

/// Card de cidade exibido no GridView do catálogo principal (RF01, RF10).
/// Resiliente ao aumento de escala de fontes do sistema e acessível para leitores de tela.
class CityCard extends StatelessWidget {
  final CityWeatherItem item;
  final VoidCallback onTap;

  const CityCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final city = item.city;
    final weather = item.weather;
    final condition = weather != null
        ? WeatherCodeHelper.getInfo(weather.weatherCode).description
        : 'Indisponível';

    final tempString = weather != null
        ? '${weather.temperature.round()}°C'
        : '--';

    final accessibilityLabel = 'Cidade: ${city.name}, ${city.country}. '
        'Temperatura: ${weather != null ? "${weather.temperature.round()} graus Celsius" : "não informada"}. '
        'Condição: $condition.'
        '${city.isOrigin ? " Sua cidade de origem." : ""} Toque para ver detalhes.';

    return Semantics(
      button: true,
      label: accessibilityLabel,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minHeight: 140),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cabeçalho do Card: Origem + Nome + País
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (city.isOrigin)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Sua Origem',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Text(
                      city.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      city.country,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Rodapé do Card: Ícone e Temperatura
                if (item.isLoading)
                  const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (item.error != null)
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: colorScheme.error),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Indisponível',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      WeatherIconWidget(
                        weatherCode: weather?.weatherCode,
                        size: 44,
                      ),
                      Flexible(
                        child: Text(
                          tempString,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
