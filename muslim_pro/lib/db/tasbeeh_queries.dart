import 'package:sqflite/sqflite.dart';
import '../models/tasbeeh_counter.dart';
import 'database_helper.dart';

class TasbeehQueries {
  static const String _table = 'tasbeeh_counters';

  // CREATE: returns the new row's id
  Future<int> insert(TasbeehCounter counter) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(
      _table,
      counter.toMap()..remove('id'), // let SQLite assign the id
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ: all counters, newest first
  Future<List<TasbeehCounter>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(_table, orderBy: 'created_at DESC');
    return rows.map((row) => TasbeehCounter.fromMap(row)).toList();
  }

  // READ: one counter by id (null if not found)
  Future<TasbeehCounter?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return TasbeehCounter.fromMap(rows.first);
  }

  // UPDATE: returns number of rows changed
  Future<int> update(TasbeehCounter counter) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      _table,
      counter.toMap(),
      where: 'id = ?',
      whereArgs: [counter.id],
    );
  }

  // DELETE: returns number of rows deleted
  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}