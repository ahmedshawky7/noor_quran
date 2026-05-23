import 'package:noor_quran/core/constants/app_constants.dart';
import 'package:noor_quran/core/di/injection.dart';
import 'package:noor_quran/core/services/initial_data_service.dart';
import 'package:noor_quran/core/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String databaseInitialized = 'database_initialized';
  static bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final initialized = prefs.getBool(databaseInitialized) ?? false;

    if (!initialized) {
      await _performInitialSetup(prefs);
    }

    // ◄◄◄ نأجل SyncService لحد ما الـ DB يكون جاهز تماماً
    // getIt<SyncService>().startPeriodicSync();

    _isInitialized = true;
  }

  Future<void> _performInitialSetup(SharedPreferences prefs) async {
    final initialDataService = getIt<InitialDataService>();

    try {
      final alreadyLoaded = await initialDataService.isDataAlreadyLoaded();
      if (alreadyLoaded) {
        await prefs.setBool(databaseInitialized, true);
        return;
      }

      await initialDataService.loadInitialData();
      await prefs.setBool(databaseInitialized, true);
    } catch (e) {
      print('❌ Initial setup error: $e');
    }
  }

  // ◄◄◄ دالة منفصلة للـ SyncService
  void startSync() {
    getIt<SyncService>().startPeriodicSync();
  }
}