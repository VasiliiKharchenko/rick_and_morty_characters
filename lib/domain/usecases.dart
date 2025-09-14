import '../data/repositories/characters_repository.dart';
import '../data/repositories/favorites_repository.dart';
import 'models.dart';

class FetchCharactersPage {
  final CharactersRepository repo;
  FetchCharactersPage(this.repo);
  Future<Paginated<Character>> call(int page) => repo.fetchPage(page);
}

class ToggleFavorite {
  final FavoritesRepository repo;
  ToggleFavorite(this.repo);
  Future<void> call(int id, {FavoritesSort currentSort = FavoritesSort.byName}) =>
      repo.toggle(id, currentSort: currentSort);
}

class GetFavoritesSorted {
  final FavoritesRepository repo;
  GetFavoritesSorted(this.repo);
  Stream<List<Character>> call(FavoritesSort sort) => repo.watchFavoritesSorted(sort);
}


