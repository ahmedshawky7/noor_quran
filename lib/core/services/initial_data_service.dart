import 'package:flutter/foundation.dart';
import 'package:noor_quran/core/services/quran_api_service.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class InitialDataService {
  final DatabaseHelper dbHelper;
  final QuranApiService apiService;
  InitialDataService(this.dbHelper, this.apiService);

  Future<bool> isDataAlreadyLoaded() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM surahs');
    final count = result.first['count'] as int;
    return count > 0;
  }

  Future<void> loadInitialData() async {
    final db = await dbHelper.database;
    final response = await apiService.fetchQuran();
    final surahs = response['data']['surahs'];

    final batch = db.batch();

    for (final surah in surahs) {
      final surahNumber = surah['number'] as int;

      batch.insert(
        'surahs',
        {
          'id': surahNumber,
          'name': surah['englishName'],
          'name_arabic': surah['name'],
          'english_name': surah['englishNameTranslation'],
          'revelation_type': surah['revelationType'],
          'total_ayahs': (surah['ayahs'] as List).length,
          'page': surah['ayahs'][0]['page'],
          'juz_list': '[]',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final ayahs = surah['ayahs'] as List;
      for (int i = 0; i < ayahs.length; i++) {
        final ayah = ayahs[i];
        String text = ayah['text'];

        final hizbQuarter = ayah['hizbQuarter'] as int;
        final hizb = ((hizbQuarter - 1) ~/ 4) + 1;

        batch.insert(
          'ayahs',
          {
            'id': ayah['number'],
            'surah_id': surahNumber,
            'ayah_number': ayah['numberInSurah'],
            'text_uthmani': text,
            'text_simple': text,
            'juz': ayah['juz'],
            'hizb': hizb,
            'hizb_quarter': hizbQuarter,
            'page': ayah['page'],
            'sajda': ayah['sajda'] == false ? 0 : 1,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit(noResult: true);
    debugPrint('Quran Loaded Successfully');
  }
}