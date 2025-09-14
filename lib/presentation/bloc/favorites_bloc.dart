import 'package:bloc/bloc.dart';

import '../../domain/models.dart';
import '../../domain/usecases.dart';

sealed class FavoritesEvent {}

class FavoritesLoad extends FavoritesEvent {}

class FavoritesToggleFavorite extends FavoritesEvent {
  final int id;
  FavoritesToggleFavorite(this.id);
}

class FavoritesChangeSort extends FavoritesEvent {
  final FavoritesSort sort;
  FavoritesChangeSort(this.sort);
}

class FavoritesState {
  final List<Character> items;
  final FavoritesSort sort;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    required this.items,
    required this.sort,
    required this.isLoading,
    required this.error,
  });

  factory FavoritesState.initial() => const FavoritesState(
        items: [],
        sort: FavoritesSort.byName,
        isLoading: false,
        error: null,
      );

  FavoritesState copyWith({
    List<Character>? items,
    FavoritesSort? sort,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return FavoritesState(
      items: items ?? this.items,
      sort: sort ?? this.sort,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesSorted _getFavorites;
  final ToggleFavorite _toggleFavorite;

  FavoritesBloc({required GetFavoritesSorted getFavorites, required ToggleFavorite toggleFavorite})
      : _getFavorites = getFavorites,
        _toggleFavorite = toggleFavorite,
        super(FavoritesState.initial()) {
    on<FavoritesLoad>(_onLoad);
    on<FavoritesChangeSort>(_onChangeSort);
    on<FavoritesToggleFavorite>(_onToggle);
  }

  Future<void> _onLoad(FavoritesLoad event, Emitter<FavoritesState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await emit.forEach(
        _getFavorites(state.sort),
        onData: (data) => state.copyWith(items: data, isLoading: false),
        onError: (_, err) => state.copyWith(isLoading: false, error: err.toString()),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onChangeSort(FavoritesChangeSort event, Emitter<FavoritesState> emit) async {
    emit(state.copyWith(sort: event.sort, isLoading: true));
    add(FavoritesLoad());
  }

  Future<void> _onToggle(FavoritesToggleFavorite event, Emitter<FavoritesState> emit) async {
    await _toggleFavorite(event.id, currentSort: state.sort);
  }
}


