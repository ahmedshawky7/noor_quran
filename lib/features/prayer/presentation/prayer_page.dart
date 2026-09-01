import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_surface.dart';
import '../../../core/widgets/qalam_header.dart';
import '../../worship/domain/entities/prayer_moment.dart';
import '../../worship/domain/entities/location_settings.dart';
import '../../worship/domain/entities/worship_snapshot.dart';
import '../../worship/presentation/widgets/worship_loading_or_error.dart';
import '../../worship/presentation/worship_controller.dart';
import '../../settings/data/shared_preferences_adhan_audio_repository.dart';
import '../../settings/data/shared_preferences_notification_settings_repository.dart';
import '../../settings/presentation/prayer_alert_settings_page.dart';

class PrayerPage extends StatefulWidget {
  const PrayerPage({
    super.key,
    required this.worshipController,
    required this.onOpenQibla,
    required this.onOpenSettings,
    required this.onOpenAdhanSettings,
    required this.notificationRepository,
    required this.adhanRepository,
  });

  final WorshipController worshipController;
  final VoidCallback onOpenQibla;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenAdhanSettings;
  final SharedPreferencesNotificationSettingsRepository notificationRepository;
  final SharedPreferencesAdhanAudioRepository adhanRepository;

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _moveDay(int offset) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: offset)));
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() => _selectedDate = DateTime(now.year, now.month, now.day));
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<void> _pickScheduleDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'اختر تاريخ جدول الصلاة',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedDate = DateTime(picked.year, picked.month, picked.day));
  }

  String _scheduleTitle(DateTime date) {
    if (_isToday(date)) return 'جدول اليوم';
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) return 'جدول غداً';
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) return 'جدول أمس';
    return 'جدول ${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(bottom: false, child: Column(children: [
      QalamHeader(
        onSettingsPressed: widget.onOpenSettings,
        trailing: IconButton(
          onPressed: widget.onOpenQibla,
          icon: const Icon(Icons.explore_outlined, color: AppColors.emeraldLight),
          tooltip: 'القبلة',
        ),
      ),
      Expanded(child: AnimatedBuilder(animation: widget.worshipController, builder: (context, _) {
        final currentSnapshot = widget.worshipController.snapshot;
        if (currentSnapshot == null) return WorshipLoadingOrError(controller: widget.worshipController);
        final scheduleSnapshot = widget.worshipController.snapshotForDate(_selectedDate) ?? currentSnapshot;
        return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 30, 24, 28), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _NextPrayerPanel(snapshot: currentSnapshot, locationLabel: widget.worshipController.locationLabel),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: _ActionTile(icon: Icons.explore_outlined, label: 'تحديد القبلة', color: AppColors.emeraldLight, onTap: widget.onOpenQibla)), const SizedBox(width: 16), Expanded(child: _ActionTile(icon: Icons.volume_up_outlined, label: 'إعدادات الأذان', color: AppColors.gold, onTap: widget.onOpenAdhanSettings))]),
          const SizedBox(height: 45),
          Row(
            children: [
              IconButton(onPressed: () => _moveDay(-1), icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.gold), tooltip: 'اليوم السابق'),
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'اختيار تاريخ جدول الصلاة',
                  child: InkWell(
                    onTap: _pickScheduleDate,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(_scheduleTitle(_selectedDate), textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_month_outlined, size: 20, color: AppColors.gold),
                      ]),
                    ),
                  ),
                ),
              ),
              IconButton(onPressed: () => _moveDay(1), icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.gold), tooltip: 'اليوم التالي'),
            ],
          ),
          if (!_isToday(_selectedDate)) Center(child: TextButton.icon(onPressed: _goToToday, icon: const Icon(Icons.today_outlined, size: 18), label: const Text('العودة إلى اليوم'))),
          const SizedBox(height: 10),
          ...scheduleSnapshot.prayerSchedule.map((prayer) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _PrayerRow(prayer: prayer, state: _isToday(_selectedDate) ? _stateFor(prayer, currentSnapshot) : _RowState.upcoming, onBell: () => _openPrayerAlert(context, prayer)))),
        ]));
      })),
    ]));
  }

  void _openPrayerAlert(BuildContext context, PrayerMoment prayer) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(body: PrayerAlertSettingsPage(prayerKey: _prayerKey(prayer.kind), prayerName: _name(prayer.kind), notificationRepository: widget.notificationRepository, adhanRepository: widget.adhanRepository)))));
  }
}

