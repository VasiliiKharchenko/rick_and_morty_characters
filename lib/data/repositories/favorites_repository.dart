import 'dart:async';

import '../../domain/models.dart';
import '../local/favorites_dao.dart';

class FavoritesRepository {
  final SqfliteFavoritesDao _favoritesDao;

  FavoritesRepository(this._favoritesDao);

  final StreamController<List<Character>> _favoritesStreamController = StreamController.broadcast();

  Stream<List<Character>> watchFavoritesSorted(FavoritesSort sort) async* {
    final list = await _getFavorites(sort);
    yield list;
    yield* _favoritesStreamController.stream;
  }

  Future<void> _emitFavorites(FavoritesSort sort) async {
    final list = await _getFavorites(sort);
    if (!_favoritesStreamController.isClosed) {
      _favoritesStreamController.add(list);
    }
  }

  Future<List<Character>> _getFavorites(FavoritesSort sort) async {
    final order = sort == FavoritesSort.byStatus ? 'status' : 'name';
    final rows = await _favoritesDao.getAllFavoritesJoined(orderBy: order);
    return rows.map(_mapRowToCharacter).toList();
  }

  Future<void> toggle(int characterId, {FavoritesSort currentSort = FavoritesSort.byName}) async {
    await _favoritesDao.toggle(characterId);
    await _emitFavorites(currentSort);
  }

  Future<bool> isFavorite(int characterId) => _favoritesDao.isFavorite(characterId);

  Future<void> onCharactersCacheUpdated({FavoritesSort currentSort = FavoritesSort.byName}) async {
    await _emitFavorites(currentSort);
  }

  Future<List<int>> getAllFavoriteIds() => _favoritesDao.getAllFavoriteIds();

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
    _favoritesStreamController.close();
  }
}


