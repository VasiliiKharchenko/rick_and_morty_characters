import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/characters_bloc.dart';
import 'character_card.dart';

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<CharactersBloc>().add(CharactersStarted());
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      context.read<CharactersBloc>().add(CharactersLoadNextPage());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharactersBloc, CharactersState>(
      builder: (context, state) {
        if (state.items.isEmpty && state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () async => context.read<CharactersBloc>().add(CharactersForceRefresh()),
          child: ListView.builder(
            controller: _controller,
            itemCount: state.items.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.items.length) {
                if (state.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state.error != null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: OutlinedButton.icon(
                        onPressed: () => context.read<CharactersBloc>().add(CharactersLoadNextPage()),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Повторить загрузку'),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }
              final c = state.items[index];
              final fav = state.favorites.contains(c.id);
              return CharacterCard(
                character: c,
                isFavorite: fav,
                onToggleFavorite: () => context.read<CharactersBloc>().add(CharactersToggleFavorite(c.id)),
              );
            },
          ),
        );
      },
    );
  }
}


