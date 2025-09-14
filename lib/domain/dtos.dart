import 'dart:convert';

import 'models.dart';

class CharacterDto {
  final int id;
  final String name;
  final String status;
  final String species;
  final String locationName;
  final String imageUrl;
  final Map<String, dynamic> rawJson;

  CharacterDto({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.locationName,
    required this.imageUrl,
    required this.rawJson,
  });

  factory CharacterDto.fromJson(Map<String, dynamic> json) {
    return CharacterDto(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String? ?? '',
      species: json['species'] as String? ?? '',
      locationName: (json['location'] as Map<String, dynamic>?)?['name'] as String? ?? '',
      imageUrl: json['image'] as String? ?? '',
      rawJson: json,
    );
  }

  Character toDomain() {
    return Character(
      id: id,
      name: name,
      status: status,
      species: species,
      locationName: locationName,
      imageUrl: imageUrl,
    );
  }

  String toRawJsonString() => jsonEncode(rawJson);
}

class PaginatedDto<T> {
  final PageInfo info;
  final List<T> results;

  PaginatedDto({required this.info, required this.results});
}


