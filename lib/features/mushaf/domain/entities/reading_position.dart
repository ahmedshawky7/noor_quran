import 'ayah_ref.dart';

class ReadingPosition {
  const ReadingPosition({
    required this.pageNumber,
    required this.anchorAyah,
    required this.updatedAt,
  });

  final int pageNumber;
  final AyahRef? anchorAyah;
  final DateTime updatedAt;
}
