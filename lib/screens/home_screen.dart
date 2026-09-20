import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cities_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/consumed_provider.dart';
import '../services/weather_api_service.dart';
import '../widgets/city_card.dart';
import '../widgets/error_view.dart';
import 'details_screen.dart';
import 'favorites_screen.dart';
import 'consumed_screen.dart';

/// Tela Principal do aplicativo: Catálogo de previsões em grade (RF01, RF08, RF09, RF10).
/// Contém a barra de busca direta, a lista paginada e a navegação para as demais telas.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _weatherApiService = WeatherApiService();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Executa a busca de cidade pelo endpoint de Geocoding (RF08, RF09)
  /// e navega diretamente para a Tela de Detalhes da cidade encontrada.
  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite o nome de uma cidade para buscar.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSearching = true);

    try {
      final city = await _weatherApiService.searchCity(query);

      if (!mounted) return;

      if (city != null) {
        _searchController.clear();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsScreen(city: city),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nenhuma localidade encontrada para "$query".'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro na busca: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Encerrar Sessão'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final auth = context.watch<AuthProvider>();
    final citiesProvider = context.watch<CitiesProvider>();
    final favCount = context.watch<FavoritesProvider>().count;
    final consCount = context.watch<ConsumedProvider>().count;

    // Cálculo dinâmico da altura dos cards no GridView para resiliência ao textScaler (RF10)
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final cardExtent = 160.0 * (textScale > 1.0 ? textScale : 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Previsão do Tempo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (auth.currentUser != null)
              Text(
                'Olá, ${auth.currentUser!.name.split(' ').first}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: [
          // Acesso à Tela de Favoritos (RF01, RF05)
          Semantics(
            button: true,
            label: 'Abrir tela de favoritos. $favCount cidades salvas.',
            child: IconButton(
              icon: Badge(
                isLabelVisible: favCount > 0,
                label: Text('$favCount'),
                child: const Icon(Icons.star_rounded),
              ),
              tooltip: 'Favoritos ($favCount)',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                );
              },
            ),
          ),

          // Acesso à Tela de Cidades Consultadas (RF01, RF07)
          Semantics(
            button: true,
            label: 'Abrir tela de cidades consultadas. $consCount cidades salvas.',
            child: IconButton(
              icon: Badge(
                isLabelVisible: consCount > 0,
                label: Text('$consCount'),
                child: const Icon(Icons.checklist_rounded),
              ),
              tooltip: 'Consultadas ($consCount)',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConsumedScreen()),
                );
              },
            ),
          ),

          // Botão de Logout (RF01, RF07 baseline)
          Semantics(
            button: true,
            label: 'Encerrar sessão do usuário',
            child: IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Sair da conta',
              onPressed: _confirmLogout,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de Busca de Cidade (RF08)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Semantics(
              label: 'Seção de busca de cidades pelo nome',
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _handleSearch(),
                      decoration: InputDecoration(
                        hintText: 'Buscar cidade (ex.: Curitiba, Londres)...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    button: true,
                    label: 'Botão para executar a busca da cidade informada',
                    child: ElevatedButton(
                      onPressed: _isSearching ? null : _handleSearch,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Buscar'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Conteúdo Principal: Estado Inicial, Erro ou Grade de Cidades
          Expanded(
            child: _buildBody(citiesProvider, cardExtent),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(CitiesProvider citiesProvider, double cardExtent) {
    // 1. Carregamento inicial do catálogo (RF09)
    if (citiesProvider.isLoadingInitial) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando catálogo climático...'),
          ],
        ),
      );
    }

    // 2. Erro de carregamento inicial (RF09)
    if (citiesProvider.errorMessage != null && citiesProvider.items.isEmpty) {
      return ErrorView(
        message: citiesProvider.errorMessage!,
        onRetry: () => citiesProvider.loadInitial(),
      );
    }

    final items = citiesProvider.items;

    // 3. Grade de cidades (RF01) com suporte a Pull-to-refresh
    return RefreshIndicator(
      onRefresh: () => citiesProvider.refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: cardExtent, // Resiliente à escala de texto (RF10)
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = items[index];
                  return CityCard(
                    item: item,
                    onTap: () {
                      // Navega para Detalhes usando Navigator.push (RF02)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailsScreen(city: item.city),
                        ),
                      );
                    },
                  );
                },
                childCount: items.length,
              ),
            ),
          ),

          // Botão "Carregar Mais" / Indicador de carregamento de página (RF01, RF09)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: citiesProvider.isLoadingMore
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      )
                    : citiesProvider.hasMore
                        ? Semantics(
                            button: true,
                            label: 'Carregar mais cidades no catálogo',
                            child: ElevatedButton.icon(
                              onPressed: () => citiesProvider.loadNextPage(),
                              icon: const Icon(Icons.expand_more_rounded),
                              label: const Text('Carregar Mais'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(200, 48), // RF10: 48x48
                              ),
                            ),
                          )
                        : Text(
                            'Você chegou ao fim do catálogo (~40 cidades)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
