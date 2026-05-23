import 'package:noor_quran/core/database/database_helper.dart';
import 'package:noor_quran/features/hadith/domain/entities/hadith.dart';
import 'package:sqflite/sqflite.dart';

class HadithDao {
  final DatabaseHelper _dbHelper;

  HadithDao(this._dbHelper);

  Future<Database> get database async =>
      await _dbHelper.database;

  // =========================
  // Insert Single Hadith
  // =========================

  Future<void> insertHadith(
    Map<String, dynamic> hadithMap,
  ) async {
    final db = await database;

    await db.insert(
      'hadith',
      hadithMap,
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  // =========================
  // Batch Insert
  // =========================

  Future<void> insertBatch(
    List<Map<String, dynamic>> hadithList,
  ) async {
    final db = await database;

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final hadith in hadithList) {
        batch.insert(
          'hadith',
          {
            'collection':
                hadith['collection'] ?? '',
            'category':
                hadith['category'] ?? '',
            'book_number':
                hadith['book_number'] ?? 0,
            'hadith_number':
                hadith['hadith_number'] ?? 0,
            'text_arabic':
                hadith['text_arabic'] ?? '',
            'text_english':
                hadith['text_english'] ?? '',
            'narrator':
                hadith['narrator'] ?? '',
            'grade': hadith['grade'] ?? '',
          },
          conflictAlgorithm:
              ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
  }

  // =========================
  // Get All Hadith
  // =========================

  Future<List<Hadith>> getAllHadith() async {
    final db = await database;

    final result = await db.query(
      'hadith',
      orderBy: 'id DESC',
    );

    return result
        .map((e) => Hadith.fromMap(e))
        .toList();
  }

  // =========================
  // Get By Collection
  // =========================

  Future<List<Hadith>> getHadithByCollection(
    String collection,
  ) async {
    final db = await database;

    final result = await db.query(
      'hadith',
      where: 'collection = ?',
      whereArgs: [collection],
    );

    return result
        .map((e) => Hadith.fromMap(e))
        .toList();
  }

  // =========================
  // Search Hadith
  // =========================

  Future<List<Hadith>> searchHadith(
    String query,
  ) async {
    final db = await database;

    final result = await db.query(
      'hadith',
      where:
          'text_arabic LIKE ? OR text_english LIKE ?',
      whereArgs: [
        '%$query%',
        '%$query%',
      ],
      limit: 50,
    );

    return result
        .map((e) => Hadith.fromMap(e))
        .toList();
  }
}