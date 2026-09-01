import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/advanced_recitation_mode.dart';
import '../../domain/entities/advanced_recitation_repeat.dart';
import '../../domain/entities/ayah_ref.dart';

class VerseActionSheet extends StatelessWidget {
  const VerseActionSheet({
    super.key,
    required this.ayah,
    required this.surahName,
    required this.surahAyahCount,
    required this.onPlay,
    required this.onAdvancedRecitation,
    required this.onPlaybackActionSelected,
    required this.onTafsir,
    required this.onBookmark,
    required this.onShare,
  });

  final AyahRef ayah;
  final String surahName;
  final int surahAyahCount;
  final VoidCallback onPlay;
  final VoidCallback onPlaybackActionSelected;
  final VoidCallback onTafsir;
  final Future<void> Function(AyahRef ayah) onBookmark;
  final Future<void> Function(AyahRef ayah) onShare;
  final Future<void> Function(
    AyahRef start,
    AdvancedRecitationMode mode, {
    int? untilAyahNumber,
    required AdvancedRecitationRepeat repeat,
    required int repeatCount,
  }) onAdvancedRecitation;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '$surahName — الآية ${ayah.ayahNumber}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _Action(
              icon: Icons.play_arrow_rounded,
              label: 'تشغيل التلاوة',
              color: AppColors.emeraldLight,
              onTap: () {
                onPlaybackActionSelected();
                onPlay();
              },
            ),
            _Action(
              icon: Icons.tune_rounded,
              label: 'التلاوة المتقدمة',
              color: AppColors.gold,
              dismissOnTap: false,
              onTap: () => _showAdvancedOptions(context),
            ),
            _Action(
              icon: Icons.menu_book_outlined,
              label: 'التفسير',
              color: AppColors.gold,
              onTap: onTafsir,
            ),
            _Action(
              icon: Icons.bookmark_add_outlined,
              label: 'إضافة علامة مرجعية',
              color: AppColors.emeraldLight,
              onTap: () => onBookmark(ayah),
            ),
            _Action(
              icon: Icons.share_outlined,
              label: 'مشاركة الآية',
              color: AppColors.emeraldLight,
              onTap: () => onShare(ayah),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAdvancedOptions(BuildContext parentContext) async {
    AdvancedRecitationMode? selectedMode;
    var untilAyahNumber = ayah.ayahNumber;
    var repeatRange = false;
    var repeatAyah = false;
    var repeatSurah = false;
    var rangeRepeatCount = 3;
    var ayahRepeatCount = 3;

    await showModalBottomSheet<void>(
      context: parentContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final canStart = selectedMode != null || repeatAyah || repeatSurah;
          return Material(
            color: AppColors.surfaceRaised,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * .88,
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'التلاوة المتقدمة',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'اختر نطاق التلاوة أو نوع التكرار',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  ...AdvancedRecitationMode.values.map(
                    (mode) => _AdvancedOption(
                      mode: mode,
                      selected: selectedMode == mode,
                      onTap: () => setSheetState(() {
                        selectedMode = mode;
                        repeatAyah = false;
                        repeatSurah = false;
                        if (mode == AdvancedRecitationMode.continuous) {
                          repeatRange = false;
                        }
                      }),
                    ),
                  ),
                  if (selectedMode == AdvancedRecitationMode.untilAyah)
                    _InlineUntilAyahPicker(
                      selectedAyah: untilAyahNumber,
                      firstAyah: ayah.ayahNumber,
                      lastAyah: surahAyahCount,
                      onChanged: (value) => setSheetState(() => untilAyahNumber = value),
                    ),
                  const Divider(height: 28, color: AppColors.border),
                  const Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      'التكرار',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _RepeatSwitchTile(
                    label: 'تكرار النطاق',
                    value: repeatRange,
                    enabled: selectedMode != null &&
                        selectedMode != AdvancedRecitationMode.continuous,
                    onChanged: (value) => setSheetState(() {
                      repeatRange = value;
                      if (value) {
                        repeatAyah = false;
                        repeatSurah = false;
                      }
                    }),
                  ),
                  if (selectedMode == null)
                    const Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Padding(
                        padding: EdgeInsets.only(right: 8, bottom: 8),
                        child: Text(
                          'اختر أولاً نهاية الصفحة أو السورة أو آية محددة لتكرار النطاق.',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ),
                    ),
                  if (repeatRange)
                    _InlineRepeatCounter(
                      count: rangeRepeatCount,
                      onDecrement: rangeRepeatCount > 1
                          ? () => setSheetState(() => rangeRepeatCount--)
                          : null,
                      onIncrement: rangeRepeatCount < 99
                          ? () => setSheetState(() => rangeRepeatCount++)
                          : null,
                    ),
                  _RepeatSwitchTile(
                    label: 'تكرار الآية',
                    value: repeatAyah,
                    onChanged: (value) => setSheetState(() {
                      repeatAyah = value;
                      if (value) {
                        selectedMode = null;
                        repeatRange = false;
                        repeatSurah = false;
                      }
                    }),
                  ),
                  if (repeatAyah)
                    _InlineRepeatCounter(
                      count: ayahRepeatCount,
                      onDecrement: ayahRepeatCount > 1
                          ? () => setSheetState(() => ayahRepeatCount--)
                          : null,
                      onIncrement: ayahRepeatCount < 99
                          ? () => setSheetState(() => ayahRepeatCount++)
                          : null,
                    ),
                  _RepeatSwitchTile(
                    label: 'تكرار السورة',
                    value: repeatSurah,
                    onChanged: (value) => setSheetState(() {
                      repeatSurah = value;
                      if (value) {
                        selectedMode = null;
                        repeatRange = false;
                        repeatAyah = false;
                      }
                    }),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: canStart
                          ? () async {
                              final repeat = repeatAyah
                                  ? AdvancedRecitationRepeat.ayah
                                  : repeatRange
                                      ? AdvancedRecitationRepeat.range
                                      : repeatSurah
                                          ? AdvancedRecitationRepeat.surah
                                          : AdvancedRecitationRepeat.none;
                              final repeatCount = repeat == AdvancedRecitationRepeat.ayah
                                  ? ayahRepeatCount
                                  : repeat == AdvancedRecitationRepeat.range
                                      ? rangeRepeatCount
                                      : 0;
                              final playbackMode = selectedMode ??
                                  AdvancedRecitationMode.continuous;
                              if (!sheetContext.mounted || !parentContext.mounted) return;
                              onPlaybackActionSelected();
                              Navigator.of(sheetContext).pop();
                              Navigator.of(parentContext).pop();
                              await onAdvancedRecitation(
                                ayah,
                                playbackMode,
                                untilAyahNumber: selectedMode ==
                                        AdvancedRecitationMode.untilAyah
                                    ? untilAyahNumber
                                    : null,
                                repeat: repeat,
                                repeatCount: repeatCount,
                              );
                            }
                          : null,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        canStart
                            ? 'بدء التلاوة'
                            : 'اختر طريقة التلاوة أو التكرار',
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InlineUntilAyahPicker extends StatelessWidget {
  const _InlineUntilAyahPicker({
    required this.selectedAyah,
    required this.firstAyah,
    required this.lastAyah,
    required this.onChanged,
  });

  final int selectedAyah;
  final int firstAyah;
  final int lastAyah;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonFormField<int>(
        value: selectedAyah,
        isExpanded: true,
        dropdownColor: AppColors.surfaceRaised,
        decoration: const InputDecoration(
          labelText: 'التوقف عند الآية',
          border: InputBorder.none,
        ),
        items: List.generate(
          lastAyah - firstAyah + 1,
          (index) {
            final number = firstAyah + index;
            return DropdownMenuItem(value: number, child: Text('الآية $number'));
          },
        ),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

class _AdvancedOption extends StatelessWidget {
  const _AdvancedOption({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final AdvancedRecitationMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          child: Row(children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.emeraldLight : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    mode.title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mode.description,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _RepeatSwitchTile extends StatelessWidget {
  const _RepeatSwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Material(
        color: AppColors.surface,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: borderRadius,
          ),
          child: SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            title: Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: enabled ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: AppColors.emeraldLight,
            controlAffinity: ListTileControlAffinity.trailing,
          ),
        ),
      ),
    );
  }
}

class _InlineRepeatCounter extends StatelessWidget {
  const _InlineRepeatCounter({
    required this.count,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int count;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        const Text('التكرارات', style: TextStyle(fontWeight: FontWeight.w700)),
        const Spacer(),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.emeraldLight,
          ),
        ),
        const SizedBox(width: 10),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                tooltip: 'تقليل العدد',
                onPressed: onDecrement,
                icon: const Icon(Icons.remove_rounded),
              ),
              Container(width: 1, height: 26, color: AppColors.border),
              IconButton(
                tooltip: 'زيادة العدد',
                onPressed: onIncrement,
                icon: const Icon(Icons.add_rounded),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.dismissOnTap = true,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool dismissOnTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(label, textAlign: TextAlign.right),
      onTap: () {
        if (dismissOnTap) Navigator.pop(context);
        onTap();
      },
    );
  }
}
