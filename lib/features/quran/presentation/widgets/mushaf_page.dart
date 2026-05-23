import 'package:flutter/material.dart';
import '../../domain/entities/ayah.dart';

class MushafPage extends StatelessWidget {
  final String surahName;
  final int page;
  final List<Ayah> ayahs;
  final int surahId;
  final bool isFirstPageOfSurah;
  final int? currentAyah;
  const MushafPage({
    super.key,
    required this.page,
    required this.ayahs,
    required this.surahName,
    required this.surahId,
    this.isFirstPageOfSurah = false,
    required this.currentAyah,
  });

  String _cleanText(String text, int ayahNumber) {
    if (ayahNumber == 1 && isFirstPageOfSurah && surahId != 1 && surahId != 9) {
      final basmalaRegex = RegExp(
        r'^بِسْمِ\s+ٱ?للَّ?هِ?\s+ٱ?لرَّ?حْ?مَ?ٰ?نِ?\s+ٱ?لرَّ?حِ?يمِ?\s*',
        unicode: true,
      );

      text = text.replaceFirst(basmalaRegex, '').trim();
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final sortedAyahs = ayahs.toList()
      ..sort((a, b) => a.ayahNumber.compareTo(b.ayahNumber));

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          int totalChars = 0;

          for (var ayah in sortedAyahs) {
            totalChars += _cleanText(ayah.textUthmani, ayah.ayahNumber).length;
          }

          double fontSize = 17;
          double lineHeight = 2.2;

          if (totalChars < 150) {
            lineHeight = 2.8;
          } else if (totalChars < 250) {
            lineHeight = 2.5;
          } else if (totalChars < 400) {
            lineHeight = 2.3;
          } else {
            lineHeight = 1.8;
            fontSize = 20.8;
          }

          final spans = <InlineSpan>[];

          for (final ayah in sortedAyahs) {
            String text = _cleanText(ayah.textUthmani, ayah.ayahNumber);

            if (text.isEmpty) continue;

            final isCurrent = currentAyah == ayah.ayahNumber;

            spans.add(
              TextSpan(
                text: "$text ",
                style: TextStyle(
                  fontFamily: "Amiri",
                  fontSize: fontSize,
                  height: lineHeight,
                  color: const Color(0xff1c2a1f),
                  backgroundColor: isCurrent
                      ? const Color(0xffc8a96b).withOpacity(0.5)
                      : Colors.transparent,
                ),
              ),
            );

            spans.add(
              TextSpan(
                text: " ۝${_toArabicNumbers(ayah.ayahNumber.toString())} ",
                style: TextStyle(
                  fontFamily: "Amiri",
                  fontSize: fontSize * .7,
                  color: const Color(0xff1a472a),
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),

            decoration: BoxDecoration(
              color: const Color(0xfff8f3e8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffc8a96b), width: 2.5),
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

              child: Column(
                children: [
                  /// HEADER
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      crossAxisAlignment: CrossAxisAlignment.baseline,

                      textBaseline: TextBaseline.alphabetic,

                      children: [
                        // الجزء فوق يمين
                        Text(
                          "الجزء ${_toArabicNumbers('${sortedAyahs.first.juz}')}",
                          style: const TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 14,
                            color: Color(0xff1a472a),
                          ),
                        ),

                        // اسم السورة فوق شمال
                        Text(
                          surahName,
                          style: const TextStyle(
                            fontFamily: "Amiri",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1a472a),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Color(0xffc8a96b)),

                  /// زخرفة السورة
                  if (isFirstPageOfSurah)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),

                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Sura_border.png',
                            height: 50,
                            width: double.infinity,
                            fit: BoxFit.fill,
                          ),

                          Text(
                            surahName,

                            style: const TextStyle(
                              fontFamily: "Amiri",
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  /// البسملة
                  if (isFirstPageOfSurah && surahId != 1 && surahId != 9)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                        style: TextStyle(
                          fontFamily: "Uthmanic",
                          fontSize: fontSize * 1.1,
                        ),
                      ),
                    ),

                  /// الآيات
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,

                      child: Text.rich(
                        TextSpan(children: spans),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),

                  /// رقم الصفحة تحت شمال
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 4,
                      right: 4,
                      bottom: 2,
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        // الحزب تحت يمين
                        Text(
                          "الحزب ${_toArabicNumbers('${sortedAyahs.first.hizb}')}",
                          style: const TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 14,
                            color: Color(0xff1a472a),
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // رقم الصفحة تحت شمال
                        Text(
                          "الصفحة ${_toArabicNumbers('$page')}",
                          style: const TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 14,
                            color: Color(0xff1a472a),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < 10; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }
}
