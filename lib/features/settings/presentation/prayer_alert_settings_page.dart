import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/theme/app_colors.dart';
import '../data/shared_preferences_adhan_audio_repository.dart';
import '../data/shared_preferences_notification_settings_repository.dart';
import '../domain/adhan_audio_settings.dart';
import '../domain/notification_settings.dart';

class PrayerAlertSettingsPage extends StatefulWidget {
  const PrayerAlertSettingsPage({super.key, required this.prayerKey, required this.prayerName, required this.notificationRepository, required this.adhanRepository});

  final String prayerKey;
  final String prayerName;
  final SharedPreferencesNotificationSettingsRepository notificationRepository;
  final SharedPreferencesAdhanAudioRepository adhanRepository;

  @override
  State<PrayerAlertSettingsPage> createState() => _PrayerAlertSettingsPageState();
}

class _PrayerAlertSettingsPageState extends State<PrayerAlertSettingsPage> {
  static const _voices = AdhanVoices.all;

  late NotificationSettings _notifications;
  late AdhanAudioSettings _adhan;
  final _player = AudioPlayer();
  String? _playing;

  @override
  void initState() {
    super.initState();
    _notifications = widget.notificationRepository.load();
    _adhan = widget.adhanRepository.load();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  bool _enabled() => switch (widget.prayerKey) {
        'fajr' => _notifications.fajr,
        'dhuhr' => _notifications.dhuhr,
        'asr' => _notifications.asr,
        'maghrib' => _notifications.maghrib,
        'sunrise' => _notifications.sunrise,
        _ => _notifications.isha,
      };

  Future<void> _setEnabled(bool value) async {
    final next = switch (widget.prayerKey) {
      'fajr' => _notifications.copyWith(fajr: value),
      'dhuhr' => _notifications.copyWith(dhuhr: value),
      'asr' => _notifications.copyWith(asr: value),
      'maghrib' => _notifications.copyWith(maghrib: value),
      'sunrise' => _notifications.copyWith(sunrise: value),
      _ => _notifications.copyWith(isha: value),
    };
    setState(() => _notifications = next);
    await widget.notificationRepository.save(next);
  }

  AdhanVoice _voice() => _voices.firstWhere((voice) => voice.id == _adhan.forPrayer(widget.prayerKey), orElse: () => _voices.first);

  int _minutes() => switch (widget.prayerKey) {
        'fajr' => _notifications.fajrMinutes,
        'sunrise' => _notifications.sunriseMinutes,
        'dhuhr' => _notifications.dhuhrMinutes,
        'asr' => _notifications.asrMinutes,
        'maghrib' => _notifications.maghribMinutes,
        _ => _notifications.ishaMinutes,
      };

  Future<void> _setMinutes(int value) async {
    final next = switch (widget.prayerKey) {
      'fajr' => _notifications.copyWith(fajrMinutes: value),
      'sunrise' => _notifications.copyWith(sunriseMinutes: value),
      'dhuhr' => _notifications.copyWith(dhuhrMinutes: value),
      'asr' => _notifications.copyWith(asrMinutes: value),
      'maghrib' => _notifications.copyWith(maghribMinutes: value),
      _ => _notifications.copyWith(ishaMinutes: value),
    };
    setState(() => _notifications = next);
    await widget.notificationRepository.save(next);
  }

  Future<void> _chooseMinutes() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Material(color: Colors.transparent, child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, 8), child: Align(alignment: Alignment.centerRight, child: Text('موعد ظهور التنبيه', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),),
          for (final value in const [0, 5, 10, 15]) ListTile(
            title: Text(value == 0 ? 'عند دخول وقت الصلاة' : 'قبل الصلاة بـ$value دقائق'),
            trailing: value == _minutes() ? const Icon(Icons.check_circle_rounded, color: AppColors.emeraldLight) : null,
            onTap: () => Navigator.of(sheetContext).pop(value),
          ),
          const SizedBox(height: 8),
        ]))),
      ),
    );
    if (selected == null) return;
    await _setMinutes(selected);
  }

  bool _silent() => switch (widget.prayerKey) {
        'fajr' => _notifications.fajrSilent,
        'sunrise' => _notifications.sunriseSilent,
        'dhuhr' => _notifications.dhuhrSilent,
        'asr' => _notifications.asrSilent,
        'maghrib' => _notifications.maghribSilent,
        _ => _notifications.ishaSilent,
      };

  String _alertTypeLabel() => !_enabled() ? 'متوقف' : (_silent() ? 'إشعار بدون صوت' : 'أذان');

  Future<void> _chooseAlertType() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => Directionality(textDirection: TextDirection.rtl, child: Material(color: Colors.transparent, child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, 8), child: Align(alignment: Alignment.centerRight, child: Text('نوع التنبيه', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)))),
        ListTile(title: const Text('أذان'), subtitle: const Text('تنبيه بصوت المؤذن المختار'), trailing: !_silent() && _enabled() ? const Icon(Icons.check_circle_rounded, color: AppColors.emeraldLight) : null, onTap: () => Navigator.pop(sheetContext, 1)),
        ListTile(title: const Text('إشعار فقط'), subtitle: const Text('إشعار بدون صوت أذان'), trailing: _silent() && _enabled() ? const Icon(Icons.check_circle_rounded, color: AppColors.emeraldLight) : null, onTap: () => Navigator.pop(sheetContext, 2)),
        ListTile(title: const Text('إيقاف'), subtitle: const Text('عدم إرسال تنبيه لهذه الصلاة'), trailing: !_enabled() ? const Icon(Icons.check_circle_rounded, color: AppColors.emeraldLight) : null, onTap: () => Navigator.pop(sheetContext, 0)),
        const SizedBox(height: 8),
      ])))),
    );
    if (selected == null) return;
    final enabled = selected != 0;
    final silent = selected == 2;
    final next = switch (widget.prayerKey) {
      'fajr' => _notifications.copyWith(fajr: enabled, fajrSilent: silent),
      'sunrise' => _notifications.copyWith(sunrise: enabled, sunriseSilent: silent),
      'dhuhr' => _notifications.copyWith(dhuhr: enabled, dhuhrSilent: silent),
      'asr' => _notifications.copyWith(asr: enabled, asrSilent: silent),
      'maghrib' => _notifications.copyWith(maghrib: enabled, maghribSilent: silent),
      _ => _notifications.copyWith(isha: enabled, ishaSilent: silent),
    };
    setState(() => _notifications = next);
    await widget.notificationRepository.save(next);
  }

  String _minutesLabel() => _minutes() == 0 ? 'عند دخول الوقت' : 'قبل الوقت بـ${_minutes()} دقائق';

  Future<void> _preview(AdhanVoice voice) async {
    try {
      if (_playing == voice.id) {
        await _player.stop();
        if (mounted) setState(() => _playing = null);
        return;
      }
      setState(() => _playing = voice.id);
      await _player.setAsset(voice.assetPath);
      await _player.play();
      if (mounted) setState(() => _playing = null);
    } catch (_) {
      if (mounted) {
        setState(() => _playing = null);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر تشغيل المعاينة، تأكد من الاتصال بالإنترنت')));
      }
    }
  }

  Future<void> _chooseVoice() async {
    final current = _voice();
    final selected = await showModalBottomSheet<AdhanVoice>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(child: ListView(shrinkWrap: true, children: [
          Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 8), child: Text('اختار مؤذن ${widget.prayerName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('اضغط زر التشغيل لسماع الصوت قبل اختياره.', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
          const SizedBox(height: 8),
          for (final voice in _voices) Material(color: Colors.transparent, child: ListTile(leading: IconButton(onPressed: () => _preview(voice), icon: Icon(_playing == voice.id ? Icons.stop_circle_outlined : Icons.play_circle_outline_rounded, color: AppColors.emeraldLight), tooltip: 'معاينة'), title: Text(voice.name, style: const TextStyle(fontWeight: FontWeight.w700)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [if (voice.id == current.id) const Icon(Icons.check_circle_rounded, color: AppColors.emeraldLight) else const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted)]), onTap: () => Navigator.of(sheetContext).pop(voice))),
          const SizedBox(height: 8),
        ])),
      ),
    );
    if (!mounted || selected == null) return;
    final next = switch (widget.prayerKey) {
      'fajr' => _adhan.copyWith(fajr: selected.id),
      'dhuhr' => _adhan.copyWith(dhuhr: selected.id),
      'asr' => _adhan.copyWith(asr: selected.id),
      'maghrib' => _adhan.copyWith(maghrib: selected.id),
      'sunrise' => _adhan.copyWith(sunrise: selected.id),
      _ => _adhan.copyWith(isha: selected.id),
    };
    setState(() => _adhan = next);
    await widget.adhanRepository.save(next);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(bottom: false, child: Column(children: [
      Container(height: 84, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))), child: Row(children: [IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary), tooltip: 'رجوع'), const Spacer(), Text('منبه ${widget.prayerName}', style: const TextStyle(color: AppColors.emerald, fontSize: 23, fontWeight: FontWeight.w700)), const Spacer(), const SizedBox(width: 48)])),
      Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 32), children: [
        const Text('منبه قبل الأذان', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        _Group(children: [
          SwitchListTile(value: _enabled(), onChanged: _setEnabled, activeColor: AppColors.emeraldLight, contentPadding: const EdgeInsets.symmetric(horizontal: 14), secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.textMuted), title: const Text('تنبيه دخول وقت الصلاة', style: TextStyle(fontWeight: FontWeight.w700)), subtitle: const Text('تشغيل أو إيقاف التنبيه لهذه الصلاة فقط', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
          const Divider(height: 1, color: AppColors.border),
          ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 14), leading: const Icon(Icons.schedule_outlined, color: AppColors.textMuted), title: const Text('موعد التنبيه', style: TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(_minutesLabel(), style: const TextStyle(color: AppColors.textMuted, fontSize: 12)), trailing: const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted), onTap: _chooseMinutes),
          const Divider(height: 1, color: AppColors.border),
          ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 14), leading: Icon(_silent() ? Icons.volume_off_outlined : Icons.notifications_active_outlined, color: AppColors.textMuted), title: const Text('نوع التنبيه', style: TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(_alertTypeLabel(), style: const TextStyle(color: AppColors.textMuted, fontSize: 12)), trailing: const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted), onTap: _chooseAlertType),
          const Divider(height: 1, color: AppColors.border),
          ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 14), leading: const Icon(Icons.volume_up_outlined, color: AppColors.textMuted), title: const Text('صوت الأذان', style: TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(_voice().name, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)), trailing: const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted), onTap: _chooseVoice),
        ]),
        const SizedBox(height: 24),
        const Text('ملاحظات', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        const Text('يمكنك تغيير صوت كل صلاة بشكل مستقل. يمكنك اختيار التنبيه عند دخول الوقت أو قبله بـ5 أو 10 أو 15 دقيقة. وضع «صامت» يعرض إشعاراً بدون صوت، بينما «صوت الأذان» يحدد صوت التنبيه.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ])),
    ]));
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)), child: Column(children: children.map((child) => child is ListTile || child is SwitchListTile ? Material(color: Colors.transparent, child: child) : child).toList()));
}
