import 'package:flutter/material.dart';

import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:qcf_quran_plus/src/data/quran_data.dart' show quran;

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_surface.dart';
import '../../../core/widgets/qalam_header.dart';
import '../../mushaf/presentation/mushaf_controller.dart';
import '../../worship/domain/entities/daily_ayah.dart';
import '../../worship/domain/entities/prayer_moment.dart';
import '../../worship/domain/entities/worship_snapshot.dart';
import '../../worship/presentation/widgets/worship_loading_or_error.dart';
import '../../worship/presentation/worship_controller.dart';
import '../domain/entities/reading_progress.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.onContinueReading,
    required this.onOpenQibla,
    required this.onOpenSettings,
    required this.worshipController,
    required this.mushafController,
  });

  final VoidCallback onContinueReading;
  final VoidCallback onOpenQibla;
  final VoidCallback onOpenSettings;
  final WorshipController worshipController;
  final MushafController mushafController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(children: [
        QalamHeader(
          onSettingsPressed: onOpenSettings,
          trailing: IconButton(
            onPressed: onOpenQibla,
            icon: const Icon(Icons.explore_outlined, color: AppColors.emeraldLight),
            tooltip: 'القبلة',
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: worshipController,
            builder: (context, _) {
              final snapshot = worshipController.snapshot;
              if (snapshot == null) {
                return _DashboardLoadingBody(controller: worshipController, mushafController: mushafController, onContinueReading: onContinueReading);
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 25, 24, 30),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text(snapshot.hijriDateLabel, textAlign: TextAlign.right, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(snapshot.gregorianDateLabel, textAlign: TextAlign.right, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ]),
                  const SizedBox(height: 22),
                  _NextPrayerCard(snapshot: snapshot),
                  const SizedBox(height: 18),
                  _DailyAyahCard(snapshot: snapshot),
                  const SizedBox(height: 18),
                  AnimatedBuilder(
                    animation: mushafController,
                    builder: (context, _) => _ReadingProgressCard(
                      progress: _readingProgress(mushafController),
                      hasPosition: mushafController.lastPosition?.anchorAyah != null,
                      onPressed: onContinueReading,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _FastingTrackerCard(
                    fajrAt: snapshot.prayerSchedule.firstWhere((prayer) => prayer.kind == PrayerKind.fajr).at,
                    maghribAt: snapshot.prayerSchedule.firstWhere((prayer) => prayer.kind == PrayerKind.maghrib).at,
                  ),
                  const SizedBox(height: 18),
                  const _QuickToolsCard(),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _DashboardLoadingBody extends StatelessWidget {
  const _DashboardLoadingBody({required this.controller, required this.mushafController, required this.onContinueReading});
  final WorshipController controller;
  final MushafController mushafController;
  final VoidCallback onContinueReading;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 25, 24, 30),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AppSurface(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(children: [
              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.emeraldLight)),
              const SizedBox(width: 10),
              Expanded(child: Text(controller.isLoading ? 'بنحدد موقعك ونحدّث المواقيت…' : (controller.errorMessage ?? 'المواقيت هتظهر هنا بعد تحديد الموقع'), style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
              if (!controller.isLoading && controller.errorMessage != null) IconButton(onPressed: controller.refreshLocation, icon: const Icon(Icons.sync_rounded, color: AppColors.emeraldLight), tooltip: 'إعادة المحاولة'),
            ]),
          ),
          const SizedBox(height: 18),
          const _LoadingCard(height: 96),
          const SizedBox(height: 18),
          const _LoadingCard(height: 148),
          const SizedBox(height: 18),
          AnimatedBuilder(animation: mushafController, builder: (context, _) => _ReadingProgressCard(progress: _readingProgress(mushafController), hasPosition: mushafController.lastPosition?.anchorAyah != null, onPressed: onContinueReading)),
          const SizedBox(height: 18),
          const _LoadingCard(height: 105),
        ]),
      );
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.height});
  final double height;
  @override
  Widget build(BuildContext context) => AppSurface(child: SizedBox(height: height));
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({required this.snapshot});
  final WorshipSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final next = snapshot.nextPrayer;
    return AppSurface(
      borderColor: const Color(0xFF69512F),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('الصلاة القادمة', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 5),
          Row(children: [
            Text(_prayerName(next.kind), style: const TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(width: 12),
            Text(_formatTime(next.at), textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          ]),
        ])),
        Container(width: 1, height: 52, color: AppColors.border),
        const SizedBox(width: 18),
        Text(_formatCountdown(snapshot.remainingToNextPrayer), textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 20)),
      ]),
    );
  }
}

