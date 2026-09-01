import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../domain/entities/device_location.dart';
import '../../domain/repositories/location_repository.dart';

class GeolocatorLocationRepository implements LocationRepository {
  static const _locationTimeout = Duration(seconds: 12);

  @override
  Future<DeviceLocation> getCurrentLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationFailure('خدمات الموقع متوقفة. فعّلها ثم أعد المحاولة.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationFailure('لم يتم منح إذن الموقع، لذلك لا يمكن حساب المواقيت والقبلة بدقة.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure('إذن الموقع مرفوض بشكل دائم. فعّله من إعدادات الجهاز ثم أعد المحاولة.');
    }

    try {
      // المهلة هنا صريحة أيضاً، حتى لا يبقى المحاكي في حالة تحميل مفتوحة.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: _locationTimeout,
        ),
      ).timeout(_locationTimeout);
      return _fromPosition(position);
    } on TimeoutException {
      final fallback = await _lastKnownLocation();
      if (fallback != null) return fallback;
      throw const LocationFailure(
        'انتهت مهلة قراءة الموقع. في المحاكي اختر نقطة من Extended controls > Location ثم اضغط Set location، وبعدها أعد المحاولة.',
      );
    } catch (_) {
      final fallback = await _lastKnownLocation();
      if (fallback != null) return fallback;
      throw const LocationFailure(
        'تعذر الحصول على موقع دقيق حالياً. تأكد من إذن الموقع ومن تعيين نقطة في المحاكي ثم أعد المحاولة.',
      );
    }
  }

  Future<DeviceLocation?> _lastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      return position == null ? null : _fromPosition(position);
    } catch (_) {
      return null;
    }
  }

  DeviceLocation _fromPosition(Position position) {
    return DeviceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
    );
  }
}
