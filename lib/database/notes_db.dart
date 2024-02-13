import 'package:learning_sqlite_flutter/models/note.dart';
import 'package:learning_sqlite_flutter/services/sqlite_service.dart';
import 'package:sqflite/sqflite.dart';

class NotesDB {
  final tableName = 'todos';

  Future<void> createTable(Database database, int version) async {
    await database.execute(''' 
      CREATE TABLE IF NOT EXISTS $tableName (
        "id" INTEGER PRIMARY KEY AUTOINCREMENT,
        "title" TEXT NOT NULL,
        "description" TEXT NOT NULL
      )
     ''');
  }

  Future<int> create(
      {required String title, required String description}) async {
    final database = await SqliteService().database;

    return await database.rawInsert(
      '''
      INSERT INTO $tableName (title , description) VALUES (?,?)
     ''',
      [title, description],
    );
  }

  Future<List<Note>> fetchAll() async {
    final database = await SqliteService().database;

    final notes = await database.rawQuery(''' 
        SELECT * from $tableName 
      ''');

    return notes.map((note) => Note.fromSqfliteDatabase(note)).toList();
  }

  Future<Note> fetchById(int id) async {
    final database = await SqliteService().database;

    final note = await database.rawQuery('''
      SELECT * from $tableName WHERE id = ?
     ''', [id]);

    return Note.fromSqfliteDatabase(note.first);
  }

  Future<int> update(
      {required int id, String? title, String? description}) async {
    final database = await SqliteService().database;

    return await database.update(
      tableName,
      {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
      },
      where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final database = await SqliteService().database;
    await database.rawDelete(
      ''' 
        DELETE FROM $tableName WHERE id = ?
      ''',
      [id],
    );
  }
}