class _DailyAyahCard extends StatelessWidget {
  const _DailyAyahCard({required this.snapshot});
  final WorshipSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final ayah = snapshot.dailyAyah;
    return AppSurface(
      padding: const EdgeInsets.all(20),
      gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF1A2528), AppColors.surface]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(Icons.bookmark_border, color: Color(0xFFD7D9EA)),
          DecoratedBox(decoration: BoxDecoration(color: Color(0x33000000), borderRadius: BorderRadius.all(Radius.circular(18))), child: Padding(padding: EdgeInsets.symmetric(horizontal: 13, vertical: 6), child: Text('آية اليوم', style: TextStyle(fontSize: 12)))),
        ]),
        const SizedBox(height: 30),
        _DailyAyahQcfText(ayah: ayah),
        const SizedBox(height: 18),
        Text('سورة ${ayah.surahName} • الآية ${ayah.ayahNumber}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
      ]),
    );
  }
}

class _DailyAyahQcfText extends StatefulWidget {
  const _DailyAyahQcfText({required this.ayah});

  final DailyAyah ayah;

  @override
  State<_DailyAyahQcfText> createState() => _DailyAyahQcfTextState();
}

class _DailyAyahQcfTextState extends State<_DailyAyahQcfText> {
  bool _fontReady = false;

  @override
  void initState() {
    super.initState();
    _loadPageFont();
  }

  @override
  void didUpdateWidget(covariant _DailyAyahQcfText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ayah.surahNumber != widget.ayah.surahNumber ||
        oldWidget.ayah.ayahNumber != widget.ayah.ayahNumber) {
      _fontReady = false;
      _loadPageFont();
    }
  }

  Future<void> _loadPageFont() async {
    try {
      await QcfFontLoader.ensureFontLoaded(_pageNumber);
      if (mounted) setState(() => _fontReady = true);
    } catch (_) {
      // يظل النص العثماني في البديل مرئياً إذا تعذر تحميل خط الصفحة.
    }
  }

  Map<String, dynamic> get _verse => quran.firstWhere(
        (item) =>
            item['sora'] == widget.ayah.surahNumber &&
            item['aya_no'] == widget.ayah.ayahNumber,
      );

  int get _pageNumber => _verse['page'] as int;

  @override
  Widget build(BuildContext context) {
    if (!_fontReady) return _DailyAyahFallback(ayah: widget.ayah);

    final qcfText = _verse['qcfData'].toString();
    final endsLine = qcfText.endsWith('\n');
    final lineText = endsLine ? qcfText.substring(0, qcfText.length - 1) : qcfText;
    final glyph = getaya_noQCF(widget.ayah.surahNumber, widget.ayah.ayahNumber);
    final verseBody = lineText.endsWith(glyph)
        ? lineText.substring(0, lineText.length - glyph.length)
        : lineText;
    final baseStyle = QuranTextStyles.qcfStyle(
      pageNumber: _pageNumber,
      color: const Color(0xFFF8F3E8),
      fontSize: 31,
      height: 1.5,
    );
    final mainTextStyle = _withGlyphColor(baseStyle, const Color(0xFFF8F3E8));
    final ayahNumberStyle = _withGlyphColor(baseStyle, const Color(0xFFE6B555));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: verseBody, style: mainTextStyle),
              TextSpan(text: glyph, style: ayahNumberStyle),
              if (endsLine) TextSpan(text: '\n', style: mainTextStyle),
            ],
          ),
          textAlign: TextAlign.center,
          style: baseStyle,
        ),
      ),
    );
  }

  TextStyle _withGlyphColor(TextStyle style, Color color) => style
      .copyWith(color: null)
      .merge(TextStyle(foreground: Paint()..colorFilter = ColorFilter.mode(color, BlendMode.srcIn)));
}

class _DailyAyahFallback extends StatelessWidget {
  const _DailyAyahFallback({required this.ayah});

  final DailyAyah ayah;

  @override
  Widget build(BuildContext context) {
    final text = ayah.text
        .replaceAll(RegExp(r'[\u00A0\s]+[٠-٩0-9]+$'), '')
        .trim();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFF8F3E8),
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.58,
        ),
      ),
    );
  }
}

class _ReadingProgressCard extends StatelessWidget {
  const _ReadingProgressCard({required this.progress, required this.hasPosition, required this.onPressed});
  final ReadingProgress progress;
  final bool hasPosition;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppSurface(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Row(children: [Icon(Icons.history, color: Color(0xFFD7D9EA)), Spacer(), Text('مواصلة القراءة', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700))]),
      const SizedBox(height: 20),
      Text(
        hasPosition ? progress.surahName : 'لم تبدأ القراءة بعد',
        textAlign: TextAlign.right,
        style: const TextStyle(color: AppColors.gold, fontSize: 19, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 5),
      Text(
        hasPosition ? 'الآية ${progress.ayah} • الجزء ${progress.juz}' : 'ابدأ قراءة المصحف ليظهر آخر موضع هنا',
        textAlign: TextAlign.right,
      ),
      const SizedBox(height: 19),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('نسبة القراءة'),
        Text(
          '${(progress.progress * 100).round()}%',
          textDirection: TextDirection.ltr,
          style: const TextStyle(color: AppColors.emeraldLight, fontWeight: FontWeight.w700),
        ),
      ]),
      const SizedBox(height: 8),
      ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: progress.progress, minHeight: 7, color: AppColors.emeraldLight, backgroundColor: const Color(0xFF29313D))),
      const SizedBox(height: 22),
      FilledButton.icon(onPressed: onPressed, icon: const Icon(Icons.arrow_back, color: AppColors.background), label: Text(hasPosition ? 'استئناف القراءة' : 'ابدأ القراءة', style: const TextStyle(color: AppColors.background, fontWeight: FontWeight.w700)), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: AppColors.emeraldLight, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
    ]));
  }
}

