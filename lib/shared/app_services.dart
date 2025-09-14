import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../data/local/characters_dao.dart';
import '../data/local/database_provider.dart';
import '../data/local/favorites_dao.dart';
import '../data/remote/api_client.dart';
import '../data/repositories/characters_repository.dart';
import '../data/repositories/favorites_repository.dart';
import 'http_proxy/debug_proxy_config.dart';
import 'http_proxy/dio_proxy.dart';

class AppServices {
  late final Dio dio;
  late final RickAndMortyApiClient apiClient;
  late final AppDatabaseProvider dbProvider;
  late final SqfliteCharactersDao charactersDao;
  late final SqfliteFavoritesDao favoritesDao;
  late final CharactersRepository charactersRepository;
  late final FavoritesRepository favoritesRepository;

  AppServices._();

  static Future<AppServices> init({DebugProxyConfig? proxy}) async {
    final s = AppServices._();
    s.dio = Dio(BaseOptions(
      baseUrl: 'https://rickandmortyapi.com/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));
    s.dio.interceptors.add(LogInterceptor(responseBody: false));
    s.dio.httpClientAdapter = IOHttpClientAdapter();
    if (proxy != null) {
      applyProxyToDio(s.dio, proxy);
    }

    s.apiClient = RickAndMortyApiClient(s.dio);

    s.dbProvider = AppDatabaseProvider();
    s.charactersDao = SqfliteCharactersDao(s.dbProvider);
    s.favoritesDao = SqfliteFavoritesDao(s.dbProvider);

    s.favoritesRepository = FavoritesRepository(s.favoritesDao);
    s.charactersRepository = CharactersRepository(
      s.apiClient,
      s.charactersDao,
      onCacheUpdated: () => s.favoritesRepository.onCharactersCacheUpdated(),
    );

    return s;
  }
}


