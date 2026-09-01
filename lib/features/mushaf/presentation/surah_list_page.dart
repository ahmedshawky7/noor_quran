import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_surface.dart';
import '../../../core/widgets/qalam_header.dart';
import '../domain/entities/surah_summary.dart';
import 'mushaf_controller.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({
    super.key,
    required this.controller,
    required this.onOpenMushaf,
    required this.onOpenQibla,
    required this.onOpenSettings,
  });

  final MushafController controller;
  final VoidCallback onOpenMushaf;
  final VoidCallback onOpenQibla;
  final VoidCallback onOpenSettings;

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  String _query = '';
  bool _isOpening = false;

  List<SurahSummary> get _visibleSurahs {
    final query = _query.trim();
    if (query.isEmpty) return widget.controller.surahs;
    return widget.controller.surahs.where((surah) {
      return surah.arabicName.contains(query) || surah.number.toString() == query;
    }).toList();
  }

  Future<void> _openSurah(SurahSummary surah) async {
    setState(() => _isOpening = true);
    try {
      await widget.controller.openSurah(surah.number);
      if (mounted) widget.onOpenMushaf();
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surahs = _visibleSurahs;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          QalamHeader(
            onSettingsPressed: widget.onOpenSettings,
            trailing: IconButton(
              onPressed: widget.onOpenQibla,
              icon: const Icon(Icons.explore_outlined, color: AppColors.emeraldLight),
              tooltip: 'القبلة',
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'القرآن الكريم',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'اختر سورة لبدء القراءة من أول آية',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    textDirection: TextDirection.rtl,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'ابحث باسم السورة أو رقمها',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search, color: AppColors.emeraldLight),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.emerald),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Stack(
                      children: [
                        ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: surahs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 11),
                          itemBuilder: (context, index) {
                            final surah = surahs[index];
                            return _SurahTile(
                              surah: surah,
                              onTap: _isOpening ? null : () => _openSurah(surah),
                            );
                          },
                        ),
                        if (_isOpening)
                          const ColoredBox(
                            color: Color(0x88091110),
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.emeraldLight),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  const _SurahTile({required this.surah, required this.onTap});

  final SurahSummary surah;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF093E35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${surah.number}',
                textDirection: TextDirection.ltr,
                style: const TextStyle(color: AppColors.emeraldLight, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(surah.arabicName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('${surah.ayahCount} آيات • الصفحة ${surah.firstPage}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
