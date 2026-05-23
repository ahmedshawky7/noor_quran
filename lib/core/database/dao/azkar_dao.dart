import 'package:noor_quran/core/database/database_helper.dart';
import 'package:noor_quran/features/azkar/domain/entities/zikr.dart';
import 'package:sqflite/sqflite.dart';

class AzkarDao {
  final DatabaseHelper _dbHelper;

  AzkarDao(this._dbHelper);

  Future<Database> get database async =>
      await _dbHelper.database;

  // =========================
  // Insert Single Zikr
  // =========================

  Future<void> insertZikr(
    Map<String, dynamic> zikrMap,
  ) async {
    final db = await database;

    await db.insert(
      'azkar',
      zikrMap,
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  // =========================
  // Batch Insert
  // =========================

  Future<void> insertBatch(
    List<Map<String, dynamic>> azkarList,
  ) async {
    final db = await database;

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final zikr in azkarList) {
        batch.insert(
          'azkar',
          {
            'category':
                zikr['category'] ?? '',
            'text_arabic':
                zikr['text_arabic'] ?? '',
            'text_english':
                zikr['text_english'] ?? '',
            'translation':
                zikr['translation'] ?? '',
            'count': zikr['count'] ?? 1,
            'reference':
                zikr['reference'] ?? '',
            'favorite': 0,
          },
          conflictAlgorithm:
              ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
  }

  // =========================
  // Get By Category
  // =========================

  Future<List<Zikr>> getZikrByCategory(
    String category,
  ) async {
    final db = await database;

    final result = await db.query(
      'azkar',
      where: 'category = ?',
      whereArgs: [category],
    );

    return result
        .map((e) => Zikr.fromMap(e))
        .toList();
  }

  // =========================
  // Get Categories
  // =========================

  Future<List<String>> getAllCategories() async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT DISTINCT category
      FROM azkar
      ORDER BY category
      ''',
    );

    return result
        .map((e) => e['category'] as String)
        .toList();
  }

  // =========================
  // Search Azkar
  // =========================

  Future<List<Zikr>> searchAzkar(
    String query,
  ) async {
    final db = await database;

    final result = await db.query(
      'azkar',
      where:
          'text_arabic LIKE ? OR text_english LIKE ?',
      whereArgs: [
        '%$query%',
        '%$query%',
      ],
      limit: 50,
    );

    return result
        .map((e) => Zikr.fromMap(e))
        .toList();
  }
}