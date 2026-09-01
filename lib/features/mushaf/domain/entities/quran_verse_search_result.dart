import 'ayah_ref.dart';

class QuranVerseSearchResult {
  const QuranVerseSearchResult({
    required this.ayah,
    required this.surahName,
    required this.text,
  });

  final AyahRef ayah;
  final String surahName;
  final String text;
}
