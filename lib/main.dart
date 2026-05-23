import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
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

  await configureDependencies(); // ← DI بس

  runApp(const NoorQuranApp());
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