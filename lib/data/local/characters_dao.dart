import 'package:sqflite/sqflite.dart';

import '../../domain/dtos.dart';
import 'database_provider.dart';

class SqfliteCharactersDao {
  final AppDatabaseProvider _provider;
  SqfliteCharactersDao(this._provider);

  Future<void> upsertCharacters(List<CharacterDto> dtos) async {
    final db = await _provider.database;
    final batch = db.batch();
    for (final dto in dtos) {
      batch.insert(
        'characters',
        {
          'id': dto.id,
          'name': dto.name,
          'status': dto.status,
          'species': dto.species,
          'location_name': dto.locationName,
          'image': dto.imageUrl,
          'json': dto.toRawJsonString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, Object?>>> getAllCharacters() async {
    final db = await _provider.database;
    return db.query('characters', orderBy: 'id ASC');
  }

  Future<List<Map<String, Object?>>> getCharactersPage({required int offset, required int limit}) async {
    final db = await _provider.database;
    return db.query('characters', orderBy: 'id ASC', limit: limit, offset: offset);
  }
}