ReadingProgress _readingProgress(MushafController controller) {
  final position = controller.lastPosition;
  if (position == null || position.anchorAyah == null) {
    return const ReadingProgress(surahName: '', ayah: 0, juz: 0, progress: 0);
  }
  final ayah = position.anchorAyah!;
  final completedBefore = _completedAyahsBefore(ayah.surahNumber);
  final globalAyah = completedBefore + ayah.ayahNumber;
  const totalAyahs = 6236;
  return ReadingProgress(
    surahName: controller.surahs.firstWhere((surah) => surah.number == ayah.surahNumber).arabicName,
    ayah: ayah.ayahNumber,
    juz: controller.juzForAyah(ayah),
    progress: (globalAyah / totalAyahs).clamp(0.0, 1.0),
  );
}

int _completedAyahsBefore(int surahNumber) {
  const counts = [
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128,
    111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30,
    73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45,
    60, 49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52,
    44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19,
    26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 8, 3, 5, 6, 8,
    3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6, 3, 5,
  ];
  return counts.take(surahNumber - 1).fold<int>(0, (sum, count) => sum + count);
}

class _FastingTrackerCard extends StatelessWidget {
  const _FastingTrackerCard({required this.fajrAt, required this.maghribAt});
  final DateTime fajrAt;
  final DateTime maghribAt;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final total = maghribAt.difference(fajrAt);
    final elapsed = now.difference(fajrAt);
    final progress = now.isBefore(fajrAt)
        ? 0.0
        : now.isAfter(maghribAt)
            ? 1.0
            : (elapsed.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
    final remaining = now.isBefore(fajrAt) ? fajrAt.difference(now) : maghribAt.difference(now);
    final status = now.isBefore(fajrAt)
        ? 'حتى بداية الصيام'
        : now.isBefore(maghribAt)
            ? 'حتى الإفطار'
            : 'انتهى الصيام';

    return AppSurface(child: Column(children: [
      Row(children: [
        const DecoratedBox(decoration: BoxDecoration(color: Color(0xFF36200D), borderRadius: BorderRadius.all(Radius.circular(9))), child: Padding(padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5), child: Text('من الفجر للمغرب', style: TextStyle(color: AppColors.gold, fontSize: 11)))),
        const Spacer(), const Text('متتبع الصيام', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 22),
      SizedBox(width: 150, height: 150, child: Stack(fit: StackFit.expand, children: [
        CircularProgressIndicator(value: progress, strokeWidth: 6, color: AppColors.gold, backgroundColor: const Color(0xFF2B3340)),
        Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_formatCountdown(remaining), textDirection: TextDirection.ltr, style: const TextStyle(color: AppColors.gold, fontSize: 23, fontWeight: FontWeight.w700)),
          Text(status, style: const TextStyle(fontSize: 11)),
        ])),
      ])),
    ]));
  }
}

class _QuickToolsCard extends StatelessWidget {
  const _QuickToolsCard();
  @override
  Widget build(BuildContext context) => AppSurface(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const Text('أدوات سريعة', textAlign: TextAlign.right, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
    const SizedBox(height: 16),
    Row(children: const [Expanded(child: _Tool(icon: Icons.mosque_outlined, label: 'المساجد')), SizedBox(width: 14), Expanded(child: _Tool(icon: Icons.favorite_border, label: 'دعاء'))]),
  ]));
}

class _Tool extends StatelessWidget {
  const _Tool({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(height: 118, decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(15)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(radius: 25, backgroundColor: const Color(0xFF063D35), child: Icon(icon, color: AppColors.emeraldLight)), const SizedBox(height: 10), Text(label, style: const TextStyle(fontWeight: FontWeight.w600))]));
}

String _prayerName(dynamic kind) => switch (kind.toString().split('.').last) { 'fajr' => 'الفجر', 'sunrise' => 'الشروق', 'dhuhr' => 'الظهر', 'asr' => 'العصر', 'maghrib' => 'المغرب', _ => 'العشاء' };
String _formatTime(DateTime time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
String _formatCountdown(Duration value) { final seconds = value.isNegative ? 0 : value.inSeconds; final hours = seconds ~/ 3600; final minutes = (seconds % 3600) ~/ 60; final remainder = seconds % 60; return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}'; }
