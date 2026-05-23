import 'package:sqflite/sqflite.dart';
import 'package:noor_quran/core/database/database_helper.dart';
import 'package:noor_quran/features/bookmarks/domain/entities/bookmark.dart';

class BookmarkDao {
  final DatabaseHelper _dbHelper;
  
  BookmarkDao(this._dbHelper);
  
  Future<Database> get _db async => await _dbHelper.database;
  
  Future<void> insertBookmark(Bookmark bookmark) async {
    final db = await _db;
    await db.insert('bookmarks', bookmark.toMap());
  }
  
  Future<void> deleteBookmark(int id) async {
    final db = await _db;
    await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }
  
  Future<List<Bookmark>> getAllBookmarks() async {
    final db = await _db;
    final result = await db.query('bookmarks', orderBy: 'created_at DESC');
    return result.map((map) => Bookmark.fromMap(map)).toList();
  }
  
  Future<Bookmark?> getBookmark(int surahId, int ayahNumber) async {
    final db = await _db;
    final result = await db.query(
      'bookmarks',
      where: 'surah_id = ? AND ayah_number = ?',
      whereArgs: [surahId, ayahNumber],
    );
    if (result.isNotEmpty) {
      return Bookmark.fromMap(result.first);
    }
    return null;
  }
  
  Future<void> updateBookmarkNote(int id, String note) async {
    final db = await _db;
    await db.update(
      'bookmarks',
      {'note': note},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}