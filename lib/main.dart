import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Hive Models & Adapters
import 'package:noor_quran/features/ai_assistant/data/models/chat_message.dart';
import 'package:noor_quran/features/ai_assistant/data/models/chat_session.dart';

import 'package:noor_quran/features/ai_assistant/data/datasources/chat_storage.dart';
import 'package:noor_quran/features/ai_assistant/presentation/cubit/ai_assistant_cubit.dart';
import 'core/di/injection.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/localization/app_localizations.dart';

import 'features/audio/presentation/cubit/audio_cubit.dart';
import 'features/bookmarks/presentation/cubit/bookmark_cubit.dart';
import 'features/khatma/presentation/cubit/khatma_cubit.dart';
import 'features/quran/presentation/cubit/ayah_cubit.dart';
import 'features/quran/presentation/cubit/surah_cubit.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await _initHive();
  await configureDependencies();

  runApp(const NoorQuranApp());
}

Future<void> _initHive() async {
  await Hive.initFlutter();

  // تسجيل الـ Adapters
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(ChatSessionAdapter());

  await ChatStorage().init();
}

class NoorQuranApp extends StatelessWidget {
  const NoorQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<SurahCubit>()),
        BlocProvider(create: (_) => getIt<AyahCubit>()),
        BlocProvider(create: (_) => getIt<BookmarkCubit>()),
        BlocProvider(create: (_) => getIt<KhatmaCubit>()),
        BlocProvider(create: (_) => getIt<SettingsCubit>()),
        BlocProvider(create: (_) => getIt<AudioCubit>()),
        BlocProvider(create: (_) => getIt<AIAssistantCubit>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Noor Quran',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: getIt<AppRouter>().router,
      ),
    );
  }
}