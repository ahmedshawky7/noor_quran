import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/entities/device_location.dart';
import '../domain/entities/location_settings.dart';
import '../domain/entities/worship_snapshot.dart';
import '../domain/repositories/location_repository.dart';
import '../data/repositories/shared_preferences_location_settings_repository.dart';
import '../domain/repositories/worship_repository.dart';

class WorshipController extends ChangeNotifier {
  WorshipController({
    required LocationRepository locationRepository,
    required WorshipRepository worshipRepository,
    required LocationSettingsRepository locationSettingsRepository,
  })  : _locationRepository = locationRepository,
        _worshipRepository = worshipRepository,
        _locationSettingsRepository = locationSettingsRepository;

  final LocationRepository _locationRepository;
  final WorshipRepository _worshipRepository;
  final LocationSettingsRepository _locationSettingsRepository;

  WorshipSnapshot? _snapshot;
  LocationSettings _locationSettings = const LocationSettings();
  String? _errorMessage;
  bool _isLoading = false;
  String _locationLabel = 'موقعك الحالي';
  Timer? _clock;

  WorshipSnapshot? get snapshot => _snapshot;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get hasData => _snapshot != null;
  LocationSettings get locationSettings => _locationSettings;
  String get locationLabel => _locationLabel;

  /// يعيد مواقيت يوم محدد بنفس الموقع الحالي، من دون تغيير بيانات اليوم الحالي
  /// أو إعادة جدولة التنبيهات.
  WorshipSnapshot? snapshotForDate(DateTime date) {
    final current = _snapshot;
    if (current == null) return null;
    final requestedDay = DateTime(date.year, date.month, date.day);
    final currentDay = DateTime(
      current.capturedAt.year,
      current.capturedAt.month,
      current.capturedAt.day,
    );
    if (requestedDay == currentDay) return current;
    return _worshipRepository.calculate(
      location: current.location,
      now: requestedDay,
    );
  }

  Future<void> initialize() async {
    _locationSettings = await _locationSettingsRepository.getSettings();
    await refreshLocation();
  }

  Future<void> refreshLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final isManual = _locationSettings.mode == LocationMode.manual;
      final location = isManual
          ? DeviceLocation(
              latitude: _locationSettings.manualLatitude,
              longitude: _locationSettings.manualLongitude,
              accuracyMeters: 0,
            )
          : await _locationRepository.getCurrentLocation().timeout(
              const Duration(seconds: 15),
              onTimeout: () => throw const LocationFailure(
                'لم يستجب GPS خلال المهلة. اضبط موقع المحاكي أو اختر مدينة يدوياً من إعدادات الموقع.',
              ),
            );
      _locationLabel = isManual && _locationSettings.manualLabel.trim().isNotEmpty
          ? _locationSettings.manualLabel
          : 'موقعك الحالي';
      _snapshot = _worshipRepository.calculate(location: location, now: DateTime.now());
      _startClock();
    } on LocationFailure catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'تعذر تحديث بيانات العبادة حالياً. أعد المحاولة لاحقاً.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLocationMode(LocationMode mode) async {
    _locationSettings = _locationSettings.copyWith(mode: mode);
    await _locationSettingsRepository.save(_locationSettings);
    await refreshLocation();
  }

  Future<void> setManualLocation({required String label, required double latitude, required double longitude}) async {
    _locationSettings = _locationSettings.copyWith(
      mode: LocationMode.manual,
      manualLabel: label.trim().isEmpty ? 'الموقع اليدوي' : label.trim(),
      manualLatitude: latitude,
      manualLongitude: longitude,
    );
    await _locationSettingsRepository.save(_locationSettings);
    await refreshLocation();
  }


  void _startClock() {
    _clock ??= Timer.periodic(const Duration(seconds: 1), (_) {
      final previous = _snapshot;
      if (previous == null) return;
      _snapshot = _worshipRepository.calculate(
        location: previous.location,
        now: DateTime.now(),
      );
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }
}
