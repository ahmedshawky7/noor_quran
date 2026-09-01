import 'package:flutter/material.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:qcf_quran_plus/src/data/quran_data.dart' show quran;

import '../../../core/theme/app_colors.dart';
import '../../mushaf/domain/entities/ayah_ref.dart';
import '../domain/entities/tafsir_entry.dart';

class TafsirPage extends StatelessWidget {
  const TafsirPage({
    super.key,
    required this.ayah,
    required this.surahName,
    required this.verseText,
    required this.repository,
  });

  final AyahRef ayah;
  final String surahName;
  final String verseText;
  final TafsirRepository repository;

  @override
  Widget build(BuildContext context) {
    final entry = repository.find(ayah.surahNumber, ayah.ayahNumber);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('التفسير الميسر'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$surahName — الآية ${ayah.ayahNumber}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: _TafsirAyahCard(
                  ayah: ayah,
                  fallbackText: verseText,
                ),
              ),
              const SizedBox(height: 14),
              const Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  'التفسير الميسر',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  entry?.text ?? 'التفسير غير متوفر لهذه الآية حالياً.',
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    height: 1.9,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'المصدر: التفسير الميسر — بيانات محلية داخل التطبيق',
                textAlign: TextAlign.right,
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _TafsirAyahCard extends StatefulWidget {
  const _TafsirAyahCard({required this.ayah, required this.fallbackText});

  final AyahRef ayah;
  final String fallbackText;

  @override
  State<_TafsirAyahCard> createState() => _TafsirAyahCardState();
}

class _TafsirAyahCardState extends State<_TafsirAyahCard> {
  bool _fontReady = false;

  Map<String, dynamic>? get _verse {
    for (final item in quran) {
      if (item['sora'] == widget.ayah.surahNumber &&
          item['aya_no'] == widget.ayah.ayahNumber) {
        return item;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadPageFont();
  }

  Future<void> _loadPageFont() async {
    final page = _verse?['page'];
    if (page is! int) return;
    try {
      await QcfFontLoader.ensureFontLoaded(page);
      if (mounted) setState(() => _fontReady = true);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final verse = _verse;
    if (!_fontReady || verse == null) {
      return Text(
        widget.fallbackText,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: Color(0xFFF8F3E8),
          fontSize: 20,
          height: 1.9,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final qcfText = verse['qcfData'].toString();
    final endsLine = qcfText.endsWith('\n');
    final lineText = endsLine ? qcfText.substring(0, qcfText.length - 1) : qcfText;
    final glyph = getaya_noQCF(widget.ayah.surahNumber, widget.ayah.ayahNumber);
    final verseBody = lineText.endsWith(glyph)
        ? lineText.substring(0, lineText.length - glyph.length)
        : lineText;
    final baseStyle = QuranTextStyles.qcfStyle(
      pageNumber: verse['page'] as int,
      color: const Color(0xFFF8F3E8),
      fontSize: 31,
      height: 1.5,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: verseBody,
                style: _withGlyphColor(baseStyle, const Color(0xFFF8F3E8)),
              ),
              TextSpan(
                text: glyph,
                style: _withGlyphColor(baseStyle, AppColors.gold),
              ),
              if (endsLine)
                TextSpan(
                  text: '\n',
                  style: _withGlyphColor(baseStyle, const Color(0xFFF8F3E8)),
                ),
            ],
          ),
          textAlign: TextAlign.center,
          style: baseStyle,
        ),
      ),
    );
  }
}

TextStyle _withGlyphColor(TextStyle style, Color color) => style
    .copyWith(color: null)
    .merge(TextStyle(foreground: Paint()..colorFilter = ColorFilter.mode(color, BlendMode.srcIn)));

