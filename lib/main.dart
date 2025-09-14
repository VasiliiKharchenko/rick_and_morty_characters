import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/characters_repository.dart';
import 'data/repositories/favorites_repository.dart';
import 'presentation/bloc/characters_bloc.dart';
import 'presentation/bloc/favorites_bloc.dart';
import 'presentation/bloc/theme_cubit.dart';
import 'presentation/ui/root_scaffold.dart';
import 'shared/app_services.dart';
import 'shared/http_proxy/debug_proxy_config.dart';
import 'shared/http_proxy/proxy_debug_screen.dart';
import 'shared/http_proxy/run_with_proxy.dart';
import 'domain/usecases.dart';
import 'shared/theme_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final proxyFromEnv = DebugProxyConfig.fromEnv();
  if (proxyFromEnv.enabled) {
    setGlobalProxy(proxyFromEnv);
  }
  final services = await AppServices.init(proxy: proxyFromEnv.enabled ? proxyFromEnv : null);
  final storedTheme = await ThemeStorage().readMode();
  runApp(MyApp(services: services, initialProxy: proxyFromEnv, initialThemeMode: storedTheme ?? ThemeMode.light));
}

class MyApp extends StatelessWidget {
  final AppServices services;
  final DebugProxyConfig initialProxy;
  final ThemeMode initialThemeMode;
  const MyApp({super.key, required this.services, required this.initialProxy, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CharactersRepository>.value(value: services.charactersRepository),
        RepositoryProvider<FavoritesRepository>.value(value: services.favoritesRepository),
        RepositoryProvider<Dio>.value(value: services.dio),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit(initialMode: initialThemeMode)),
          BlocProvider(
            create: (ctx) => CharactersBloc(
              charactersRepository: ctx.read<CharactersRepository>(),
              favoritesRepository: ctx.read<FavoritesRepository>(),
            ),
          ),
          BlocProvider(
            create: (ctx) => FavoritesBloc(
              getFavorites: GetFavoritesSorted(ctx.read<FavoritesRepository>()),
              toggleFavorite: ToggleFavorite(ctx.read<FavoritesRepository>()),
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'Rick & Morty',
              theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
              darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark)),
              themeMode: themeMode,
              themeAnimationDuration: const Duration(milliseconds: 250),
              themeAnimationCurve: Curves.easeInOut,
              routes: {
                '/': (_) => const RootScaffold(),
                '/proxy': (_) => ProxyDebugScreen(dio: context.read<Dio>(), initialConfig: initialProxy),
              },
            );
          },
        ),
      ),
    );
  }
}
