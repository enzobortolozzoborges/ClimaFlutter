import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/weather_api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/consumed_provider.dart';
import 'providers/cities_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a persistência local (SharedPreferences)
  final storageService = await StorageService.getInstance();
  final weatherApiService = WeatherApiService();

  runApp(
    MultiProvider(
      providers: [
        // Provider de Autenticação e Sessão
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(storageService),
        ),

        // Provider de Cidades Favoritas (reativo ao usuário logado)
        ChangeNotifierProxyProvider<AuthProvider, FavoritesProvider>(
          create: (_) => FavoritesProvider(storageService),
          update: (_, auth, favorites) {
            final provider = favorites ?? FavoritesProvider(storageService);
            provider.updateCurrentUser(auth.currentUser?.email);
            return provider;
          },
        ),

        // Provider de Cidades Consultadas (reativo ao usuário logado)
        ChangeNotifierProxyProvider<AuthProvider, ConsumedProvider>(
          create: (_) => ConsumedProvider(storageService),
          update: (_, auth, consumed) {
            final provider = consumed ?? ConsumedProvider(storageService);
            provider.updateCurrentUser(auth.currentUser?.email);
            return provider;
          },
        ),

        // Provider do Catálogo de Cidades (reativo à cidade de origem do usuário)
        ChangeNotifierProxyProvider<AuthProvider, CitiesProvider>(
          create: (_) => CitiesProvider(weatherApiService),
          update: (_, auth, cities) {
            final provider = cities ?? CitiesProvider(weatherApiService);
            provider.updateOriginCity(auth.currentUser?.originCity);
            return provider;
          },
        ),
      ],
      child: const ClimaApp(),
    ),
  );
}


class ClimaApp extends StatelessWidget {
  const ClimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clima Brasil & Mundo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Aguarda checagem de sessão persistida no SharedPreferences
    if (!auth.isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Inicializando aplicativo...'),
            ],
          ),
        ),
      );
    }

    if (auth.isAuthenticated) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}