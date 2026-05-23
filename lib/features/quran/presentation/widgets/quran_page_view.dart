import 'package:flutter/material.dart';
import '../../domain/entities/ayah.dart';
import 'mushaf_page.dart';

class QuranPageView extends StatefulWidget {
  final String surahName;
  final List<Ayah> ayahs;
  final int surahId;
  final int? currentAyah;
  final VoidCallback? onNextSurah;     // ◄ دالة السورة التالية
  final VoidCallback? onPreviousSurah; // ◄ دالة السورة السابقة

  const QuranPageView({
    super.key,
    required this.surahName,
    required this.ayahs,
    required this.surahId,
    required this.currentAyah,
    this.onNextSurah,
    this.onPreviousSurah,
  });

  @override
  State<QuranPageView> createState() => _QuranPageViewState();
}

class _QuranPageViewState extends State<QuranPageView> {
  final PageController _pageController = PageController();

  @override
  void didUpdateWidget(covariant QuranPageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentAyah != null) {
      _jumpToPageOfAyah(widget.currentAyah!);
    }
  }

  void _jumpToPageOfAyah(int ayahNumber) {
    final ayah = widget.ayahs.firstWhere(
          (e) => e.ayahNumber == ayahNumber,
    );

    final pages = widget.ayahs.map((e) => e.page).toSet().toList()
      ..sort();

    final targetPageIndex = pages.indexOf(ayah.page);

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        targetPageIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <int, List<Ayah>>{};

    for (var ayah in widget.ayahs) {
      pages.putIfAbsent(ayah.page, () => []);
      pages[ayah.page]!.add(ayah);
    }

    final sortedPages =
    pages.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    // ◄ استخدام NotificationListener لالتقاط نهاية التمرير والسحب الزائد
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is OverscrollNotification) {
          if (notification.overscroll > 0) {
            // سحب إضافي من اليسار لليمين (نهاية السورة الحالية)
            widget.onNextSurah?.call();
          } else if (notification.overscroll < 0) {
            // سحب إضافي من اليمين لليسار (بداية السورة الحالية)
            widget.onPreviousSurah?.call();
          }
        }
        return false;
      },
      child: PageView.builder(
        controller: _pageController,
        reverse: false, // ◄ تم تغييرها إلى false لعكس اتجاه السحب ليصبح طبيعياً
        physics: const BouncingScrollPhysics(), // ◄ ضرورية لالتقاط الـ Overscroll بشكل سليم
        itemCount: sortedPages.length,
        itemBuilder: (context, index) {
          final entry = sortedPages[index];

          return MushafPage(
            page: entry.key,
            ayahs: entry.value,
            surahName: widget.surahName,
            surahId: widget.surahId,
            currentAyah: widget.currentAyah,
            isFirstPageOfSurah: entry.value.any((e) => e.ayahNumber == 1),
          );
        },
      ),
    );
  }
}