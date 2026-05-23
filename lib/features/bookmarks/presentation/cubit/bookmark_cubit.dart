import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_quran/features/bookmarks/domain/entities/bookmark.dart';
import 'package:noor_quran/features/bookmarks/domain/repositories/bookmark_repository.dart';
import 'package:noor_quran/features/bookmarks/presentation/cubit/bookmark_state.dart';

class BookmarkCubit extends Cubit<BookmarkState> {
  final BookmarkRepository _repository;
  
  BookmarkCubit(this._repository) : super(BookmarkInitial());
  
  Future<void> loadBookmarks() async {
    emit(BookmarkLoading());
    final result = await _repository.getAllBookmarks();
    result.fold(
      (failure) => emit(BookmarkError(failure.message)),
      (bookmarks) => emit(BookmarksLoaded(bookmarks)),
    );
  }
  
  Future<void> addBookmark({required int surahId, required int ayahNumber, String? note}) async {
    final bookmark = Bookmark(
      id: 0,
      surahId: surahId,
      ayahNumber: ayahNumber,
      note: note,
      createdAt: DateTime.now(),
    );
    final result = await _repository.addBookmark(bookmark);
    result.fold(
      (failure) => emit(BookmarkError(failure.message)),
      (_) => emit(BookmarkAdded()),
    );
  }
  
  Future<void> removeBookmark(int id) async {
    final result = await _repository.removeBookmark(id);
    result.fold(
      (failure) => emit(BookmarkError(failure.message)),
      (_) => emit(BookmarkRemoved()),
    );
  }
}