import '../entities/reading_position.dart';

abstract interface class ReadingPositionRepository {
  Future<ReadingPosition?> getLastPosition();
  Future<void> save(ReadingPosition position);

  /// مرجعية يختارها المستخدم صراحة، منفصلة عن آخر موضع قراءة محفوظ تلقائياً.
  Future<ReadingPosition?> getBookmark();
  Future<void> saveBookmark(ReadingPosition position);
  Future<void> clearBookmark();
}
