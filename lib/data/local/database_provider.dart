import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabaseProvider {
  static const _dbName = 'rick_and_morty.db';
  static const _dbVersion = 1;

  static final AppDatabaseProvider _instance = AppDatabaseProvider._internal();
  factory AppDatabaseProvider() => _instance;
  AppDatabaseProvider._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dbDir = await getDatabasesPath();
    final path = p.join(dbDir, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE characters(
  id INTEGER PRIMARY KEY,
  name TEXT,
  status TEXT,
  species TEXT,
  location_name TEXT,
  image TEXT,
  json TEXT NOT NULL
);
''');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_characters_name ON characters(name);');
        await db.execute('''
CREATE TABLE favorites(
  character_id INTEGER PRIMARY KEY,
  FOREIGN KEY(character_id) REFERENCES characters(id) ON DELETE CASCADE
);
''');
      },
    );
  }
}


