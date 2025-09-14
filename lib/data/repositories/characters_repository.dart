import 'dart:async';

import '../../domain/dtos.dart';
import '../../domain/models.dart';
import '../local/characters_dao.dart';
import '../remote/api_client.dart';

class CharactersRepository {
  final RickAndMortyApiClient _apiClient;
  final SqfliteCharactersDao _charactersDao;
  final void Function()? _onCacheUpdated; 

  CharactersRepository(this._apiClient, this._charactersDao, {void Function()? onCacheUpdated})
      : _onCacheUpdated = onCacheUpdated;

  final StreamController<List<Character>> _cachedStreamController = StreamController.broadcast();

  
  Future<Paginated<Character>> fetchPage(int page) async {
    final paged = await _apiClient.getCharacters(page: page);
    await _charactersDao.upsertCharacters(paged.results);
    // notify watchers
    await _emitAllCached();
    _onCacheUpdated?.call();
    final mapped = paged.results.map((e) => e.toDomain()).toList();
    return Paginated<Character>(info: paged.info, results: mapped);
  }

  
  Stream<List<Character>> watchAllCached() async* {
    final all = await _getAllCached();
    yield all;
    yield* _cachedStreamController.stream;
  }

  Future<void> cachePage(List<Character> items) async {
    final dbRows = items
        .map((c) => CharacterDto(
              id: c.id,
              name: c.name,
              status: c.status,
              species: c.species,
              locationName: c.locationName,
              imageUrl: c.imageUrl,
              rawJson: const {},
            ))
        .toList();
    await _charactersDao.upsertCharacters(dbRows);
    await _emitAllCached();
    _onCacheUpdated?.call();
  }

  Future<void> _emitAllCached() async {
    final all = await _getAllCached();
    if (!_cachedStreamController.isClosed) {
      _cachedStreamController.add(all);
    }
  }

  Future<List<Character>> _getAllCached() async {
    final rows = await _charactersDao.getAllCharacters();
    return rows.map(_mapRowToCharacter).toList();
  }

  Character _mapRowToCharacter(Map<String, Object?> row) {
    return Character(
      id: (row['id'] as int?) ?? 0,
      name: (row['name'] as String?) ?? '',
      status: (row['status'] as String?) ?? '',
      species: (row['species'] as String?) ?? '',
      locationName: (row['location_name'] as String?) ?? '',
      imageUrl: (row['image'] as String?) ?? '',
    );
  }

  void dispose() {
    _cachedStreamController.close();
  }
}


