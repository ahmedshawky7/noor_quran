import 'dart:async';
import 'package:noor_quran/core/constants/app_constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;
  static Completer<Database>? _completer;

  Future<Database> get database async {
    // ◄◄◄ لو الـ DB مفتوح وشغال، رجعه على طول
    if (_database != null) {
      try {
        await _database!.rawQuery('SELECT 1');
        return _database!;
      } catch (_) {
        _database = null;
        _completer = null;
      }
    }

    // ◄◄◄ لو فيه حد بيفتحه دلوقتي، استنى
    if (_completer != null) {
      return await _completer!.future;
    }

    // ◄◄◄ افتح الـ DB مرة واحدة بس
    _completer = Completer<Database>();
    _database = await _initDatabase();
    _completer!.complete(_database);

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      // ◄◄◄ مهم جداً: instance واحد بس
      singleInstance: true,

      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onOpen: (db) async {
        // ◄◄◄ نستخدم rawQuery عشان PRAGMA
        await db.rawQuery('PRAGMA journal_mode = WAL');
      },

      onCreate: (db, version) async {
        await _createTables(db);
        await _createIndexes(db);
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        await _handleMigrations(db, oldVersion, newVersion);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE surahs (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        name_arabic TEXT NOT NULL,
        english_name TEXT NOT NULL,
        revelation_type TEXT NOT NULL,
        total_ayahs INTEGER NOT NULL,
        page INTEGER NOT NULL,
        juz_list TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ayahs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_id INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        text_uthmani TEXT NOT NULL,
        text_simple TEXT NOT NULL,
        juz INTEGER NOT NULL,
        hizb INTEGER DEFAULT 0,
        hizb_quarter INTEGER DEFAULT 0,
        page INTEGER NOT NULL,
        sajda INTEGER DEFAULT 0,
        UNIQUE(surah_id, ayah_number),
        FOREIGN KEY (surah_id) REFERENCES surahs(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tafsir (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_id INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        source TEXT DEFAULT 'default',
        text_arabic TEXT NOT NULL,
        text_english TEXT,
        FOREIGN KEY (surah_id) REFERENCES surahs(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_id INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        note TEXT,
        folder_name TEXT DEFAULT 'Default',
        created_at INTEGER NOT NULL,
        FOREIGN KEY (surah_id) REFERENCES surahs(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE last_read (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_id INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        page_number INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (surah_id) REFERENCES surahs(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE hadith (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        collection TEXT NOT NULL,
        category TEXT,
        book_number INTEGER,
        hadith_number INTEGER,
        text_arabic TEXT,
        text_english TEXT NOT NULL,
        narrator TEXT,
        grade TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE azkar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        text_arabic TEXT NOT NULL,
        text_english TEXT,
        translation TEXT,
        count INTEGER DEFAULT 1,
        reference TEXT,
        favorite INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute('CREATE INDEX idx_ayahs_surah ON ayahs(surah_id)');
    await db.execute(
      'CREATE INDEX idx_bookmarks ON bookmarks(surah_id, ayah_number)',
    );
  }

  Future<void> _handleMigrations(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {}

  Future<void> deleteDatabaseFile() async {
    final path = join(await getDatabasesPath(), AppConstants.dbName);
    await deleteDatabase(path);
    _database = null;
    _completer = null;
  }
}