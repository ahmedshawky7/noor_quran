class AppConstants {
  static const String appName = 'Noor Quran';
  static const String packageName = 'com.noor.quran';
  
  // Database
  static const String dbName = 'noor_quran.db';
  static const int dbVersion = 1;
  
  // Pref keys
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
  static const String lastReadSurah = 'last_read_surah';
  static const String lastReadAyah = 'last_read_ayah';
  static const String databaseInitialized = 'database_initialized';
  static const String quranVersion = 'quran_version';
  
  // Audio
  static const String reciterId = 'ar.alafasy';
  static const String audioBaseUrl = 'https://cdn.islamic.network/quran/audio/128/';
  
  // AI
  static const String geminiApiKey = 'AIzaSyAhGJMfYZpWZdzm0Q6lr3yAJn2Q5lXviig'; // Move to secure config
}