class _NextPrayerPanel extends StatelessWidget {
  const _NextPrayerPanel({required this.snapshot, required this.locationLabel});
  final WorshipSnapshot snapshot;
  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    return AppSurface(borderColor: const Color(0xFF5A4B33), padding: const EdgeInsets.fromLTRB(20, 28, 20, 20), gradient: const LinearGradient(colors: [Color(0xFF161B29), Color(0xFF151217)]), child: Column(children: [
      const Text('الصلاة القادمة', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w700)),
      const SizedBox(height: 11),
      Text(_name(snapshot.nextPrayer.kind), style: const TextStyle(fontSize: 47, fontWeight: FontWeight.w500)),
      const SizedBox(height: 5),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 18), const SizedBox(width: 5), Text(locationLabel)]),
      const SizedBox(height: 22),
      SizedBox(width: 210, height: 210, child: Stack(fit: StackFit.expand, children: [
        const CircularProgressIndicator(value: .72, strokeWidth: 6, color: AppColors.gold, backgroundColor: Color(0xFF2D3441)),
        Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_countdown(snapshot.remainingToNextPrayer), textDirection: TextDirection.ltr, style: const TextStyle(color: AppColors.gold, fontSize: 34, fontWeight: FontWeight.w500)), const Text('متبقي', style: TextStyle(fontSize: 12))])),
      ])),
      const SizedBox(height: 21),
      Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF17171A), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.calendar_today_outlined, color: AppColors.emeraldLight), const SizedBox(width: 10), Text('${snapshot.hijriDateLabel}\n${snapshot.gregorianDateLabel}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))])),
    ]));
  }
}

class _ActionTile extends StatelessWidget { const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap}); final IconData icon; final String label; final Color color; final VoidCallback onTap; @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: AppSurface(padding: const EdgeInsets.symmetric(vertical: 20), child: Column(children: [Icon(icon, color: color, size: 28), const SizedBox(height: 9), Text(label, style: const TextStyle(fontWeight: FontWeight.w600))]))); }
class _PrayerRow extends StatelessWidget { const _PrayerRow({required this.prayer, required this.state, required this.onBell}); final PrayerMoment prayer; final _RowState state; final VoidCallback onBell; @override Widget build(BuildContext context) { final current = state == _RowState.current; final foreground = current ? AppColors.gold : AppColors.textPrimary; return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: current ? const Color(0xFF392B18) : AppColors.surface, borderRadius: BorderRadius.circular(15), border: Border.all(color: current ? AppColors.gold : AppColors.border, width: current ? 1.3 : 1)), child: Row(children: [Text(_icon(prayer.kind), style: TextStyle(color: foreground, fontSize: 24)), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_name(prayer.kind), style: TextStyle(color: foreground, fontSize: 18, fontWeight: FontWeight.w700)), Text(_subtitle(prayer.kind), style: const TextStyle(fontSize: 12, color: AppColors.textMuted))]), const Spacer(), IconButton(onPressed: onBell, icon: Icon(current ? Icons.notifications_active_outlined : Icons.notifications_none_outlined, color: current ? AppColors.gold : AppColors.textMuted), tooltip: 'إعداد تنبيه ${_name(prayer.kind)}'), const SizedBox(width: 4), Text(_time(prayer.at), textDirection: TextDirection.ltr, style: TextStyle(color: foreground, fontSize: 20, fontWeight: FontWeight.w600))])); } }

String _prayerKey(PrayerKind kind) => switch (kind) { PrayerKind.fajr => 'fajr', PrayerKind.sunrise => 'sunrise', PrayerKind.dhuhr => 'dhuhr', PrayerKind.asr => 'asr', PrayerKind.maghrib => 'maghrib', PrayerKind.isha => 'isha' };
enum _RowState { completed, current, upcoming }
_RowState _stateFor(PrayerMoment moment, WorshipSnapshot snapshot) { if (moment.kind == snapshot.nextPrayer.kind && moment.at == snapshot.nextPrayer.at) return _RowState.current; if (moment.at.isBefore(snapshot.capturedAt)) return _RowState.completed; return _RowState.upcoming; }
String _name(PrayerKind kind) => switch (kind) { PrayerKind.fajr => 'الفجر', PrayerKind.sunrise => 'الشروق', PrayerKind.dhuhr => 'الظهر', PrayerKind.asr => 'العصر', PrayerKind.maghrib => 'المغرب', PrayerKind.isha => 'العشاء' };
String _subtitle(PrayerKind kind) => switch (kind) { PrayerKind.fajr => 'الفجر', PrayerKind.sunrise => 'الشروق', PrayerKind.dhuhr || PrayerKind.asr => 'النهار', PrayerKind.maghrib => 'الغروب', PrayerKind.isha => 'الليل' };
String _icon(PrayerKind kind) => switch (kind) { PrayerKind.fajr => '☀', PrayerKind.sunrise => '☼', PrayerKind.dhuhr => '☀', PrayerKind.asr => '◐', PrayerKind.maghrib => '●', PrayerKind.isha => '☾' };
String _time(DateTime value) => '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
String _countdown(Duration value) { final seconds = value.inSeconds < 0 ? 0 : value.inSeconds; return '${(seconds ~/ 3600).toString().padLeft(2, '0')}:${((seconds % 3600) ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}'; }
String _locationLabel(WorshipController controller) { final settings = controller.locationSettings; return settings.mode == LocationMode.manual && settings.manualLabel.trim().isNotEmpty ? settings.manualLabel : 'موقعك الحالي'; }
