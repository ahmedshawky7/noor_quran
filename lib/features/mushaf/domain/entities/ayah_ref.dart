class AyahRef {
  const AyahRef({
    required this.surahNumber,
    required this.ayahNumber,
    required this.pageNumber,
  });

  final int surahNumber;
  final int ayahNumber;
  final int pageNumber;

  @override
  bool operator ==(Object other) {
    return other is AyahRef &&
        other.surahNumber == surahNumber &&
        other.ayahNumber == ayahNumber &&
        other.pageNumber == pageNumber;
  }

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber, pageNumber);
}
