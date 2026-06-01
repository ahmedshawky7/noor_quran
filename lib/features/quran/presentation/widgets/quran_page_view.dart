import 'package:flutter/material.dart';
import '../../domain/entities/ayah.dart';
import 'mushaf_page.dart';

class QuranPageView extends StatefulWidget {
  final String surahName;
  final List<Ayah> ayahs;
  final int surahId;
  final int? currentAyah;
  final int? selectedAyah;
  final Function(int?)? onSelectAyah;
  final VoidCallback? onNextSurah;
  final VoidCallback? onPreviousSurah;
  final int? initialPageIndex; // 0 = أول صفحة، -1 = آخر صفحة

  const QuranPageView({
    super.key,
    required this.surahName,
    required this.ayahs,
    required this.surahId,
    required this.currentAyah,
    this.selectedAyah,
    this.onSelectAyah,
    this.onNextSurah,
    this.onPreviousSurah,
    this.initialPageIndex,
  });

  @override
  State<QuranPageView> createState() => _QuranPageViewState();
}

class _QuranPageViewState extends State<QuranPageView> {
  late final PageController _pageController;
  int _currentIndex = 0;
  DateTime? _lastSwipeTime;

  List<MapEntry<int, List<Ayah>>> _getSortedPages() {
    final pages = <int, List<Ayah>>{};
    for (var ayah in widget.ayahs) {
      pages.putIfAbsent(ayah.page, () => []);
      pages[ayah.page]!.add(ayah);
    }
    return pages.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  }

  int _resolveInitialPage(int totalPages) {
    if (widget.initialPageIndex == null) return 0;
    if (widget.initialPageIndex! < 0) return totalPages - 1;
    return widget.initialPageIndex!.clamp(0, totalPages - 1);
  }

  @override
  void initState() {
    super.initState();
    final sortedPages = _getSortedPages();
    final initialPage = _resolveInitialPage(sortedPages.length);
    _currentIndex = initialPage;
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void didUpdateWidget(covariant QuranPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentAyah != null && widget.currentAyah != oldWidget.currentAyah) {
      _jumpToPageOfAyah(widget.currentAyah!);
    }
  }

  void _jumpToPageOfAyah(int ayahNumber) {
    final ayah = widget.ayahs.firstWhere(
          (e) => e.ayahNumber == ayahNumber,
      orElse: () => widget.ayahs.first,
    );
    final pages = widget.ayahs.map((e) => e.page).toSet().toList()..sort();
    final targetPageIndex = pages.indexOf(ayah.page);
    if (targetPageIndex != -1 && _pageController.hasClients) {
      _pageController.animateToPage(
        targetPageIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
      _currentIndex = targetPageIndex;
    }
  }

  void _handleHorizontalSwipe(double velocity, int totalPages) {
    final now = DateTime.now();
    if (_lastSwipeTime != null &&
        now.difference(_lastSwipeTime!).inMilliseconds < 600) {
      return; // منع الاستجابة المتكررة السريعة
    }

    // ◄◄◄ سحب لليمين (velocity موجب) = الانتقال للصفحة التالية في المصحف العربي
    if (velocity > 200) {
      if (_currentIndex < totalPages - 1) {
        // قلب صفحة داخل السورة
        _pageController.animateToPage(
          _currentIndex + 1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      } else {
        // آخر صفحة → الانتقال للسورة التالية (أول صفحة فيها)
        _lastSwipeTime = now;
        widget.onNextSurah?.call();
      }
    }
    // ◄◄◄ سحب لليسار (velocity سالب) = العودة للصفحة السابقة في المصحف العربي
    else if (velocity < -200) {
      if (_currentIndex > 0) {
        // رجوع صفحة داخل السورة
        _pageController.animateToPage(
          _currentIndex - 1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      } else {
        // أول صفحة → الانتقال للسورة السابقة (آخر صفحة فيها)
        _lastSwipeTime = now;
        widget.onPreviousSurah?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedPages = _getSortedPages();

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        _handleHorizontalSwipe(details.primaryVelocity ?? 0, sortedPages.length);
      },
      child: PageView.builder(
        controller: _pageController,
        reverse: false, // نتركه false لأننا نتحكم بالكامل يدوياً عبر الـ GestureDetector وعكسنا الاتجاه هناك
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedPages.length,
        onPageChanged: (index) => _currentIndex = index,
        itemBuilder: (context, index) {
          final entry = sortedPages[index];
          return MushafPage(
            page: entry.key,
            ayahs: entry.value,
            surahName: widget.surahName,
            surahId: widget.surahId,
            currentAyah: widget.currentAyah,
            selectedAyah: widget.selectedAyah,
            onSelectAyah: widget.onSelectAyah,
            isFirstPageOfSurah: entry.value.any((e) => e.ayahNumber == 1),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}