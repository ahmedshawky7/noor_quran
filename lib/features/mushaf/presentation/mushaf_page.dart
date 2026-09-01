import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noor_quran/features/mushaf/domain/entities/ayah_ref.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/entities/quran_audio_preferences.dart';
import '../domain/entities/quran_verse_search_result.dart';
import 'mushaf_controller.dart';
import 'widgets/mushaf_audio_panel.dart';
import 'widgets/quran_page_view_adapter.dart';
import 'widgets/verse_action_sheet.dart';
import '../../tafsir/domain/entities/tafsir_entry.dart';
import '../../tafsir/presentation/tafsir_page.dart';

class MushafPage extends StatefulWidget {
  const MushafPage({
    super.key,
    required this.controller,
    required this.tafsirRepository,
    this.onExit,
  });

  final MushafController controller;
  final TafsirRepository tafsirRepository;
  final VoidCallback? onExit;

  @override
  State<MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends State<MushafPage> {
  static const _controlsAutoHideDelay = Duration(seconds: 4);

  bool _showControls = true;
  bool _isSeekingPage = false;
  double _seekPage = 1;
  Timer? _hideControlsTimer;
  late final TextEditingController _reciterSearchController;
  late final TextEditingController _mushafSearchController;

  @override
  void initState() {
    super.initState();
    _reciterSearchController = TextEditingController();
    _mushafSearchController = TextEditingController();
    _scheduleControlsAutoHide();
  }

  void _onReaderTapped() {
    _hideControlsTimer?.cancel();
    if (_showControls) {
      setState(() => _showControls = false);
      return;
    }
    setState(() => _showControls = true);
    _scheduleControlsAutoHide();
  }

  void _scheduleControlsAutoHide() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(_controlsAutoHideDelay, () {
      if (mounted && !_isSeekingPage) {
        setState(() => _showControls = false);
      }
    });
  }

  void _keepControlsVisible() {
    _hideControlsTimer?.cancel();
    if (!_showControls) setState(() => _showControls = true);
  }

  void _resumeAutoHide() => _scheduleControlsAutoHide();

