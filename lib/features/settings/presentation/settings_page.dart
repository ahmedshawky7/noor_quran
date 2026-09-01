import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../mushaf/domain/entities/quran_audio_preferences.dart';
import '../../mushaf/presentation/mushaf_controller.dart';
import '../../worship/domain/entities/location_settings.dart';
import '../../worship/presentation/worship_controller.dart';
import '../data/shared_preferences_adhan_audio_repository.dart';
import '../data/shared_preferences_notification_settings_repository.dart';
import 'adhan_audio_settings_page.dart';
import 'notification_settings_page.dart';
import 'storage_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.mushafController, required this.worshipController, required this.notificationSettingsRepository, required this.adhanAudioRepository});

  final MushafController mushafController;
  final WorshipController worshipController;
  final SharedPreferencesNotificationSettingsRepository notificationSettingsRepository;
  final SharedPreferencesAdhanAudioRepository adhanAudioRepository;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _keepScreenOn = false;
  bool _notifications = true;
  bool _vibration = true;
  static const _cities = <_CityOption>[
    _CityOption('القاهرة', 30.0444, 31.2357),
    _CityOption('الجيزة', 30.0131, 31.2089),
    _CityOption('الإسكندرية', 31.2001, 29.9187),
    _CityOption('المنصورة', 31.0409, 31.3785),
    _CityOption('طنطا', 30.7865, 31.0004),
    _CityOption('الأقصر', 25.6872, 32.6396),
    _CityOption('أسوان', 24.0889, 32.8998),
    _CityOption('الرياض', 24.7136, 46.6753),
    _CityOption('جدة', 21.5433, 39.1728),
    _CityOption('مكة المكرمة', 21.3891, 39.8579),
    _CityOption('المدينة المنورة', 24.5247, 39.5692),
    _CityOption('دبي', 25.2048, 55.2708),
    _CityOption('أبو ظبي', 24.4539, 54.3773),
    _CityOption('الدوحة', 25.2854, 51.5310),
    _CityOption('عمّان', 31.9539, 35.9106),
    _CityOption('الكويت', 29.3759, 47.9774),
  ];

  void _showAdhanAudioPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: AdhanAudioSettingsPage(repository: widget.adhanAudioRepository)),
        ),
      ),
    );
  }

  void _showStoragePage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: StorageSettingsPage(mushafController: widget.mushafController),
        ),
      ),
    );
  }

  void _showNotificationsPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: NotificationSettingsPage(repository: widget.notificationSettingsRepository)),
        ),
      ),
    );
  }

  Future<void> _showReciterPicker() async {
    final selected = await showModalBottomSheet<QuranReciter>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * .72,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Text('اختر القارئ الافتراضي', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
                ),
                const Divider(height: 1, color: AppColors.border),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: widget.mushafController.reciters.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (_, index) {
                      final reciter = widget.mushafController.reciters[index];
                      final selectedNow = reciter == widget.mushafController.reciter;
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                          leading: CircleAvatar(
                            backgroundColor: selectedNow ? AppColors.emerald : AppColors.surfaceRaised,
                            child: Icon(Icons.record_voice_over_outlined, color: selectedNow ? AppColors.background : AppColors.textMuted),
                          ),
                          title: Text(reciter.name, textAlign: TextAlign.right, style: TextStyle(fontWeight: selectedNow ? FontWeight.w800 : FontWeight.w600)),
                          subtitle: const Text('تلاوة افتراضية', textAlign: TextAlign.right, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          trailing: selectedNow ? const Icon(Icons.check_circle_rounded, color: AppColors.emeraldLight) : const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
                          onTap: () => Navigator.of(sheetContext).pop(reciter),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || selected == null || selected == widget.mushafController.reciter) return;
    await widget.mushafController.selectReciter(selected);
    if (mounted) setState(() {});
  }

  Future<void> _showDownloadModePicker() async {
    final selected = await showModalBottomSheet<AudioDownloadMode>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(padding: EdgeInsets.all(20), child: Text('اختار وضع تنزيل التلاوة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
              ...AudioDownloadMode.values.map((mode) => RadioListTile<AudioDownloadMode>(
                    value: mode,
                    groupValue: widget.mushafController.downloadMode,
                    title: Text(mode.title),
                    subtitle: Text(mode.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    activeColor: AppColors.emeraldLight,
                    onChanged: (value) => Navigator.of(sheetContext).pop(value),
                  )),
            ],
          ),
        ),
      ),
    );
    if (!mounted || selected == null || selected == widget.mushafController.downloadMode) return;
    await widget.mushafController.setDownloadMode(selected);
    if (mounted) setState(() {});
  }

  Future<void> _showLocationModePicker() async {
    final mode = await showModalBottomSheet<LocationMode>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Padding(padding: EdgeInsets.all(20), child: Text('مصدر الموقع', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
            RadioListTile<LocationMode>(
              value: LocationMode.automatic,
              groupValue: widget.worshipController.locationSettings.mode,
              title: const Text('تلقائي من GPS'),
              subtitle: const Text('استخدم موقع الجهاز الحالي', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              activeColor: AppColors.emeraldLight,
              onChanged: (value) => Navigator.of(sheetContext).pop(value),
            ),
            RadioListTile<LocationMode>(
              value: LocationMode.manual,
              groupValue: widget.worshipController.locationSettings.mode,
              title: const Text('يدوي'),
              subtitle: const Text('استخدم المدينة أو الإحداثيات المحفوظة', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              activeColor: AppColors.emeraldLight,
              onChanged: (value) => Navigator.of(sheetContext).pop(value),
            ),
            const SizedBox(height: 10),
          ]),
        ),
      ),
    );
    if (!mounted || mode == null) return;
    if (mode == LocationMode.manual) {
      await _showManualLocationDialog();
    } else {
      await widget.worshipController.setLocationMode(LocationMode.automatic);
      if (mounted) setState(() {});
    }
  }

  Future<void> _showManualLocationDialog() async {
    var query = '';
    final selected = await showModalBottomSheet<_CityOption>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            final cities = _cities.where((city) => city.name.contains(query.trim())).toList();
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * .78,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Text('اختار مدينتك', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: TextField(
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'ابحث باسم المدينة'),
                        onChanged: (value) => setSheetState(() => query = value),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    Expanded(
                      child: ListView.separated(
                        itemCount: cities.length,
                        separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                        itemBuilder: (_, index) {
                          final city = cities[index];
                          return Material(
                            color: Colors.transparent,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                              leading: const Icon(Icons.location_city_outlined, color: AppColors.textMuted),
                              title: Text(city.name, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: const Text('سيتم ضبط المواقيت والقبلة تلقائياً', textAlign: TextAlign.right, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                              trailing: const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
                              onTap: () => Navigator.of(sheetContext).pop(city),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
    if (selected == null || !mounted) return;
    await widget.worshipController.setManualLocation(label: selected.name, latitude: selected.latitude, longitude: selected.longitude);
    if (mounted) setState(() {});
  }

  Future<void> _showAboutDialog() => showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('عن قلم'),
          content: const Text('قلم تطبيق عربي يجمع المصحف والأذكار ومواقيت الصلاة والقبلة في واجهة واحدة.'),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('حسناً'))],
        ),
      );

  Future<void> _showSourcesDialog() => showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('المصادر والحقوق'),
          content: const Text('بيانات المصحف من qcf_quran_plus، ومصادر الأذكار موثقة داخل مجلد docs في المشروع.'),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('حسناً'))],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            height: 84,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                  tooltip: 'رجوع',
                ),
                const Spacer(),
                const Text(
                  'الإعدادات',
                  style: TextStyle(
                    color: AppColors.emerald,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                const Text('عام', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _SettingsGroup(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingAction(
                        icon: Icons.notifications_none_rounded,
                        title: 'التنبيهات',
                        value: 'تخصيص كل صلاة وأذكار الصباح والمساء',
                        onTap: _showNotificationsPage,
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _SettingAction(
                        icon: Icons.storage_outlined,
                        title: 'مساحة التخزين',
                        value: 'إدارة التلاوات والبيانات المنزلة',
                        onTap: _showStoragePage,
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _SettingSwitch(
                        icon: Icons.vibration_rounded,
                        title: 'الاهتزاز',
                        subtitle: 'اهتزاز خفيف عند عدّ الأذكار',
                        value: _vibration,
                        onChanged: (value) => setState(() => _vibration = value),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _SettingSwitch(
                        icon: Icons.screen_lock_portrait_outlined,
                        title: 'إبقاء الشاشة مضاءة',
                        subtitle: 'أثناء قراءة المصحف',
                        value: _keepScreenOn,
                        onChanged: (value) => setState(() => _keepScreenOn = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('الموقع ومواقيت الصلاة', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _SettingsGroup(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingAction(
                        icon: Icons.location_on_outlined,
                        title: 'مصدر الموقع',
                        value: widget.worshipController.locationSettings.mode == LocationMode.automatic ? 'تلقائي من GPS' : widget.worshipController.locationSettings.manualLabel,
                        onTap: _showLocationModePicker,
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _SettingAction(
                        icon: Icons.edit_location_alt_outlined,
                        title: 'تحديد الموقع يدوياً',
                        value: 'المدينة أو الإحداثيات',
                        onTap: _showManualLocationDialog,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('المصحف والتلاوة', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _SettingsGroup(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingAction(
                        icon: Icons.record_voice_over_outlined,
                        title: 'القارئ الافتراضي',
                        value: widget.mushafController.reciter.name,
                        onTap: _showReciterPicker,
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _SettingAction(
                        icon: Icons.download_outlined,
                        title: 'تنزيل التلاوة',
                        value: widget.mushafController.downloadMode.title,
                        onTap: _showDownloadModePicker,
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _SettingAction(
                        icon: Icons.volume_up_outlined,
                        title: 'صوت الأذان',
                        value: 'اختيار مستقل لكل صلاة',
                        onTap: _showAdhanAudioPage,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('عن التطبيق', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _SettingsGroup(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingAction(icon: Icons.info_outline_rounded, title: 'عن قلم', value: 'مصحف وأذكار ومواقيت الصلاة', onTap: _showAboutDialog),
                      const Divider(height: 1, color: AppColors.border),
                      _SettingAction(icon: Icons.menu_book_outlined, title: 'المصادر والحقوق', value: 'المصادر المستخدمة داخل التطبيق', onTap: _showSourcesDialog),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _CityOption {
  const _CityOption(this.name, this.latitude, this.longitude);

  final String name;
  final double latitude;
  final double longitude;
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});

  final IconData icon;
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      secondary: Icon(icon, color: AppColors.textMuted),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ),
    );
  }
}

class _SettingAction extends StatelessWidget {
  const _SettingAction({required this.icon, required this.title, required this.value, this.onTap});

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Icon(icon, color: AppColors.textMuted),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(value, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        trailing: const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
