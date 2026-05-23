import 'dart:developer';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../database/dao/azkar_dao.dart';
import '../database/dao/bookmark_dao.dart';
import '../database/dao/hadith_dao.dart';
import '../database/dao/khatma_dao.dart';
import '../database/dao/last_read_dao.dart';
import '../database/dao/quran_dao.dart';
import '../database/database_helper.dart';
import '../network/network_info.dart';
import '../routing/app_router.dart';
import '../services/initial_data_service.dart';
import '../services/quran_api_service.dart';
import '../services/sync_service.dart';

import '../../features/quran/data/repositories/quran_repository_impl.dart';
import '../../features/quran/domain/repositories/quran_repository.dart';

import '../../features/bookmarks/data/repositories/bookmark_repository_impl.dart';
import '../../features/bookmarks/domain/repositories/bookmark_repository.dart';
import '../../features/bookmarks/presentation/cubit/bookmark_cubit.dart';

import '../../features/khatma/data/repositories/khatma_repository_impl.dart';
import '../../features/khatma/domain/repositories/khatma_repository.dart';
import '../../features/khatma/presentation/cubit/khatma_cubit.dart';

import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/audio/presentation/cubit/audio_cubit.dart';
import '../../features/audio/data/repositories/audio_repository_impl.dart';  // ✅ جديد
import '../../features/ai_assistant/presentation/cubit/ai_assistant_cubit.dart';

import '../../features/quran/presentation/cubit/surah_cubit.dart';
import '../../features/quran/presentation/cubit/ayah_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<String>(instanceName: 'DI_INITIALIZED')) return;

  getIt.registerSingleton<String>('done', instanceName: 'DI_INITIALIZED');

  log('🔧 DI START');

  // ===== CORE =====
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker.instance,
  );

  getIt.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(getIt()),
  );

  getIt.registerLazySingleton(() => DatabaseHelper());
  getIt.registerLazySingleton(() => QuranApiService());

  // Router
  getIt.registerLazySingleton(() => AppRouter());

  // ===== SERVICES =====
  getIt.registerLazySingleton<SyncService>(
      () => SyncService(getIt()),
  );

  getIt.registerLazySingleton<InitialDataService>(
      () => InitialDataService(
    getIt<DatabaseHelper>(),
    getIt<QuranApiService>(),
  ),
  );
  getIt.registerLazySingleton<AppConfig>(() => AppConfig());
  // ===== DAOs =====
  getIt.registerLazySingleton(() => QuranDao(getIt()));
  getIt.registerLazySingleton(() => BookmarkDao(getIt()));
  getIt.registerLazySingleton(() => LastReadDao(getIt()));
  getIt.registerLazySingleton(() => KhatmaDao(getIt()));
  getIt.registerLazySingleton(() => HadithDao(getIt()));
  getIt.registerLazySingleton(() => AzkarDao(getIt()));

  // ===== REPOS =====
  getIt.registerLazySingleton<QuranRepository>(
        () => QuranRepositoryImpl(getIt(), getIt()),
  );

  getIt.registerLazySingleton<BookmarkRepository>(
      () => BookmarkRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<KhatmaRepository>(
        () => KhatmaRepositoryImpl(getIt()),
  );

  // ✅ جديد: Audio Repository
  getIt.registerLazySingleton<AudioRepositoryImpl>(
      () => AudioRepositoryImpl(),
  );

  // ===== CUBITS =====
  getIt.registerFactory(() => SurahCubit(getIt()));
  getIt.registerFactory(() => AyahCubit(getIt()));
  getIt.registerFactory(() => BookmarkCubit(getIt()));
  getIt.registerFactory(() => KhatmaCubit(getIt()));
  getIt.registerFactory(() => SettingsCubit(getIt()));
  getIt.registerFactory(() => AudioCubit(getIt<AudioRepositoryImpl>()));  // ✅ عدل ده
  getIt.registerFactory(() => AIAssistantCubit(getIt()));

  log('✅ DI READY');
}