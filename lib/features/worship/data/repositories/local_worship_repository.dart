import 'dart:math' as math;

import 'package:adhan_dart/adhan_dart.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../../mushaf/domain/entities/ayah_ref.dart';
import '../../../mushaf/domain/repositories/mushaf_repository.dart';
import '../../domain/entities/daily_ayah.dart';
import '../../domain/entities/device_location.dart';
import '../../domain/entities/prayer_moment.dart';
import '../../domain/entities/worship_snapshot.dart';
import '../../domain/repositories/worship_repository.dart';

/// حساب محلي فقط؛ لا يرسل الموقع إلى مزود مواقيت خارجي.
class LocalWorshipRepository implements WorshipRepository {
  LocalWorshipRepository({required MushafRepository mushafRepository})
      : _mushafRepository = mushafRepository;

  static const _makkahLatitude = 21.422487;
  static const _makkahLongitude = 39.826206;

  final MushafRepository _mushafRepository;

  @override
  WorshipSnapshot calculate({
    required DeviceLocation location,
    required DateTime now,
  }) {
    final localNow = now.toLocal();
    final todaySchedule = _scheduleFor(location, localNow);
    final next = _nextPrayer(location, localNow, todaySchedule);

    return WorshipSnapshot(
      capturedAt: localNow,
      location: location,
      gregorianDateLabel: _formatGregorian(localNow),
      hijriDateLabel: _formatHijri(localNow),
      prayerSchedule: List.unmodifiable(todaySchedule),
      nextPrayer: next,
      qiblaBearingDegrees: Qibla.qibla(
        Coordinates(location.latitude, location.longitude),
      ),
      distanceToMakkahKm: _distanceKm(
        location.latitude,
        location.longitude,
        _makkahLatitude,
        _makkahLongitude,
      ),
      dailyAyah: _dailyAyah(localNow),
    );
  }

  CalculationParameters _parametersFor(DeviceLocation location) {
    final latitude = location.latitude;
    final longitude = location.longitude;
    final isQatar = latitude >= 24.3 && latitude <= 27.0 && longitude >= 50.5 && longitude <= 52.0;
    final isEgypt = latitude >= 22.0 && latitude <= 31.7 && longitude >= 24.5 && longitude <= 37.0;
    final isSaudi = latitude >= 16.0 && latitude <= 32.5 && longitude >= 34.5 && longitude <= 55.7;
    final isUae = latitude >= 22.5 && latitude <= 26.5 && longitude >= 51.5 && longitude <= 56.5;
    final isKuwait = latitude >= 28.4 && latitude <= 30.2 && longitude >= 46.5 && longitude <= 49.0;
    final parameters = isQatar
        ? CalculationMethodParameters.qatar()
        : isEgypt
            ? CalculationMethodParameters.egyptian()
            : isSaudi
                ? CalculationMethodParameters.ummAlQura()
                : isUae
                    ? CalculationMethodParameters.dubai()
                    : isKuwait
                        ? CalculationMethodParameters.kuwait()
                        : CalculationMethodParameters.muslimWorldLeague();
    return parameters..madhab = Madhab.shafi;
  }

  List<PrayerMoment> _scheduleFor(DeviceLocation location, DateTime day) {
    final parameters = _parametersFor(location);
    final times = PrayerTimes(
      coordinates: Coordinates(location.latitude, location.longitude),
      date: day,
      calculationParameters: parameters,
      precision: true,
    );

    return [
      PrayerMoment(kind: PrayerKind.fajr, at: times.fajr.toLocal()),
      PrayerMoment(kind: PrayerKind.sunrise, at: times.sunrise.toLocal()),
      PrayerMoment(kind: PrayerKind.dhuhr, at: times.dhuhr.toLocal()),
      PrayerMoment(kind: PrayerKind.asr, at: times.asr.toLocal()),
      PrayerMoment(kind: PrayerKind.maghrib, at: times.maghrib.toLocal()),
      PrayerMoment(kind: PrayerKind.isha, at: times.isha.toLocal()),
    ];
  }

  PrayerMoment _nextPrayer(
    DeviceLocation location,
    DateTime now,
    List<PrayerMoment> schedule,
  ) {
    for (final moment in schedule) {
      if (moment.kind != PrayerKind.sunrise && moment.at.isAfter(now)) {
        return moment;
      }
    }
    final tomorrow = _scheduleFor(location, now.add(const Duration(days: 1)));
    return tomorrow.firstWhere((moment) => moment.kind == PrayerKind.fajr);
  }

  DailyAyah _dailyAyah(DateTime now) {
    // نستخدم التاريخ كـ seed حتى تكون الآية عشوائية، لكن ثابتة طوال اليوم.
    // هذا مهم لأن calculate() يُستدعى كل ثانية لتحديث الساعة؛ لا نريد
    // تغيير الآية مع كل إعادة بناء للواجهة.
    final day = DateTime(now.year, now.month, now.day);
    final dayKey = day.difference(DateTime(1970, 1, 1)).inDays;
    var remaining = math.Random(dayKey).nextInt(6236);
    for (var surah = 1; surah <= 114; surah++) {
      final count = _mushafRepository.ayahCountForSurah(surah);
      if (remaining < count) {
        final ayah = remaining + 1;
        return DailyAyah(
          surahNumber: surah,
          surahName: _mushafRepository.arabicSurahName(surah),
          ayahNumber: ayah,
          text: _mushafRepository.verseText(
            AyahRef(
              surahNumber: surah,
              ayahNumber: ayah,
              pageNumber: _mushafRepository.pageForAyah(surah, ayah),
            ),
          ),
        );
      }
      remaining -= count;
    }
    throw StateError('تعذر تحديد آية اليوم.');
  }

  String _formatGregorian(DateTime date) {
    const weekdays = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return '${weekdays[date.weekday - 1]}، ${_arabicDigits(date.day)} ${months[date.month - 1]} ${_arabicDigits(date.year)}';
  }

  String _formatHijri(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    const months = ['محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'];
    return '${_arabicDigits(hijri.hDay)} ${months[hijri.hMonth - 1]} ${_arabicDigits(hijri.hYear)} هـ';
  }

  String _arabicDigits(int value) {
    const western = '0123456789';
    const eastern = '٠١٢٣٤٥٦٧٨٩';
    return value.toString().split('').map((digit) => eastern[western.indexOf(digit)]).join();
  }

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _radians(lat2 - lat1);
    final dLon = _radians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_radians(lat1)) *
            math.cos(_radians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _radians(double degrees) => degrees * math.pi / 180;
}
