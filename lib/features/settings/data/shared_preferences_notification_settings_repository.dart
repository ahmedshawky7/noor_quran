import 'package:shared_preferences/shared_preferences.dart';

import '../domain/notification_settings.dart';

class SharedPreferencesNotificationSettingsRepository {
  const SharedPreferencesNotificationSettingsRepository(this._preferences);

  static const _prefix = 'notification_';
  final SharedPreferences _preferences;

  NotificationSettings load() {
    return NotificationSettings(
      fajr: _read('fajr', true),
      sunrise: _read('sunrise', false),
      dhuhr: _read('dhuhr', true),
      asr: _read('asr', true),
      maghrib: _read('maghrib', true),
      isha: _read('isha', true),
      morningAdhkar: _read('morning_adhkar', true),
      eveningAdhkar: _read('evening_adhkar', true),
      beforePrayer: _read('before_prayer', false),
      fajrMinutes: _readInt('fajr_minutes', 0),
      sunriseMinutes: _readInt('sunrise_minutes', 0),
      dhuhrMinutes: _readInt('dhuhr_minutes', 0),
      asrMinutes: _readInt('asr_minutes', 0),
      maghribMinutes: _readInt('maghrib_minutes', 0),
      ishaMinutes: _readInt('isha_minutes', 0),
      fajrSilent: _read('fajr_silent', false),
      sunriseSilent: _read('sunrise_silent', false),
      dhuhrSilent: _read('dhuhr_silent', false),
      asrSilent: _read('asr_silent', false),
      maghribSilent: _read('maghrib_silent', false),
      ishaSilent: _read('isha_silent', false),
    );
  }

  Future<void> save(NotificationSettings settings) async {
    await Future.wait([
      _preferences.setBool('${_prefix}fajr', settings.fajr),
      _preferences.setBool('${_prefix}sunrise', settings.sunrise),
      _preferences.setBool('${_prefix}dhuhr', settings.dhuhr),
      _preferences.setBool('${_prefix}asr', settings.asr),
      _preferences.setBool('${_prefix}maghrib', settings.maghrib),
      _preferences.setBool('${_prefix}isha', settings.isha),
      _preferences.setBool('${_prefix}morning_adhkar', settings.morningAdhkar),
      _preferences.setBool('${_prefix}evening_adhkar', settings.eveningAdhkar),
      _preferences.setBool('${_prefix}before_prayer', settings.beforePrayer),
      _preferences.setInt('${_prefix}fajr_minutes', settings.fajrMinutes),
      _preferences.setInt('${_prefix}sunrise_minutes', settings.sunriseMinutes),
      _preferences.setInt('${_prefix}dhuhr_minutes', settings.dhuhrMinutes),
      _preferences.setInt('${_prefix}asr_minutes', settings.asrMinutes),
      _preferences.setInt('${_prefix}maghrib_minutes', settings.maghribMinutes),
      _preferences.setInt('${_prefix}isha_minutes', settings.ishaMinutes),
      _preferences.setBool('${_prefix}fajr_silent', settings.fajrSilent),
      _preferences.setBool('${_prefix}sunrise_silent', settings.sunriseSilent),
      _preferences.setBool('${_prefix}dhuhr_silent', settings.dhuhrSilent),
      _preferences.setBool('${_prefix}asr_silent', settings.asrSilent),
      _preferences.setBool('${_prefix}maghrib_silent', settings.maghribSilent),
      _preferences.setBool('${_prefix}isha_silent', settings.ishaSilent),
    ]);
  }

  bool _read(String name, bool fallback) => _preferences.getBool('$_prefix$name') ?? fallback;
  int _readInt(String name, int fallback) => _preferences.getInt('$_prefix$name') ?? fallback;
}
