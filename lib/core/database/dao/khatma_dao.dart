import 'package:sqflite/sqflite.dart';
import 'package:noor_quran/core/database/database_helper.dart';
import 'package:noor_quran/features/khatma/domain/entities/khatma_progress.dart';

class KhatmaDao {
  final DatabaseHelper _dbHelper;
  
  KhatmaDao(this._dbHelper);
  
  Future<Database> get _db async => await _dbHelper.database;
  
  Future<void> saveKhatmaProgress(KhatmaProgress progress) async {
    final db = await _db;
    await db.insert('khatma_progress', progress.toMap());
  }
  
  Future<KhatmaProgress?> getCurrentKhatma() async {
    final db = await _db;
    final result = await db.query(
      'khatma_progress',
      orderBy: 'start_date DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return KhatmaProgress.fromMap(result.first);
    }
    return null;
  }
  
  Future<void> updateKhatmaProgress(KhatmaProgress progress) async {
    final db = await _db;
    await db.update(
      'khatma_progress',
      progress.toMap(),
      where: 'id = ?',
      whereArgs: [progress.id],
    );
  }
}