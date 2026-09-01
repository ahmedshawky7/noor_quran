enum PrayerState { completed, upcoming, current }

class PrayerTime {
  const PrayerTime({
    required this.name,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.state,
  });

  final String name;
  final String subtitle;
  final String time;
  final String icon;
  final PrayerState state;
}
