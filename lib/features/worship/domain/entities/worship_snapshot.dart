import 'daily_ayah.dart';
import 'device_location.dart';
import 'prayer_moment.dart';

class WorshipSnapshot {
  const WorshipSnapshot({
    required this.capturedAt,
    required this.location,
    required this.gregorianDateLabel,
    required this.hijriDateLabel,
    required this.prayerSchedule,
    required this.nextPrayer,
    required this.qiblaBearingDegrees,
    required this.distanceToMakkahKm,
    required this.dailyAyah,
  });

  final DateTime capturedAt;
  final DeviceLocation location;
  final String gregorianDateLabel;
  final String hijriDateLabel;
  final List<PrayerMoment> prayerSchedule;
  final PrayerMoment nextPrayer;
  final double qiblaBearingDegrees;
  final double distanceToMakkahKm;
  final DailyAyah dailyAyah;

  Duration get remainingToNextPrayer {
    final duration = nextPrayer.at.difference(capturedAt);
    return duration.isNegative ? Duration.zero : duration;
  }
}
