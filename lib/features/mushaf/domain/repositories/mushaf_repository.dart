import '../entities/ayah_ref.dart';
import '../entities/surah_summary.dart';
import '../entities/quran_verse_search_result.dart';

abstract interface class MushafRepository {
  int pageForAyah(int surahNumber, int ayahNumber);
  AyahRef firstAyahOnPage(int pageNumber);
  int ayahCountForSurah(int surahNumber);
  String arabicSurahName(int surahNumber);
  String verseText(AyahRef ayah);
  int juzForAyah(AyahRef ayah);
  List<SurahSummary> getAllSurahs();
  List<QuranVerseSearchResult> searchVerses(String query);
}
