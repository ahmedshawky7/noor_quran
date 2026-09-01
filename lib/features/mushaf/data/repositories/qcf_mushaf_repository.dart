import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:qcf_quran_plus/src/data/quran_data.dart' show quran;

import '../../domain/entities/ayah_ref.dart';
import '../../domain/entities/surah_summary.dart';
import '../../domain/entities/quran_verse_search_result.dart';
import '../../domain/repositories/mushaf_repository.dart';

class QcfMushafRepository implements MushafRepository {
  late final List<_IndexedVerse> _verseSearchIndex = _buildVerseSearchIndex();
  @override
  String arabicSurahName(int surahNumber) => getSurahNameArabic(surahNumber);

  @override
  int ayahCountForSurah(int surahNumber) => getVerseCount(surahNumber);

  @override
  AyahRef firstAyahOnPage(int pageNumber) {
    final data = getPageData(pageNumber);
    if (data.isEmpty) {
      throw StateError('لا توجد بيانات للصفحة $pageNumber');
    }
    final first = data.first;
    final surah = first['surah'] as int;
    final ayah = first['start'] as int;
    return AyahRef(
      surahNumber: surah,
      ayahNumber: ayah,
      pageNumber: pageNumber,
    );
  }

  @override
  List<SurahSummary> getAllSurahs() {
    return List.unmodifiable(List.generate(114, (index) {
      final number = index + 1;
      return SurahSummary(
        number: number,
        arabicName: getSurahNameArabic(number),
        ayahCount: getVerseCount(number),
        firstPage: getPageNumber(number, 1),
      );
    }));
  }

  @override
  List<QuranVerseSearchResult> searchVerses(String query) {
    final normalizedQuery = _normalizeArabic(query);
    if (normalizedQuery.isEmpty) return const [];
    return _verseSearchIndex
        .where((entry) => entry.normalizedText.contains(normalizedQuery))
        .map((entry) => entry.result)
        .toList(growable: false);
  }

  List<_IndexedVerse> _buildVerseSearchIndex() {
    return List.unmodifiable(quran.map((raw) {
      final surahNumber = raw['sora'] as int;
      final ayahNumber = raw['aya_no'] as int;
      // البحث يعتمد النص الإملائي، بينما العرض يحافظ على الرسم العثماني المشكّل.
      final searchText = raw['aya_text_emlaey'].toString().trim();
      final displayText = raw['aya_text']
          .toString()
          .replaceAll(RegExp(r'[\n\r]+'), ' ')
          .replaceAll(RegExp(r'[\u00A0\s]+[٠-٩]+$'), '')
          .trim();
      final ayah = AyahRef(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        pageNumber: raw['page'] as int,
      );
      return _IndexedVerse(
        result: QuranVerseSearchResult(
          ayah: ayah,
          surahName: getSurahNameArabic(surahNumber),
          text: displayText,
        ),
        normalizedText: _normalizeArabic(searchText),
      );
    }));
  }

  String _normalizeArabic(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');
  }

  @override
  String verseText(AyahRef ayah) => getVerse(ayah.surahNumber, ayah.ayahNumber);

  @override
  int juzForAyah(AyahRef ayah) => getJuzNumber(ayah.surahNumber, ayah.ayahNumber);

  @override
  int pageForAyah(int surahNumber, int ayahNumber) =>
      getPageNumber(surahNumber, ayahNumber);
}

class _IndexedVerse {
  const _IndexedVerse({required this.result, required this.normalizedText});

  final QuranVerseSearchResult result;
  final String normalizedText;
}
