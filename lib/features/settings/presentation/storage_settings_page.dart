import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_surface.dart';
import '../../mushaf/domain/repositories/quran_audio_repository.dart';
import '../../mushaf/presentation/mushaf_controller.dart';

class StorageSettingsPage extends StatefulWidget {
  const StorageSettingsPage({super.key, required this.mushafController});

  final MushafController mushafController;

  @override
  State<StorageSettingsPage> createState() => _StorageSettingsPageState();
}

class _StorageSettingsPageState extends State<StorageSettingsPage> {
  AudioStorageStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final stats = await widget.mushafController.audioStorageStats();
    if (mounted) setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} ك.ب';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} م.ب';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} ج.ب';
  }

  Future<void> _clearAudio() async {
    final stats = _stats;
    if (stats == null || stats.fileCount == 0) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الملفات الصوتية؟'),
        content: Text('سيتم حذف ${stats.fileCount} ملف صوتي وتحرير ${_formatBytes(stats.bytes)}. لن يتم حذف إعدادات القارئ.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.mushafController.clearAudioCache();
    await _refresh();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الملفات الصوتية المنزلة')));
  }

  Future<void> _showReciterDetails(AudioStorageReciterStats item) async {
    final names = {for (final surah in widget.mushafController.surahs) surah.number: surah.arabicName};
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .72,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(children: [
                  const Icon(Icons.record_voice_over_outlined, color: AppColors.emeraldLight),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item.reciterName, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))),
                  Text('${item.fileCount} ملف', style: const TextStyle(color: AppColors.textMuted)),
                ]),
              ),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: item.surahs.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (_, index) {
                    final surah = item.surahs[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                      leading: CircleAvatar(backgroundColor: AppColors.surfaceRaised, child: Text('${surah.surahNumber}', style: const TextStyle(color: AppColors.gold, fontSize: 12))),
                      title: Text(names[surah.surahNumber] ?? 'سورة ${surah.surahNumber}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${surah.fileCount} آية — ${_formatBytes(surah.bytes)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      trailing: const Icon(Icons.delete_outline_rounded, color: AppColors.gold),
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: Text('حذف ${names[surah.surahNumber] ?? 'السورة'}؟'),
                            content: Text('سيتم حذف ${surah.fileCount} ملف وتحرير ${_formatBytes(surah.bytes)} لهذا القارئ فقط.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
                              FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('حذف')),
                            ],
                          ),
                        );
                        if (confirmed != true) return;
                        await widget.mushafController.deleteSurahAudio(item.reciterId, surah.surahNumber);
                        if (!mounted) return;
                        Navigator.pop(sheetContext);
                        await _refresh();
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف السورة من هذا القارئ')));
                      },
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _showTafsirInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('التفسير الميسر'),
        content: const Text('التفسير الميسر مدمج داخل التطبيق ويعمل أوفلاين، لذلك لا يحتاج إلى تنزيل منفصل ولا يمكن حذفه من مساحة التخزين. يمكن حذف التفاسير الإضافية مستقبلاً إذا تمت إضافتها كملفات اختيارية.'),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('حسناً'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('مساحة التخزين')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          AppSurface(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.storage_rounded, color: AppColors.emeraldLight, size: 30),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('إجمالي التلاوات المحفوظة', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Text(_loading ? 'جارٍ الحساب...' : '${stats?.fileCount ?? 0} ملف صوتي — ${_formatBytes(stats?.bytes ?? 0)}', style: const TextStyle(color: AppColors.textMuted)),
                ])),
              ]),
              if (!_loading && stats != null) ...[
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(child: _StatTile(label: 'الملفات', value: '${stats.fileCount}')),
                  const SizedBox(width: 10),
                  Expanded(child: _StatTile(label: 'القُرّاء', value: '${stats.byReciter.length}')),
                  const SizedBox(width: 10),
                  Expanded(child: _StatTile(label: 'السور', value: '${stats.byReciter.fold<int>(0, (sum, item) => sum + item.surahNumbers.length)}')),
                ]),
              ],
            ]),
          ),
          const SizedBox(height: 20),
          if (!_loading && stats != null && stats.byReciter.isNotEmpty) ...[
            const Text('التوزيع حسب القارئ', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            AppSurface(
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (var index = 0; index < stats.byReciter.length; index++) ...[
                  _ReciterStat(item: stats.byReciter[index], formatBytes: _formatBytes, onTap: () => _showReciterDetails(stats.byReciter[index])),
                  if (index < stats.byReciter.length - 1) const Divider(height: 1, color: AppColors.border),
                ],
              ]),
            ),
            const SizedBox(height: 20),
          ],
          const Text('إدارة الملفات', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _StorageAction(
            icon: Icons.headphones_rounded,
            title: 'التلاوات المنزلة',
            subtitle: _loading ? 'جارٍ حساب الحجم' : '${stats?.fileCount ?? 0} ملف — ${_formatBytes(stats?.bytes ?? 0)}',
            onTap: stats?.fileCount == 0 ? null : _clearAudio,
          ),
          const SizedBox(height: 12),
          _StorageAction(
            icon: Icons.menu_book_rounded,
            title: 'التفسير الميسر',
            subtitle: 'مدمج داخل التطبيق — يعمل أوفلاين',
            onTap: _showTafsirInfo,
            canDelete: false,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: AppColors.surfaceRaised, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [Text(value, style: const TextStyle(color: AppColors.emeraldLight, fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11))]),
      );
}

class _ReciterStat extends StatelessWidget {
  const _ReciterStat({required this.item, required this.formatBytes, required this.onTap});
  final AudioStorageReciterStats item;
  final String Function(int) formatBytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: const Icon(Icons.record_voice_over_outlined, color: AppColors.emeraldLight),
          title: Text(item.reciterName, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${item.fileCount} ملف • ${item.surahNumbers.length} سورة', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(formatBytes(item.bytes), style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)), const SizedBox(width: 8), const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted)]),
          onTap: onTap,
        ),
      );
}

class _StorageAction extends StatelessWidget {
  const _StorageAction({required this.icon, required this.title, required this.subtitle, required this.onTap, this.canDelete = true});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool canDelete;

  @override
  Widget build(BuildContext context) => AppSurface(
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(icon, color: onTap == null ? AppColors.textMuted : AppColors.emeraldLight),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          trailing: Icon(canDelete ? Icons.delete_outline_rounded : Icons.info_outline_rounded, color: canDelete ? AppColors.gold : AppColors.textMuted),
            onTap: onTap,
          ),
        ),
      );
}
