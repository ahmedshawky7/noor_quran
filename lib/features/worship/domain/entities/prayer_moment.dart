enum PrayerKind { fajr, sunrise, dhuhr, asr, maghrib, isha }

class PrayerMoment {
  const PrayerMoment({
    required this.kind,
    required this.at,
  });

  final PrayerKind kind;
  final DateTime at;
}
