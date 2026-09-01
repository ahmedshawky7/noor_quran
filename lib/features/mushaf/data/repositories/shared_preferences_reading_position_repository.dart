import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/ayah_ref.dart';
import '../../domain/entities/reading_position.dart';
import '../../domain/repositories/reading_position_repository.dart';

class SharedPreferencesReadingPositionRepository
    implements ReadingPositionRepository {
  SharedPreferencesReadingPositionRepository(this._preferences);

  static const _pageKey = 'mushaf_last_page';
  static const _surahKey = 'mushaf_last_surah';
  static const _ayahKey = 'mushaf_last_ayah';
  static const _updatedAtKey = 'mushaf_last_updated_at';
  static const _bookmarkPageKey = 'mushaf_bookmark_page';
  static const _bookmarkSurahKey = 'mushaf_bookmark_surah';
  static const _bookmarkAyahKey = 'mushaf_bookmark_ayah';
  static const _bookmarkUpdatedAtKey = 'mushaf_bookmark_updated_at';

  final SharedPreferences _preferences;

  @override
  Future<ReadingPosition?> getLastPosition() async {
    final page = _preferences.getInt(_pageKey);
    if (page == null) return null;

    final surah = _preferences.getInt(_surahKey);
    final ayah = _preferences.getInt(_ayahKey);
    final timestamp = _preferences.getInt(_updatedAtKey);
    final anchor = surah != null && ayah != null
        ? AyahRef(surahNumber: surah, ayahNumber: ayah, pageNumber: page)
        : null;

    return ReadingPosition(
      pageNumber: page,
      anchorAyah: anchor,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp ?? 0),
    );
  }

  @override
  Future<void> save(ReadingPosition position) async {
    await _preferences.setInt(_pageKey, position.pageNumber);
    await _preferences.setInt(_updatedAtKey, position.updatedAt.millisecondsSinceEpoch);
    final anchor = position.anchorAyah;
    if (anchor != null) {
      await _preferences.setInt(_surahKey, anchor.surahNumber);
      await _preferences.setInt(_ayahKey, anchor.ayahNumber);
    }
  }

  @override
  Future<ReadingPosition?> getBookmark() async {
    final page = _preferences.getInt(_bookmarkPageKey);
    if (page == null) return null;
    final surah = _preferences.getInt(_bookmarkSurahKey);
    final ayah = _preferences.getInt(_bookmarkAyahKey);
    final timestamp = _preferences.getInt(_bookmarkUpdatedAtKey);
    return ReadingPosition(
      pageNumber: page,
      anchorAyah: surah != null && ayah != null
          ? AyahRef(surahNumber: surah, ayahNumber: ayah, pageNumber: page)
          : null,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp ?? 0),
    );
  }

  @override
  Future<void> saveBookmark(ReadingPosition position) async {
    await _preferences.setInt(_bookmarkPageKey, position.pageNumber);
    await _preferences.setInt(
      _bookmarkUpdatedAtKey,
      position.updatedAt.millisecondsSinceEpoch,
    );
    final anchor = position.anchorAyah;
    if (anchor != null) {
      await _preferences.setInt(_bookmarkSurahKey, anchor.surahNumber);
      await _preferences.setInt(_bookmarkAyahKey, anchor.ayahNumber);
    }
  }

  @override
  Future<void> clearBookmark() async {
    await _preferences.remove(_bookmarkPageKey);
    await _preferences.remove(_bookmarkSurahKey);
    await _preferences.remove(_bookmarkAyahKey);
    await _preferences.remove(_bookmarkUpdatedAtKey);
  }
}
