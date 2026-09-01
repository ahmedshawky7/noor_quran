import 'package:flutter/material.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ayah_ref.dart';

/// المحول الوحيد الذي يعرف QuranPageView من الحزمة الخارجية.
class QuranPageViewAdapter extends StatefulWidget {
  const QuranPageViewAdapter({
    super.key,
    required this.initialPage,
    required this.pageCommand,
    required this.selectedAyah,
    required this.onPageChanged,
    required this.onAyahLongPressed,
  });

  final int initialPage;
  final int? pageCommand;
  final AyahRef? selectedAyah;
  final ValueChanged<int> onPageChanged;
  final void Function(int surahNumber, int ayahNumber) onAyahLongPressed;

  @override
  State<QuranPageViewAdapter> createState() => _QuranPageViewAdapterState();
}

class _QuranPageViewAdapterState extends State<QuranPageViewAdapter> {
  late final PageController _pageController;
  int? _lastCommand;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage - 1);
  }

  @override
  void didUpdateWidget(covariant QuranPageViewAdapter oldWidget) {
    super.didUpdateWidget(oldWidget);
    final command = widget.pageCommand;
    if (command == null) {
      // استهلاك الأمر يسمح بإرسال نفس رقم الصفحة مرة أخرى من زر المتابعة.
      _lastCommand = null;
      return;
    }
    if (command != _lastCommand) {
      _lastCommand = command;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _pageController.animateToPage(
          command - 1,
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selectedAyah;
    final highlights = selected == null
        ? <HighlightVerse>[]
        : [
            HighlightVerse(
              surah: selected.surahNumber,
              verseNumber: selected.ayahNumber,
              page: selected.pageNumber,
              color: AppColors.selection,
            ),
          ];

    // الترويسة والبسملة أدناه من الحزمة نفسها. نغيّر لونها فقط عبر Theme.
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.copyWith(
          bodyLarge: const TextStyle(
            color: Color(0xFF2A281F),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: QuranPageView(
        pageController: _pageController,
        highlights: highlights,
        isTajweed: true,
        isDarkMode: false,
        pageBackgroundColor: AppColors.paper,
        onPageChanged: widget.onPageChanged,
        onLongPress: (surah, verse, _) =>
            widget.onAyahLongPressed(surah, verse),
      ),
    );
  }
}
