import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../data/repositories/characters_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../domain/models.dart';
import '../../domain/usecases.dart';

sealed class CharactersEvent {}

class CharactersStarted extends CharactersEvent {}

class CharactersLoadNextPage extends CharactersEvent {}

class CharactersRefresh extends CharactersEvent {}

class CharactersForceRefresh extends CharactersEvent {}

class CharactersToggleFavorite extends CharactersEvent {
  final int characterId;
  CharactersToggleFavorite(this.characterId);
}

class CharactersState {
  final List<Character> items;
  final int currentPage;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  final Set<int> favorites;

  const CharactersState({
    required this.items,
    required this.currentPage,
    required this.hasMore,
    required this.isLoading,
    required this.error,
    required this.favorites,
  });

  factory CharactersState.initial() => const CharactersState(
        items: [],
        currentPage: 0,
        hasMore: true,
        isLoading: false,
        error: null,
        favorites: {},
      );

  CharactersState copyWith({
    List<Character>? items,
    int? currentPage,
    bool? hasMore,
    bool? isLoading,
    String? error,
    Set<int>? favorites,
    bool clearError = false,
  }) {
    return CharactersState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      favorites: favorites ?? this.favorites,
    );
  }
}

class CharactersBloc extends Bloc<CharactersEvent, CharactersState> {
  final CharactersRepository charactersRepository;
  final FavoritesRepository favoritesRepository;

  late final FetchCharactersPage _fetchPage;
  late final ToggleFavorite _toggleFavorite;

  bool _isLoadingNext = false;
  StreamSubscription<List<Character>>? _cacheSub;

  CharactersBloc({
    required this.charactersRepository,
    required this.favoritesRepository,
  }) : super(CharactersState.initial()) {
    _fetchPage = FetchCharactersPage(charactersRepository);
    _toggleFavorite = ToggleFavorite(favoritesRepository);

    on<CharactersStarted>(_onStarted);
    on<CharactersLoadNextPage>(_onLoadNext);
    on<CharactersRefresh>(_onRefresh);
    on<CharactersForceRefresh>(_onForceRefresh);
    on<CharactersToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onStarted(CharactersStarted event, Emitter<CharactersState> emit) async {
    _cacheSub?.cancel();
    _cacheSub = charactersRepository.watchAllCached().listen((cached) {
      add(CharactersRefresh());
    });
    try {
      final favIds = await favoritesRepository.getAllFavoriteIds();
      emit(state.copyWith(favorites: favIds.toSet()));
    } catch (_) {}
    if (state.items.isEmpty) {
      add(CharactersLoadNextPage());
    }
  }

  Future<void> _onLoadNext(CharactersLoadNextPage event, Emitter<CharactersState> emit) async {
    if (_isLoadingNext || !state.hasMore) return;
    _isLoadingNext = true;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final nextPage = state.currentPage + 1;
      final paged = await _fetchPage(nextPage).timeout(const Duration(seconds: 8));
      final newList = [...state.items];
      final existingIds = newList.map((e) => e.id).toSet();
      for (final item in paged.results) {
        if (!existingIds.contains(item.id)) {
          newList.add(item);
        }
      }
      final hasMore = nextPage < paged.info.pages && (paged.info.next != null);
      emit(state.copyWith(
        items: newList,
        currentPage: nextPage,
        hasMore: hasMore,
        isLoading: false,
      ));
    } catch (e) {
      // Остаёмся в offline: сбрасываем флаг загрузки и не блокируем дальнейшие попытки
      emit(state.copyWith(isLoading: false, error: e.toString()));
    } finally {
      _isLoadingNext = false;
    }
  }

  Future<void> _onRefresh(CharactersRefresh event, Emitter<CharactersState> emit) async {
    final cached = await charactersRepository.watchAllCached().first;
    final existingIds = cached.map((e) => e.id).toSet();
    final favs = {...state.favorites}.where((id) => existingIds.contains(id)).toSet();
    emit(state.copyWith(items: cached, favorites: favs, clearError: true));
  }

  Future<void> _onForceRefresh(CharactersForceRefresh event, Emitter<CharactersState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final paged = await _fetchPage(1).timeout(const Duration(seconds: 8));
      final hasMore = 1 < paged.info.pages && (paged.info.next != null);
      emit(state.copyWith(
        items: paged.results,
        currentPage: 1,
        hasMore: hasMore,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onToggleFavorite(CharactersToggleFavorite event, Emitter<CharactersState> emit) async {
    final id = event.characterId;
    final nextFavs = {...state.favorites};
    if (nextFavs.contains(id)) {
      nextFavs.remove(id);
    } else {
      nextFavs.add(id);
    }
    emit(state.copyWith(favorites: nextFavs));
    try {
      await _toggleFavorite(id);
    } catch (_) {
      // rollback on error
      final rollback = {...state.favorites};
      if (rollback.contains(id)) {
        rollback.remove(id);
      } else {
        rollback.add(id);
      }
      emit(state.copyWith(favorites: rollback));
    }
  }

  @override
  Future<void> close() {
    _cacheSub?.cancel();
    charactersRepository.dispose();
    favoritesRepository.dispose();
    return super.close();
  }
}


