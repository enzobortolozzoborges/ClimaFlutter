import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/consumed_provider.dart';
import 'details_screen.dart';

/// Tela própria para listar as Cidades Consultadas pelo usuário logado (RF06, RF07, RF10).
/// Permite desmarcar/remover cidades diretamente e abrir detalhes.
class ConsumedScreen extends StatelessWidget {
  const ConsumedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final consumedProvider = context.watch<ConsumedProvider>();
    final consumedList = consumedProvider.consumed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cidades Consultadas'),
      ),
      body: consumedList.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 72,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma cidade consultada ainda',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ao abrir os detalhes de uma cidade, marque a opção "Marcar como Consultada" para salvá-la aqui.',
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
              itemCount: consumedList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final city = consumedList[index];

                return Semantics(
                  button: true,
                  label: '${city.name}, ${city.country}. Cidade marcada como consultada. Toque para ver detalhes.',
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.secondaryContainer,
                        child: Icon(
                          Icons.check_circle_outline,
                          color: colorScheme.onSecondaryContainer,
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
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Origem',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onPrimaryContainer,
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
                        label: 'Remover ${city.name} da lista de consultadas',
                        child: IconButton(
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: colorScheme.error,
                          ),
                          tooltip: 'Remover de consultadas',
                          onPressed: () {
                            consumedProvider.removeConsumed(city);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${city.name} desmarcada como consultada.'),
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
