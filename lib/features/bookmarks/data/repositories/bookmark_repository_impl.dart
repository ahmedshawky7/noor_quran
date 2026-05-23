import 'package:dartz/dartz.dart';
import 'package:noor_quran/core/database/dao/bookmark_dao.dart';
import 'package:noor_quran/core/errors/failures.dart';
import 'package:noor_quran/features/bookmarks/domain/entities/bookmark.dart';
import 'package:noor_quran/features/bookmarks/domain/repositories/bookmark_repository.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final BookmarkDao _bookmarkDao;
  
  BookmarkRepositoryImpl(this._bookmarkDao);
  
  @override
  Future<Either<Failure, void>> addBookmark(Bookmark bookmark) async {
    try {
      await _bookmarkDao.insertBookmark(bookmark);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add bookmark: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> removeBookmark(int id) async {
    try {
      await _bookmarkDao.deleteBookmark(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to remove bookmark: $e'));
    }
  }
  
  @override
  Future<Either<Failure, List<Bookmark>>> getAllBookmarks() async {
    try {
      final bookmarks = await _bookmarkDao.getAllBookmarks();
      return Right(bookmarks);
    } catch (e) {
      return Left(DatabaseFailure('Failed to load bookmarks: $e'));
    }
  }
  
  @override
  Future<Either<Failure, Bookmark?>> getBookmark(int surahId, int ayahNumber) async {
    try {
      final bookmark = await _bookmarkDao.getBookmark(surahId, ayahNumber);
      return Right(bookmark);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get bookmark: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> updateBookmarkNote(int id, String note) async {
    try {
      await _bookmarkDao.updateBookmarkNote(id, note);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update bookmark note: $e'));
    }
  }
}