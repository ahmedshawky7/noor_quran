import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_quran/features/bookmarks/presentation/cubit/bookmark_cubit.dart';
import 'package:noor_quran/features/bookmarks/presentation/cubit/bookmark_state.dart';
import 'package:noor_quran/core/widgets/loading_widget.dart';
import 'package:noor_quran/features/quran/presentation/widgets/ayah_card.dart';
import 'package:noor_quran/features/quran/domain/repositories/quran_repository.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: BlocProvider(
        create: (context) => context.read<BookmarkCubit>()..loadBookmarks(),
        child: BlocBuilder<BookmarkCubit, BookmarkState>(
          builder: (context, state) {
            if (state is BookmarkLoading) {
              return const LoadingWidget();
            } else if (state is BookmarksLoaded) {
              if (state.bookmarks.isEmpty) {
                return const Center(child: Text('No bookmarks yet'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.bookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = state.bookmarks[index];
                  return FutureBuilder(
                    future: context.read<QuranRepository>().getAyah(
                      bookmark.surahId,
                      bookmark.ayahNumber,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const SizedBox();
                      }

                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }

                      final result = snapshot.data!;

                      return result.fold(
                        (failure) => ListTile(title: Text(failure.message)),
                        (ayah) => AyahCard(
                          ayah: ayah,
                          surahName: '',
                          onBookmarkPressed: () {
                            context.read<BookmarkCubit>().removeBookmark(
                              bookmark.id,
                            );
                          },
                          onTafsirPressed: () {},
                          onAISexplainPressed: () {},
                          onSharePressed: () {},
                          onCopyPressed: () {},
                        ),
                      );
                    },
                  );
                },
              );
            } else if (state is BookmarkError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
