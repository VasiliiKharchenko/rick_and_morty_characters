import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/theme_cubit.dart';
import 'characters_screen.dart';
import 'favorites_screen.dart';

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_index == 1) {
          setState(() => _index = 0);
          return false;
        }
        final shouldExit = await showModalBottomSheet<bool>(
          context: context,
          builder: (ctx) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Выйти из приложения?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text('Вы уверены, что хотите закрыть приложение?'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Отмена'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Выйти'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
        return false;
      },
      child: Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () {
            if (kDebugMode) {
              Navigator.of(context).pushNamed('/proxy');
            }
          },
          child: const Text('Rick & Morty Characters'),
        ),
        actions: [
          if (_index == 1)
            BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                return PopupMenuButton<FavoritesSort>(
                  initialValue: state.sort,
                  onSelected: (value) => context.read<FavoritesBloc>().add(FavoritesChangeSort(value)),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: FavoritesSort.byName, child: Text('Sort by name')),
                    PopupMenuItem(value: FavoritesSort.byStatus, child: Text('Sort by status')),
                  ],
                  icon: const Icon(Icons.sort),
                );
              },
            ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              final current = mode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light;
              return PopupMenuButton<ThemeMode>(
                initialValue: current,
                onSelected: (m) => context.read<ThemeCubit>().setThemeMode(m),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: ThemeMode.light, child: Text('Light theme')),
                  PopupMenuItem(value: ThemeMode.dark, child: Text('Dark theme')),
                ],
                icon: Icon(current == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          CharactersScreen(),
          FavoritesScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Characters',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star),
            label: 'Favorites',
          ),
        ],
      ),
    ));
  }
}


