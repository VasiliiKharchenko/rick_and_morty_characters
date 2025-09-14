import 'package:flutter/material.dart';

import '../../domain/models.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const CharacterCard({super.key, required this.character, required this.isFavorite, required this.onToggleFavorite});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(character.imageUrl)),
        title: Text(character.name),
        subtitle: Text('${character.status} • ${character.species}\n${character.locationName}'),
        isThreeLine: true,
        trailing: IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(isFavorite ? Icons.star : Icons.star_border, key: ValueKey(isFavorite)),
          ),
          onPressed: onToggleFavorite,
        ),
      ),
    );
  }
}