  Future<void> _showTafsir(AyahRef ayah) async {
    final surahName = widget.controller.surahs
        .firstWhere((surah) => surah.number == ayah.surahNumber)
        .arabicName;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: TafsirPage(
            ayah: ayah,
            surahName: surahName,
            verseText: widget.controller
                .verseText(ayah)
                .replaceAll(RegExp(r'[\n\r\u2028\u2029]+'), ' ')
                .replaceAll(RegExp(r'[\u00A0\s]+'), ' ')
                .trim(),
            repository: widget.tafsirRepository,
          ),
        ),
      ),
    );
  }

  Future<void> _showActions(int surah, int ayah) async {
    _keepControlsVisible();
    await widget.controller.selectAyah(surah, ayah);
    if (!mounted) return;
    final selected = widget.controller.selectedAyah;
    if (selected == null) return;
    var playbackActionSelected = false;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => VerseActionSheet(
        ayah: selected,
        surahName: widget.controller.currentSurahName,
        surahAyahCount: widget.controller.ayahCountForSurah(selected.surahNumber),
        onPlay: widget.controller.playSelectedAyahNow,
        onAdvancedRecitation: widget.controller.startAdvancedRecitationFrom,
        onPlaybackActionSelected: () => playbackActionSelected = true,
        onTafsir: () => _showTafsir(selected),
        onBookmark: (ayah) async {
          await widget.controller.saveBookmarkForAyah(ayah);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم حفظ علامة عند الآية ${ayah.ayahNumber}')),
            );
          }
        },
        onShare: (ayah) async {
          try {
            final surahName = widget.controller.surahs
                .firstWhere((surah) => surah.number == ayah.surahNumber)
                .arabicName;
            await SharePlus.instance.share(
              ShareParams(
                text: widget.controller.shareTextForAyah(ayah),
                subject: 'آية من سورة $surahName',
              ),
            );
          } on MissingPluginException {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('أغلق التطبيق وشغّله من جديد لإكمال تفعيل المشاركة'),
                ),
              );
            }
          }
        },
      ),
    );
    if (!playbackActionSelected) {
      widget.controller.clearTemporaryAyahSelection(selected);
    }
    _resumeAutoHide();
  }

  void _startSeeking(int currentPage) {
    _keepControlsVisible();
    setState(() {
      _isSeekingPage = true;
      _seekPage = currentPage.toDouble();
    });
  }

  void _changeSeeking(double page) => setState(() => _seekPage = page);

  Future<void> _finishSeeking(double page) async {
    setState(() => _isSeekingPage = false);
    await widget.controller.goToPage(page.round());
    _resumeAutoHide();
  }

  Future<void> _followActivePlaybackAyah() async {
    _keepControlsVisible();
    await widget.controller.followActivePlaybackAyah();
    _resumeAutoHide();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final topInset = MediaQuery.paddingOf(context).top;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _onReaderTapped,
          child: Stack(children: [
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.paper,
                child: QuranPageViewAdapter(
                  initialPage: controller.currentPage,
                  pageCommand: controller.pageCommand,
                  selectedAyah: controller.selectedAyah,
                  onPageChanged: controller.onPageChanged,
                  onAyahLongPressed: _showActions,
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              top: _showControls ? 0 : -(topInset + 130),
              right: 0,
              left: 0,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                  _MushafTopBar(
                    surahName: controller.currentSurahName,
                    juz: controller.currentJuz,
                    isCurrentPageBookmarked: controller.isCurrentPageBookmarked,
                    onSearch: () => _showMushafSearch(context),
                    onBookmark: () => _showBookmarkActions(context),
                    onExit: () async {
                      await widget.controller.stop();
                      if (mounted) widget.onExit?.call();
                    },
                  ),

              ]),
            ),
            Positioned(
              bottom: 13,
              left: 12,
              right: 12,
              child: IgnorePointer(
                ignoring: !_showControls,
                child: AnimatedOpacity(
                  opacity: _showControls ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    MushafAudioPanel(
                      ayah: controller.activePlaybackAyah ?? controller.selectedAyah,
                      status: controller.audioStatus,
                      downloadProgress: controller.downloadProgress,
                      downloadMode: controller.downloadMode,
                      speed: controller.speed,
                      surahName: controller.playbackSurahName,
                      reciterName: controller.reciter.name,
                      onToggle: controller.togglePlayback,
                      onPrevious: controller.playPrevious,
                      onNext: controller.playNext,
                      onStop: controller.stop,
                      onDownloadModeTap: () => _showDownloadModePicker(context),
                      onSpeedChanged: controller.setSpeed,
                      onReciterTap: () => _showReciterPicker(context),
                    ),
                    const SizedBox(height: 8),
                    _PageSlider(
                      currentPage: controller.currentPage,
                      visiblePage: _isSeekingPage ? _seekPage : controller.currentPage.toDouble(),
                      onChangeStart: _startSeeking,
                      onChanged: _changeSeeking,
                      onChangeEnd: _finishSeeking,
                      activeAyahNumber: controller.activePlaybackAyah?.ayahNumber,
                      onFollowActive: _followActivePlaybackAyah,
                    ),
                  ]),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  Future<void> _showMushafSearch(BuildContext context) async {
    _keepControlsVisible();
    _mushafSearchController.clear();
    var searchQuery = '';
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final controller = widget.controller;
          final searchResults = searchQuery.trim().isEmpty
              ? <QuranVerseSearchResult>[]
              : controller.searchVerses(searchQuery);
          final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
          final screenHeight = MediaQuery.sizeOf(context).height;
          final availableHeight = screenHeight - keyboardInset;
          final desiredSheetHeight = screenHeight * .72;
          final sheetHeight = desiredSheetHeight < availableHeight
              ? desiredSheetHeight
              : availableHeight;
          return AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(bottom: keyboardInset),
            child: Material(
              color: AppColors.surfaceRaised,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: SizedBox(
                height: sheetHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(children: [
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
                      'البحث في القرآن',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _mushafSearchController,
                      autofocus: true,
                      onChanged: (value) => setSheetState(() => searchQuery = value),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'اكتب كلمة من الآية، مثل الرحمن',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: searchQuery.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'مسح البحث',
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _mushafSearchController.clear();
                                  setSheetState(() => searchQuery = '');
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: searchQuery.trim().isEmpty
                          ? const Center(
                              child: Text(
                                'اكتب كلمة لعرض الآيات المطابقة',
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            )
                          : searchResults.isEmpty
                              ? const Center(
                                  child: Text(
                                    'لا توجد آيات مطابقة لهذه العبارة',
                                    style: TextStyle(color: AppColors.textMuted),
                                  ),
                                )
                              : ListView.separated(
                                  padding: EdgeInsets.zero,
                                  itemCount: searchResults.length,
                                  separatorBuilder: (_, _) => const Divider(
                                    height: 1,
                                    color: AppColors.border,
                                  ),
                                  itemBuilder: (context, index) {
                                    final result = searchResults[index];
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () async {
                                          await controller.selectAyahFromSearch(
                                            result.ayah.surahNumber,
                                            result.ayah.ayahNumber,
                                          );
                                          if (sheetContext.mounted) {
                                            Navigator.of(sheetContext).pop();
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: [
                                                    Text(
                                                      result.text,
                                                      textDirection: TextDirection.rtl,
                                                      textAlign: TextAlign.right,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 15,
                                                        height: 1.55,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      'سورة ${result.surahName} • الآية ${result.ayah.ayahNumber} • الصفحة ${result.ayah.pageNumber}',
                                                      textDirection: TextDirection.rtl,
                                                      textAlign: TextAlign.right,
                                                      style: const TextStyle(
                                                        color: AppColors.textMuted,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
    _resumeAutoHide();
  }

  Future<void> _showDownloadModePicker(BuildContext context) async {
    _keepControlsVisible();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final controller = widget.controller;
          return Material(
            color: AppColors.surfaceRaised,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'وضع تنزيل الصوت',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                ...AudioDownloadMode.values.map((mode) {
                  final isSelected = mode == controller.downloadMode;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: Text(
                      mode.title,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? AppColors.emeraldLight : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      mode.description,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.emeraldLight)
                        : const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
                    onTap: () async {
                      if (!isSelected) await controller.setDownloadMode(mode);
                      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                    },
                  );
                }),
              ]),
            ),
          );
        },
      ),
    );
    _resumeAutoHide();
  }

  Future<void> _showReciterPicker(BuildContext context) async {
    _keepControlsVisible();
    _reciterSearchController.clear();
    var searchQuery = '';
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final controller = widget.controller;
          final query = _reciterSearchKey(searchQuery);
          final filteredReciters = controller.reciters.where((reciter) {
            return _reciterSearchKey(reciter.name).contains(query);
          }).toList();
          final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
          final screenHeight = MediaQuery.sizeOf(context).height;
          final availableHeight = screenHeight - keyboardInset;
          final desiredSheetHeight = screenHeight * .72;
          final sheetHeight = desiredSheetHeight < availableHeight
              ? desiredSheetHeight
              : availableHeight;
          return AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(bottom: keyboardInset),
            child: Material(
              color: AppColors.surfaceRaised,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: SizedBox(
                height: sheetHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(children: [
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
                    'اختيار القارئ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _reciterSearchController,
                    onChanged: (value) => setSheetState(() => searchQuery = value),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن اسم الشيخ',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: searchQuery.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'مسح البحث',
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _reciterSearchController.clear();
                                setSheetState(() => searchQuery = '');
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filteredReciters.isEmpty
                        ? const Center(
                            child: Text(
                              'لا يوجد قارئ بهذا الاسم',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          )
                        : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: filteredReciters.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final reciter = filteredReciters[index];
                        final isSelected = reciter == controller.reciter;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? AppColors.emerald.withOpacity(.18)
                                : AppColors.surface,
                            child: Icon(
                              Icons.record_voice_over_rounded,
                              color: isSelected
                                  ? AppColors.emeraldLight
                                  : AppColors.textMuted,
                            ),
                          ),
                          title: Text(
                            reciter.name,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? AppColors.emeraldLight
                                  : AppColors.textPrimary,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: AppColors.emeraldLight)
                              : const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
                          onTap: () async {
                            if (!isSelected) await controller.selectReciter(reciter);
                            if (sheetContext.mounted) Navigator.of(sheetContext).pop();
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
        },
      ),
    );
    _reciterSearchController.clear();
    _resumeAutoHide();
  }

  String _reciterSearchKey(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');
  }

  Future<void> _showBookmarkActions(BuildContext context) async {
    _keepControlsVisible();
    final controller = widget.controller;
    if (!controller.hasBookmark) {
      await controller.saveBookmark();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ المرجعية في هذه الصفحة')),
        );
      }
      _resumeAutoHide();
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Material(
        color: AppColors.surfaceRaised,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'العلامة المرجعية',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (!controller.isCurrentPageBookmarked)
              ListTile(
                leading: const Icon(Icons.my_location_rounded),
                title: const Text('الانتقال إلى المرجعية'),
                onTap: () async {
                  await controller.goToBookmark();
                  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                },
              ),
            ListTile(
              leading: const Icon(Icons.bookmark_add_rounded),
              title: Text(
                controller.isCurrentPageBookmarked
                    ? 'تحديث المرجعية هنا'
                    : 'حفظ المرجعية في هذه الصفحة',
              ),
              onTap: () async {
                await controller.saveBookmark();
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_remove_rounded, color: Colors.redAccent),
              title: const Text('حذف المرجعية', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                await controller.clearBookmark();
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
            ),
          ]),
        ),
      ),
    );
    _resumeAutoHide();
  }

  Future<void> _showSettings(BuildContext context) async {
    _keepControlsVisible();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final controller = widget.controller;
          final progress = controller.downloadProgress;
          return Material(
            color: AppColors.surfaceRaised,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .82),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 42, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 16),
                const Text('إعدادات التلاوة والتنزيل', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 18),
                DropdownButtonFormField<QuranReciter>(
                  value: controller.reciter,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceRaised,
                  decoration: const InputDecoration(labelText: 'القارئ', prefixIcon: Icon(Icons.record_voice_over_rounded)),
                  items: controller.reciters.map((reciter) => DropdownMenuItem(
                    value: reciter,
                    child: Text('${reciter.name} • ${reciter.bitrateLabel}'),
                  )).toList(),
                  onChanged: (value) { if (value != null) controller.selectReciter(value); },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<AudioDownloadMode>(
                  value: controller.downloadMode,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceRaised,
                  decoration: const InputDecoration(labelText: 'وضع تنزيل الصوت', prefixIcon: Icon(Icons.download_for_offline_rounded)),
                  items: AudioDownloadMode.values.map((mode) => DropdownMenuItem(
                    value: mode,
                    child: Text(mode.title, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (value) { if (value != null) controller.setDownloadMode(value); },
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(controller.downloadMode.description, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ),
                const SizedBox(height: 8),
                if (progress.isDownloading) ...[
                  LinearProgressIndicator(value: progress.fraction, color: AppColors.emeraldLight),
                  const SizedBox(height: 5),
                  Text(progress.text, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ] else
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(
                    onPressed: controller.downloadCurrentSurah,
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('تنزيل السورة الحالية الآن'),
                  )),
                const SizedBox(height: 12),
                Row(children: [
                  const Text('السرعة'),
                  Expanded(child: Slider(value: controller.speed, min: .75, max: 1.5, divisions: 3, label: '${controller.speed}x', onChanged: controller.setSpeed)),
                ]),
                SwitchListTile(title: const Text('تكرار الآية'), value: controller.repeatAyah, onChanged: controller.setRepeatAyah),
                SwitchListTile(title: const Text('تكرار السورة'), value: controller.repeatSurah, onChanged: controller.setRepeatSurah),
              ]),
              ),
            ),
          );
        },
      ),
    );
    _resumeAutoHide();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _reciterSearchController.dispose();
    _mushafSearchController.dispose();
    super.dispose();
  }
}

