import 'package:sqflite/sqflite.dart';
import 'package:noor_quran/core/database/database_helper.dart';
import 'package:noor_quran/features/quran/domain/entities/last_read.dart';

class LastReadDao {
  final DatabaseHelper _dbHelper;

  LastReadDao(this._dbHelper);

  Future<Database> get _db async => await _dbHelper.database;

  Future<void> saveLastRead(LastRead lastRead) async {
    final db = await _db;

    await db.delete('last_read');

    await db.insert('last_read', lastRead.toMap());
  }

  Future<LastRead?> getLastRead() async {
    final db = await _db;
    final result = await db.query(
      'last_read',
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return LastRead.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateLastRead(LastRead lastRead) async {
    final db = await _db;
    await db.update(
      'last_read',
      lastRead.toMap(),
      where: 'id = ?',
      whereArgs: [lastRead.id],
    );
  }
}
