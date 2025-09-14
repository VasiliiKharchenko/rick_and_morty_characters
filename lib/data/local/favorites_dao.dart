import 'package:sqflite/sqflite.dart';

import 'database_provider.dart';

class SqfliteFavoritesDao {
  final AppDatabaseProvider _provider;
  SqfliteFavoritesDao(this._provider);

  Future<void> toggle(int characterId) async {
    final db = await _provider.database;
    final exists = await isFavorite(characterId);
    if (exists) {
      await db.delete('favorites', where: 'character_id = ?', whereArgs: [characterId]);
    } else {
      await db.insert('favorites', {'character_id': characterId}, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<bool> isFavorite(int characterId) async {
    final db = await _provider.database;
    final res = await db.query('favorites', where: 'character_id = ?', whereArgs: [characterId], limit: 1);
    return res.isNotEmpty;
  }

  Future<List<int>> getAllFavoriteIds() async {
    final db = await _provider.database;
    final rows = await db.query('favorites', columns: ['character_id']);
    return rows.map((e) => (e['character_id'] as int?) ?? 0).where((e) => e != 0).toList();
  }

  Future<List<Map<String, Object?>>> getAllFavoritesJoined({required String orderBy}) async {
    final db = await _provider.database;
    final order = switch (orderBy) { 'status' => 'c.status ASC, c.name ASC', _ => 'c.name ASC' };
    return db.rawQuery('''
SELECT c.* FROM favorites f
JOIN characters c ON c.id = f.character_id
ORDER BY $order
''');
  }
}


