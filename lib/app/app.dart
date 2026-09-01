import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/adhkar/presentation/adhkar_page.dart';
import '../core/widgets/qalam_bottom_navigation.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/mushaf/presentation/mushaf_controller.dart';
import '../features/mushaf/presentation/mushaf_page.dart';
import '../features/mushaf/presentation/surah_list_page.dart';
import '../features/prayer/presentation/prayer_page.dart';
import '../features/qibla/presentation/qibla_page.dart';
import '../features/settings/data/shared_preferences_adhan_audio_repository.dart';
import '../features/settings/data/shared_preferences_notification_settings_repository.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/settings/presentation/adhan_audio_settings_page.dart';
import '../features/tafsir/domain/entities/tafsir_entry.dart';
import '../features/worship/presentation/worship_controller.dart';
import 'app_dependencies.dart';

class QalamApp extends StatelessWidget {
  const QalamApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'القلم',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: QalamShell(
        mushafController: dependencies.mushafController,
        worshipController: dependencies.worshipController,
        notificationSettingsRepository: dependencies.notificationSettingsRepository,
        adhanAudioRepository: dependencies.adhanAudioRepository,
        tafsirRepository: dependencies.tafsirRepository,
      ),
    );
  }
}

class QalamShell extends StatefulWidget {
  const QalamShell({
    super.key,
    required this.mushafController,
    required this.worshipController,
    required this.notificationSettingsRepository,
    required this.adhanAudioRepository,
    required this.tafsirRepository,
  });

  final MushafController mushafController;
  final WorshipController worshipController;
  final SharedPreferencesNotificationSettingsRepository notificationSettingsRepository;
  final SharedPreferencesAdhanAudioRepository adhanAudioRepository;
  final LocalTafsirRepository tafsirRepository;

  @override
  State<QalamShell> createState() => _QalamShellState();
}

class _QalamShellState extends State<QalamShell> {
  int _currentIndex = 0;
  bool _isMushafOpen = false;

  @override
  void initState() {
    super.initState();
    widget.worshipController.initialize();
  }

  void _openMushaf() => setState(() {
        _currentIndex = 2;
        _isMushafOpen = true;
      });

  void _openSurahList() => setState(() {
        _currentIndex = 2;
        _isMushafOpen = false;
      });

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 2) _isMushafOpen = false;
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SettingsPage(
              mushafController: widget.mushafController,
              worshipController: widget.worshipController,
              notificationSettingsRepository: widget.notificationSettingsRepository,
              adhanAudioRepository: widget.adhanAudioRepository,
            ),
          ),
        ),
      ),
    );
  }

  void _openAdhanSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: AdhanAudioSettingsPage(repository: widget.adhanAudioRepository),
          ),
        ),
      ),
    );
  }

  void _openQibla() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: QiblaPage(
              worshipController: widget.worshipController,
              onExit: () => Navigator.of(routeContext).pop(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.mushafController.dispose();
    widget.worshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardPage(
        onContinueReading: _openMushaf,
        onOpenQibla: _openQibla,
        onOpenSettings: _openSettings,
        worshipController: widget.worshipController,
        mushafController: widget.mushafController,
      ),
      PrayerPage(
        worshipController: widget.worshipController,
        onOpenQibla: _openQibla,
        onOpenSettings: _openSettings,
        onOpenAdhanSettings: _openAdhanSettings,
        notificationRepository: widget.notificationSettingsRepository,
        adhanRepository: widget.adhanAudioRepository,
      ),
      _isMushafOpen
          ? MushafPage(
              controller: widget.mushafController,
              tafsirRepository: widget.tafsirRepository,
              onExit: _openSurahList,
            )
          : SurahListPage(
              controller: widget.mushafController,
                            onOpenMushaf: _openMushaf,
              onOpenQibla: _openQibla,
              onOpenSettings: _openSettings,
            )
,
      AdhkarPage(onOpenQibla: _openQibla, onOpenSettings: _openSettings),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: !_isMushafOpen,
        body: IndexedStack(index: _currentIndex, children: pages),
        bottomNavigationBar: _isMushafOpen
            ? null
            : QalamBottomNavigation(
                currentIndex: _currentIndex,
                onChanged: _onTabChanged,
              ),
      ),
    );
  }
}
