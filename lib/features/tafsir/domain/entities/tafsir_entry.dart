import 'dart:convert';

import 'package:flutter/services.dart';

class TafsirEntry {
  const TafsirEntry({
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
  });

  final int surahNumber;
  final int ayahNumber;
  final String text;
}

abstract class TafsirRepository {
  Future<void> initialize();
  TafsirEntry? find(int surahNumber, int ayahNumber);
}

class LocalTafsirRepository implements TafsirRepository {
  LocalTafsirRepository({this.assetPath = 'assets/tafsir/tafsir_muyassar_source.json'});

  final String assetPath;
  final Map<String, TafsirEntry> _entries = <String, TafsirEntry>{};
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    for (final item in decoded) {
      final map = item as Map<String, dynamic>;
      final surah = int.tryParse('${map['number']}');
      final ayah = int.tryParse('${map['aya']}');
      final text = '${map['text'] ?? ''}'.trim();
      if (surah != null && ayah != null && text.isNotEmpty) {
        _entries['$surah:$ayah'] = TafsirEntry(
          surahNumber: surah,
          ayahNumber: ayah,
          text: text,
        );
      }
    }
    _initialized = true;
  }

  @override
  TafsirEntry? find(int surahNumber, int ayahNumber) =>
      _entries['$surahNumber:$ayahNumber'];
}