class _MushafTopBar extends StatelessWidget {
  const _MushafTopBar({
    required this.surahName,
    required this.juz,
    required this.isCurrentPageBookmarked,
    required this.onSearch,
    required this.onBookmark,
    this.onExit,
  });

  final String surahName;
  final int juz;
  final bool isCurrentPageBookmarked;
  final VoidCallback onSearch;
  final VoidCallback onBookmark;
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 5,
        right: 10,
        left: 10,
        bottom: 7,
      ),
      color: const Color(0xF1101727),
      child: Row(children: [
        IconButton(
          onPressed: onExit,
          icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.textPrimary),
          tooltip: 'قائمة السور',
        ),
        const Spacer(),
        Column(children: [
          Text(
            'سورة $surahName',
            style: const TextStyle(
              color: AppColors.emeraldLight,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text('الجزء $juz', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ]),
        const Spacer(),
        IconButton(
          onPressed: onSearch,
          icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
          tooltip: 'بحث',
        ),
        IconButton(
          onPressed: onBookmark,
          icon: Icon(
            isCurrentPageBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            color: isCurrentPageBookmarked
                ? AppColors.emeraldLight
                : AppColors.textPrimary,
          ),
          tooltip: 'علامة مرجعية',
        ),
      ]),
    );
  }
}

