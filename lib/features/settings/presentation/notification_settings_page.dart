import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/shared_preferences_notification_settings_repository.dart';
import '../domain/notification_settings.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key, required this.repository});

  final SharedPreferencesNotificationSettingsRepository repository;

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late NotificationSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.repository.load();
  }

  Future<void> _update(NotificationSettings next) async {
    setState(() => _settings = next);
    await widget.repository.save(next);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _SettingsTopBar(title: 'التنبيهات'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
              children: [
                const Text('تنبيهات الصلاة', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _NotificationGroup(children: [
                  _NotificationSwitch(title: 'الفجر', subtitle: 'عند دخول وقت صلاة الفجر', value: _settings.fajr, onChanged: (v) => _update(_settings.copyWith(fajr: v))),
                  _NotificationSwitch(title: 'الظهر', subtitle: 'عند دخول وقت صلاة الظهر', value: _settings.dhuhr, onChanged: (v) => _update(_settings.copyWith(dhuhr: v))),
                  _NotificationSwitch(title: 'العصر', subtitle: 'عند دخول وقت صلاة العصر', value: _settings.asr, onChanged: (v) => _update(_settings.copyWith(asr: v))),
                  _NotificationSwitch(title: 'المغرب', subtitle: 'عند دخول وقت صلاة المغرب', value: _settings.maghrib, onChanged: (v) => _update(_settings.copyWith(maghrib: v))),
                  _NotificationSwitch(title: 'العشاء', subtitle: 'عند دخول وقت صلاة العشاء', value: _settings.isha, onChanged: (v) => _update(_settings.copyWith(isha: v))),
                ]),
                const SizedBox(height: 24),
                const Text('تنبيهات الأذكار', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _NotificationGroup(children: [
                  _NotificationSwitch(title: 'أذكار الصباح', subtitle: 'بعد صلاة الفجر', value: _settings.morningAdhkar, onChanged: (v) => _update(_settings.copyWith(morningAdhkar: v))),
                  _NotificationSwitch(title: 'أذكار المساء', subtitle: 'بعد صلاة العصر أو المغرب', value: _settings.eveningAdhkar, onChanged: (v) => _update(_settings.copyWith(eveningAdhkar: v))),
                ]),
                const SizedBox(height: 24),
                const Text('خيارات إضافية', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _NotificationGroup(children: [
                  _NotificationSwitch(title: 'تنبيه قبل الصلاة', subtitle: 'تنبيه قبل الموعد بـ 10 دقائق', value: _settings.beforePrayer, onChanged: (v) => _update(_settings.copyWith(beforePrayer: v))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTopBar extends StatelessWidget {
  const _SettingsTopBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary), tooltip: 'رجوع'),
        const Spacer(),
        Text(title, style: const TextStyle(color: AppColors.emerald, fontSize: 26, fontWeight: FontWeight.w700)),
        const Spacer(),
        const SizedBox(width: 48),
      ]),
    );
  }
}

class _NotificationGroup extends StatelessWidget {
  const _NotificationGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) const Divider(height: 1, color: AppColors.border),
        ],
      ]),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  const _NotificationSwitch({required this.title, required this.subtitle, required this.value, required this.onChanged});
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.emeraldLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        secondary: const Icon(Icons.notifications_none_rounded, color: AppColors.textMuted),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ),
    );
  }
}
