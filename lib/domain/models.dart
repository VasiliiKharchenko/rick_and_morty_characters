import 'package:flutter/material.dart';

class PageInfo {
  final int count;
  final int pages;
  final String? next;
  final String? prev;

  const PageInfo({
    required this.count,
    required this.pages,
    required this.next,
    required this.prev,
  });
}

class Paginated<T> {
  final PageInfo info;
  final List<T> results;

  const Paginated({required this.info, required this.results});
}

class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String locationName;
  final String imageUrl;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.locationName,
    required this.imageUrl,
  });

  Character copyWith({
    int? id,
    String? name,
    String? status,
    String? species,
    String? locationName,
    String? imageUrl,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      species: species ?? this.species,
      locationName: locationName ?? this.locationName,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

@immutable
class FavoritesSort {
  final String value;
  const FavoritesSort._(this.value);

  static const FavoritesSort byName = FavoritesSort._('name');
  static const FavoritesSort byStatus = FavoritesSort._('status');

  @override
  String toString() => value;
}