class _PageSlider extends StatelessWidget {
  const _PageSlider({
    required this.currentPage,
    required this.visiblePage,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
    this.activeAyahNumber,
    this.onFollowActive,
  });

  final int currentPage;
  final double visiblePage;
  final ValueChanged<int> onChangeStart;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;
  final int? activeAyahNumber;
  final VoidCallback? onFollowActive;

  @override
  Widget build(BuildContext context) {
    final page = visiblePage.clamp(1, 604).round();
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 3, 12, 5),
      decoration: BoxDecoration(
        color: const Color(0xED101727),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF26374A)),
      ),
      child: Row(children: [
        Tooltip(
          message: activeAyahNumber == null
              ? 'لا توجد تلاوة نشطة'
              : 'الانتقال إلى الآية النشطة',
          child: InkWell(
            onTap: activeAyahNumber == null ? null : onFollowActive,
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 36,
              height: 35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.near_me_rounded,
                    color: activeAyahNumber == null
                        ? AppColors.textMuted
                        : AppColors.emeraldLight,
                    size: 19,
                  ),
                  if (activeAyahNumber != null)
                    Text(
                      '$activeAyahNumber',
                      style: const TextStyle(
                        color: AppColors.emeraldLight,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        Text('صفحة $page', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 12)),
        Expanded(
          child: Slider(
            value: visiblePage.clamp(1, 604).toDouble(),
            min: 1,
            max: 604,
            divisions: 603,
            activeColor: AppColors.emeraldLight,
            inactiveColor: const Color(0xFF344152),
            onChangeStart: (_) => onChangeStart(currentPage),
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
        Text('$page / 604', textDirection: TextDirection.ltr, style: const TextStyle(color: AppColors.emeraldLight, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
