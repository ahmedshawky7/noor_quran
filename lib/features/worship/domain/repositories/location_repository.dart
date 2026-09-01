import '../entities/device_location.dart';

abstract interface class LocationRepository {
  Future<DeviceLocation> getCurrentLocation();
}

class LocationFailure implements Exception {
  const LocationFailure(this.message);
  final String message;

  @override
  String toString() => message;
}
