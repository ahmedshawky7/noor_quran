import 'package:equatable/equatable.dart';
import 'package:noor_quran/features/bookmarks/domain/entities/bookmark.dart';

abstract class BookmarkState extends Equatable {
  const BookmarkState();
  
  @override
  List<Object?> get props => [];
}

class BookmarkInitial extends BookmarkState {}

class BookmarkLoading extends BookmarkState {}

class BookmarksLoaded extends BookmarkState {
  final List<Bookmark> bookmarks;
  const BookmarksLoaded(this.bookmarks);
  
  @override
  List<Object?> get props => [bookmarks];
}

class BookmarkAdded extends BookmarkState {}

class BookmarkRemoved extends BookmarkState {}

class BookmarkError extends BookmarkState {
  final String message;
  const BookmarkError(this.message);
  
  @override
  List<Object?> get props => [message];
}