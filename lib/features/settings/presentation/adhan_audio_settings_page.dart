import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/theme/app_colors.dart';
import '../data/shared_preferences_adhan_audio_repository.dart';
import '../domain/adhan_audio_settings.dart';

class AdhanAudioSettingsPage extends StatefulWidget {
  const AdhanAudioSettingsPage({super.key, required this.repository});

  final SharedPreferencesAdhanAudioRepository repository;

  @override
  State<AdhanAudioSettingsPage> createState() => _AdhanAudioSettingsPageState();
}

class _AdhanAudioSettingsPageState extends State<AdhanAudioSettingsPage> {
  static const _voices = AdhanVoices.all;

  late AdhanAudioSettings _settings;
  final _player = AudioPlayer();
  String? _playingVoice;

  @override
  void initState() {
    super.initState();
    _settings = widget.repository.load();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  AdhanVoice _voiceFor(String id) => _voices.firstWhere((voice) => voice.id == id, orElse: () => _voices.first);

  Future<void> _preview(AdhanVoice voice) async {
    try {
      if (_playingVoice == voice.id) {
        await _player.stop();
        if (mounted) setState(() => _playingVoice = null);
        return;
      }
      setState(() => _playingVoice = voice.id);
      await _player.setAsset(voice.assetPath);
      await _player.play();
      if (mounted) setState(() => _playingVoice = null);
    } catch (_) {
      if (mounted) {
        setState(() => _playingVoice = null);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر تشغيل المعاينة، تأكد من الاتصال بالإنترنت')));
      }
    }
  }

  Future<void> _chooseForPrayer(String prayerKey, String prayerName) async {
    final current = _voiceFor(_settings.forPrayer(prayerKey));
    final selected = await showModalBottomSheet<AdhanVoice>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 8), child: Text('صوت أذان $prayerName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('اسمع المعاينة ثم اختر الصوت المناسب لهذه الصلاة', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
              const SizedBox(height: 8),
              for (final voice in _voices)
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: IconButton(icon: Icon(_playingVoice == voice.id ? Icons.stop_circle_outlined : Icons.play_circle_outline_rounded, color: AppColors.emeraldLight), tooltip: 'معاينة', onPressed: () => _preview(voice)),
                    title: Text(voice.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [if (voice.id == current.id) const Icon(Icons.check_circle_rounded, color: AppColors.emeraldLight) else const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted)]),
                    onTap: () => Navigator.of(sheetContext).pop(voice),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    final next = switch (prayerKey) {
      'fajr' => _settings.copyWith(fajr: selected.id),
      'dhuhr' => _settings.copyWith(dhuhr: selected.id),
      'asr' => _settings.copyWith(asr: selected.id),
      'maghrib' => _settings.copyWith(maghrib: selected.id),
      _ => _settings.copyWith(isha: selected.id),
    };
    setState(() => _settings = next);
    await widget.repository.save(next);
  }

  @override
  Widget build(BuildContext context) {
    final prayers = [('fajr', 'الفجر'), ('dhuhr', 'الظهر'), ('asr', 'العصر'), ('maghrib', 'المغرب'), ('isha', 'العشاء')];
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(height: 84, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))), child: Row(children: [IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary), tooltip: 'رجوع'), const Spacer(), const Text('صوت الأذان', style: TextStyle(color: AppColors.emerald, fontSize: 26, fontWeight: FontWeight.w700)), const Spacer(), const SizedBox(width: 48)])),
          Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 32), children: [
            const Text('اختار صوت كل صلاة', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('اضغط على أي صلاة لسماع المعاينات واختيار المؤذن المفضل.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 12),
            Container(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)), child: Column(children: [
              for (var i = 0; i < prayers.length; i++) ...[
                Builder(builder: (_) { final prayer = prayers[i]; final voice = _voiceFor(_settings.forPrayer(prayer.$1)); return Material(color: Colors.transparent, child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), leading: const Icon(Icons.volume_up_outlined, color: AppColors.textMuted), title: Text(prayer.$2, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(voice.name, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)), trailing: const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted), onTap: () => _chooseForPrayer(prayer.$1, prayer.$2))); }),
                if (i < prayers.length - 1) const Divider(height: 1, color: AppColors.border),
              ],
            ])),
          ])),
        ],
      ),
    );
  }
}
