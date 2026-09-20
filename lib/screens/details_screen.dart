import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/city_model.dart';
import '../models/weather_details_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/consumed_provider.dart';
import '../services/weather_api_service.dart';
import '../utils/weather_codes.dart';
import '../widgets/weather_icon_widget.dart';
import '../widgets/stat_card.dart';
import '../widgets/daily_forecast_tile.dart';
import '../widgets/error_view.dart';

/// Tela de Detalhes climáticos completos de uma cidade (RF02, RF03, RF04, RF07, RF09, RF10).
/// Executa a requisição de previsão estendida com FutureBuilder e gerencia favoritos e consultadas.
class DetailsScreen extends StatefulWidget {
  final City city;

  const DetailsScreen({
    super.key,
    required this.city,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final WeatherApiService _apiService;
  late Future<WeatherDetails> _forecastFuture;

  @override
  void initState() {
    super.initState();
    _apiService = WeatherApiService();
    _loadForecast();
  }

  void _loadForecast() {
    setState(() {
      _forecastFuture = _apiService.getFullForecast(widget.city);
    });
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '--:--';
    try {
      final dateTime = DateTime.parse(raw);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return raw.split('T').last;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final city = widget.city;

    final favoritesProvider = context.watch<FavoritesProvider>();
    final consumedProvider = context.watch<ConsumedProvider>();

    final isFav = favoritesProvider.isFavorite(city);
    final isCons = consumedProvider.isConsumed(city);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          city.name,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Botão de Favoritar/Desfavoritar (RF04, RF10: Toque mínimo 48x48)
          Semantics(
            button: true,
            label: isFav
                ? 'Remover ${city.name} dos favoritos'
                : 'Adicionar ${city.name} aos favoritos',
            child: IconButton(
              icon: Icon(
                isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isFav ? Colors.amber : colorScheme.onSurface,
                size: 28,
              ),
              tooltip: isFav ? 'Desfavoritar' : 'Favoritar',
              onPressed: () => favoritesProvider.toggleFavorite(city),
            ),
          ),
        ],
      ),
      body: FutureBuilder<WeatherDetails>(
        future: _forecastFuture,
        builder: (context, snapshot) {
          // 1. Estado de carregamento (RF09)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Obtendo previsão para ${city.name}...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          // 2. Estado de erro com botão Tentar novamente (RF09)
          if (snapshot.hasError) {
            final errorMsg = snapshot.error is WeatherApiException
                ? (snapshot.error as WeatherApiException).message
                : 'Não foi possível carregar a previsão. Tente novamente.';

            return ErrorView(
              message: errorMsg,
              onRetry: _loadForecast,
            );
          }

          // 3. Sucesso: Renderização dos detalhes completos (RF03)
          final details = snapshot.data!;
          final current = details.current;
          final conditionInfo = WeatherCodeHelper.getInfo(current.weatherCode);

          // Pega nascer e pôr do sol da previsão de hoje, se disponível
          String sunrise = '--:--';
          String sunset = '--:--';
          if (details.daily.isNotEmpty) {
            sunrise = _formatTime(details.daily.first.sunrise);
            sunset = _formatTime(details.daily.first.sunset);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card de Destaque Principal: Cidade, Ícone Grande, Temperatura e Sensação
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              city.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (city.isOrigin) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Sua Cidade',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          city.country,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Ícone Grande e Temperatura Atual
                        WeatherIconWidget(
                          weatherCode: current.weatherCode,
                          size: 96,
                          customSemanticLabel:
                              'Condição climática atual: ${conditionInfo.description}',
                        ),
                        const SizedBox(height: 4),

                        Text(
                          '${current.temperature.round()}°C',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          conditionInfo.description,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          'Sensação térmica: ${current.apparentTemperature.round()}°C',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Seção "Consultada" (RF07)
                Card(
                  child: SwitchListTile(
                    title: const Text(
                      'Marcar como Consultada',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      isCons
                          ? 'Esta cidade está salva na sua lista de consultadas'
                          : 'Salve esta cidade para consulta rápida depois',
                    ),
                    secondary: Icon(
                      isCons ? Icons.check_circle : Icons.check_circle_outline,
                      color: isCons ? colorScheme.primary : colorScheme.outline,
                      size: 28,
                    ),
                    value: isCons,
                    onChanged: (val) => consumedProvider.setConsumed(city, val),
                  ),
                ),

                const SizedBox(height: 16),

                // Seção de Métricas Climáticas (RF03)
                Text(
                  'Condições Atuais',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.6,
                  children: [
                    StatCard(
                      icon: Icons.water_drop_outlined,
                      label: 'Umidade',
                      value: '${current.relativeHumidity}%',
                    ),
                    StatCard(
                      icon: Icons.air,
                      label: 'Vento',
                      value: '${current.windSpeed.round()} km/h',
                    ),
                    StatCard(
                      icon: Icons.compress,
                      label: 'Pressão',
                      value: '${current.surfacePressure.round()} hPa',
                    ),
                    StatCard(
                      icon: Icons.wb_sunny_outlined,
                      label: 'Índice UV Máx.',
                      value: details.daily.isNotEmpty
                          ? details.daily.first.uvIndexMax.toStringAsFixed(1)
                          : '--',
                    ),
                    StatCard(
                      icon: Icons.wb_twilight_rounded,
                      label: 'Nascer do Sol',
                      value: sunrise,
                    ),
                    StatCard(
                      icon: Icons.nightlight_round,
                      label: 'Pôr do Sol',
                      value: sunset,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Seção Previsão para os Próximos 7 Dias (RF03)
                Text(
                  'Próximos 7 Dias',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: details.daily.length,
                  itemBuilder: (context, index) {
                    final dayForecast = details.daily[index];
                    return DailyForecastTile(
                      forecast: dayForecast,
                      isFirst: index == 0,
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
