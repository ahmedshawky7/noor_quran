import 'package:dartz/dartz.dart';
import 'package:noor_quran/core/errors/failures.dart';
import 'package:noor_quran/features/bookmarks/domain/entities/bookmark.dart';

abstract class BookmarkRepository {
  Future<Either<Failure, void>> addBookmark(Bookmark bookmark);
  Future<Either<Failure, void>> removeBookmark(int id);
  Future<Either<Failure, List<Bookmark>>> getAllBookmarks();
  Future<Either<Failure, Bookmark?>> getBookmark(int surahId, int ayahNumber);
  Future<Either<Failure, void>> updateBookmarkNote(int id, String note);
}