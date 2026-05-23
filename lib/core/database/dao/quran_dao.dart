import 'package:noor_quran/core/database/database_helper.dart';
import 'package:noor_quran/features/quran/domain/entities/ayah.dart';
import 'package:noor_quran/features/quran/domain/entities/surah.dart';
import 'package:noor_quran/features/quran/domain/entities/tafsir.dart';
import 'package:sqflite/sqflite.dart';

class QuranDao {
  final DatabaseHelper _dbHelper;

  QuranDao(this._dbHelper);

  Future<Database> get database async => await _dbHelper.database;

  // =========================
  // Get Surah By Id
  // =========================

  Future<Surah?> getSurahById(int id) async {
    final db = await database;

    final result = await db.query(
      'surahs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Surah.fromMap(result.first);
  }

  // =========================
  // Get Single Ayah
  // =========================

  Future<Ayah?> getAyah(int surahId, int ayahNumber) async {
    final db = await database;

    final result = await db.query(
      'ayahs',
      where: 'surah_id = ? AND ayah_number = ?',
      whereArgs: [surahId, ayahNumber],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Ayah.fromMap(result.first);
  }

  Future<void> insertSurahsBatch(List<Map<String, dynamic>> surahs) async {
    final db = await database;

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final surah in surahs) {
        batch.insert(
          'surahs',
          surah,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
  }

  Future<List<Surah>> getAllSurahs() async {
    final db = await database;
    final result = await db.query('surahs', orderBy: 'id');
    return result.map((map) => Surah.fromMap(map)).toList();
  }

  // =========================
  // Ayahs
  // =========================

  Future<void> insertAyahsBatch(List<Map<String, dynamic>> ayahs) async {
    final db = await database;

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final ayah in ayahs) {
        batch.insert(
          'ayahs',
          ayah,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
  }

  Future<List<Ayah>> getAyahsBySurah(
      int surahId) async {

    final db = await _dbHelper.database;

    final results = await db.query(
      'ayahs',
      where: 'surah_id=?',
      whereArgs: [surahId],
      orderBy: 'ayah_number ASC',
    );

    return results
        .map((e) => Ayah.fromMap(e))
        .toList();
  }


  Future<void> insertTafsirBatch(List<Map<String, dynamic>> tafsirList) async {
    final db = await database;

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final tafsir in tafsirList) {
        batch.insert(
          'tafsir',
          tafsir,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
  }

  Future<Tafsir?> getTafsir(int surahId, int ayahNumber) async {
    final db = await database;

    final result = await db.query(
      'tafsir',
      where: 'surah_id = ? AND ayah_number = ?',
      whereArgs: [surahId, ayahNumber],
    );

    if (result.isEmpty) return null;

    return Tafsir.fromMap(result.first);
  }
  Future<void> insertSurah(Map<String, dynamic> surahMap) async {
    final db = await database;
    await db.insert(
      'surahs',
      surahMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
