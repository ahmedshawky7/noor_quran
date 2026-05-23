import 'package:go_router/go_router.dart';
import 'package:noor_quran/features/splash/presentation/screen/splash_screen.dart';
import 'package:noor_quran/features/onboarding/presentation/screen/onboarding_screen.dart';
import 'package:noor_quran/features/home/presentation/screen/home_screen.dart';
import 'package:noor_quran/features/quran/presentation/screen/surah_list_screen.dart';
import 'package:noor_quran/features/quran/presentation/screen/surah_detail_screen.dart';
import 'package:noor_quran/features/bookmarks/presentation/screen/bookmarks_screen.dart';
// import 'package:noor_quran/features/search/presentation/screen/search_screen.dart';
import 'package:noor_quran/features/settings/presentation/screen/settings_screen.dart';
import 'package:noor_quran/features/ai_assistant/presentation/screen/ai_assistant_screen.dart';
import 'package:noor_quran/features/azkar/presentation/screen/azkar_screen.dart';
import 'package:noor_quran/features/hadith/presentation/screen/hadith_screen.dart';
import 'package:noor_quran/features/khatma/presentation/screen/khatma_screen.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: '/splash',

    routes: [
      GoRoute(
        path: '/splash',

        builder: (context, state) => const SplashScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return HomeScreen(child: child);
        },

        routes: [
          GoRoute(
            path: '/',

            builder: (context, state) => const SurahListScreen(),
          ),

          GoRoute(
            path: '/bookmarks',

            builder: (context, state) => const BookmarksScreen(),
          ),

          GoRoute(
            path: '/azkar',

            builder: (context, state) => const AzkarScreen(),
          ),

          GoRoute(
            path: '/hadith',

            builder: (context, state) => const HadithScreen(),
          ),

          GoRoute(
            path: '/khatma',

            builder: (context, state) => const KhatmaScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/quran/:surahId',

        builder: (context, state) {
          final id = int.parse(state.pathParameters['surahId']!);

          return SurahDetailScreen(surahId: id);
        },
      ),

      GoRoute(
        path: '/ai-assistant',

        builder: (context, state) => const AIAssistantScreen(),
      ),
    ],
  );
}
