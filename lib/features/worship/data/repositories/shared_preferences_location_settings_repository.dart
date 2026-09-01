import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/location_settings.dart';

abstract interface class LocationSettingsRepository {
  Future<LocationSettings> getSettings();
  Future<void> save(LocationSettings settings);
}

class SharedPreferencesLocationSettingsRepository implements LocationSettingsRepository {
  const SharedPreferencesLocationSettingsRepository(this._preferences);

  static const _modeKey = 'location_mode';
  static const _labelKey = 'manual_location_label';
  static const _latitudeKey = 'manual_location_latitude';
  static const _longitudeKey = 'manual_location_longitude';

  final SharedPreferences _preferences;

  @override
  Future<LocationSettings> getSettings() async {
    final modeIndex = _preferences.getInt(_modeKey) ?? LocationMode.automatic.index;
    return LocationSettings(
      mode: LocationMode.values.elementAt(modeIndex.clamp(0, LocationMode.values.length - 1).toInt()),
      manualLabel: _preferences.getString(_labelKey) ?? 'الموقع اليدوي',
      manualLatitude: _preferences.getDouble(_latitudeKey) ?? 30.0444,
      manualLongitude: _preferences.getDouble(_longitudeKey) ?? 31.2357,
    );
  }

  @override
  Future<void> save(LocationSettings settings) async {
    await _preferences.setInt(_modeKey, settings.mode.index);
    await _preferences.setString(_labelKey, settings.manualLabel);
    await _preferences.setDouble(_latitudeKey, settings.manualLatitude);
    await _preferences.setDouble(_longitudeKey, settings.manualLongitude);
  }
}
