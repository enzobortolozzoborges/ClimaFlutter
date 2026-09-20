import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'details_screen.dart';

/// Tela que lista as cidades favoritas do usuário logado (RF04, RF05, RF06, RF10).
/// Atualiza automaticamente e permite desfavoritar diretamente da lista.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final favorites = favoritesProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cidades Favoritas'),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_outline_rounded,
                      size: 72,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma cidade favorita ainda',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adicione cidades tocando na estrela na Tela de Detalhes de qualquer cidade.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final city = favorites[index];

                return Semantics(
                  button: true,
                  label: '${city.name}, ${city.country}. Toque para ver a previsão detalhada.',
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.location_city,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              city.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (city.isOrigin) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Origem',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(city.country),
                      trailing: Semantics(
                        button: true,
                        label: 'Remover ${city.name} dos favoritos',
                        child: IconButton(
                          icon: const Icon(Icons.star_rounded, color: Colors.amber),
                          tooltip: 'Remover dos favoritos',
                          onPressed: () {
                            favoritesProvider.removeFavorite(city);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${city.name} removida dos favoritos.'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailsScreen(city: city),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
