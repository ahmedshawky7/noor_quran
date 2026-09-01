import 'package:shared_preferences/shared_preferences.dart';

import '../features/mushaf/data/repositories/just_audio_quran_repository.dart';
import '../features/mushaf/data/repositories/qcf_mushaf_repository.dart';
import '../features/mushaf/data/repositories/shared_preferences_reading_position_repository.dart';
import '../features/mushaf/presentation/mushaf_controller.dart';
import '../features/settings/data/shared_preferences_adhan_audio_repository.dart';
import '../features/tafsir/domain/entities/tafsir_entry.dart';
import '../features/settings/data/shared_preferences_notification_settings_repository.dart';
import '../features/worship/data/repositories/geolocator_location_repository.dart';
import '../features/worship/data/repositories/local_worship_repository.dart';
import '../features/worship/data/repositories/shared_preferences_location_settings_repository.dart';
import '../features/worship/presentation/worship_controller.dart';

class AppDependencies {
  AppDependencies._({
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

  static Future<AppDependencies> create() async {
    final preferences = await SharedPreferences.getInstance();
    final mushafRepository = QcfMushafRepository();
    final audioRepository = JustAudioQuranRepository(
      preferences: preferences,
      mushafRepository: mushafRepository,
    );
    await audioRepository.initialize();
    final positionRepository =
        SharedPreferencesReadingPositionRepository(preferences);
    final locationSettingsRepository =
        SharedPreferencesLocationSettingsRepository(preferences);
    final notificationSettingsRepository =
        SharedPreferencesNotificationSettingsRepository(preferences);
    final adhanAudioRepository =
        SharedPreferencesAdhanAudioRepository(preferences);
    final tafsirRepository = LocalTafsirRepository();
    await tafsirRepository.initialize();

    final mushafController = MushafController(
      mushafRepository: mushafRepository,
      audioRepository: audioRepository,
      positionRepository: positionRepository,
    );
    await mushafController.initialize();

    final worshipController = WorshipController(
      locationRepository: GeolocatorLocationRepository(),
      worshipRepository: LocalWorshipRepository(
        mushafRepository: mushafRepository,
      ),
      locationSettingsRepository: locationSettingsRepository,
    );

    return AppDependencies._(
      mushafController: mushafController,
      worshipController: worshipController,
      notificationSettingsRepository: notificationSettingsRepository,
      adhanAudioRepository: adhanAudioRepository,
      tafsirRepository: tafsirRepository,
    );
  }
}
