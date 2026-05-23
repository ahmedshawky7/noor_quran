import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noor_quran/core/constants/app_constants.dart';
import 'package:noor_quran/features/settings/presentation/cubit/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;
  
  SettingsCubit(this._prefs) : super(SettingsState.initial()) {
    _loadSettings();
  }
  
  void _loadSettings() {
    final themeIndex = _prefs.getInt(AppConstants.themeMode) ?? 0;
    final localeCode = _prefs.getString(AppConstants.locale) ?? 'en';
    emit(SettingsState(
      themeMode: ThemeMode.values[themeIndex],
      locale: Locale(localeCode),
    ));
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(AppConstants.themeMode, mode.index);
    emit(state.copyWith(themeMode: mode));
  }
  
  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(AppConstants.locale, locale.languageCode);
    emit(state.copyWith(locale: locale));
  }
}