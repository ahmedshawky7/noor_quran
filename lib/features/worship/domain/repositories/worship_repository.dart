import '../entities/device_location.dart';
import '../entities/worship_snapshot.dart';

abstract interface class WorshipRepository {
  WorshipSnapshot calculate({
    required DeviceLocation location,
    required DateTime now,
  });
}
