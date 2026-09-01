class NotificationSettings {
  const NotificationSettings({
    this.fajr = true,
    this.sunrise = false,
    this.dhuhr = true,
    this.asr = true,
    this.maghrib = true,
    this.isha = true,
    this.morningAdhkar = true,
    this.eveningAdhkar = true,
    this.beforePrayer = false,
    this.fajrMinutes = 0,
    this.sunriseMinutes = 0,
    this.dhuhrMinutes = 0,
    this.asrMinutes = 0,
    this.maghribMinutes = 0,
    this.ishaMinutes = 0,
    this.fajrSilent = false,
    this.sunriseSilent = false,
    this.dhuhrSilent = false,
    this.asrSilent = false,
    this.maghribSilent = false,
    this.ishaSilent = false,
  });

  final bool fajr;
  final bool sunrise;
  final bool dhuhr;
  final bool asr;
  final bool maghrib;
  final bool isha;
  final bool morningAdhkar;
  final bool eveningAdhkar;
  final bool beforePrayer;
  final int fajrMinutes;
  final int sunriseMinutes;
  final int dhuhrMinutes;
  final int asrMinutes;
  final int maghribMinutes;
  final int ishaMinutes;
  final bool fajrSilent;
  final bool sunriseSilent;
  final bool dhuhrSilent;
  final bool asrSilent;
  final bool maghribSilent;
  final bool ishaSilent;

  NotificationSettings copyWith({
    bool? fajr,
    bool? sunrise,
    bool? dhuhr,
    bool? asr,
    bool? maghrib,
    bool? isha,
    bool? morningAdhkar,
    bool? eveningAdhkar,
    bool? beforePrayer,
    int? fajrMinutes,
    int? sunriseMinutes,
    int? dhuhrMinutes,
    int? asrMinutes,
    int? maghribMinutes,
    int? ishaMinutes,
    bool? fajrSilent,
    bool? sunriseSilent,
    bool? dhuhrSilent,
    bool? asrSilent,
    bool? maghribSilent,
    bool? ishaSilent,
  }) {
    return NotificationSettings(
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      morningAdhkar: morningAdhkar ?? this.morningAdhkar,
      eveningAdhkar: eveningAdhkar ?? this.eveningAdhkar,
      beforePrayer: beforePrayer ?? this.beforePrayer,
      fajrMinutes: fajrMinutes ?? this.fajrMinutes,
      sunriseMinutes: sunriseMinutes ?? this.sunriseMinutes,
      dhuhrMinutes: dhuhrMinutes ?? this.dhuhrMinutes,
      asrMinutes: asrMinutes ?? this.asrMinutes,
      maghribMinutes: maghribMinutes ?? this.maghribMinutes,
      ishaMinutes: ishaMinutes ?? this.ishaMinutes,
      fajrSilent: fajrSilent ?? this.fajrSilent,
      sunriseSilent: sunriseSilent ?? this.sunriseSilent,
      dhuhrSilent: dhuhrSilent ?? this.dhuhrSilent,
      asrSilent: asrSilent ?? this.asrSilent,
      maghribSilent: maghribSilent ?? this.maghribSilent,
      ishaSilent: ishaSilent ?? this.ishaSilent,
    );
  }
}
