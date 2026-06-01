import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../audio/presentation/cubit/audio_cubit.dart';
import '../../domain/entities/ayah.dart';
import 'advanced_playback_dialog.dart';

class MushafPage extends StatelessWidget {
  final String surahName;
  final int page;
  final List<Ayah> ayahs;
  final int surahId;
  final bool isFirstPageOfSurah;
  final int? currentAyah;
  final int? selectedAyah; // ◄◄◄ جديد
  final Function(int?)? onSelectAyah; // ◄◄◄ جديد

  const MushafPage({
    super.key,
    required this.page,
    required this.ayahs,
    required this.surahName,
    required this.surahId,
    this.isFirstPageOfSurah = false,
    required this.currentAyah,
    this.selectedAyah, // ◄◄◄
    this.onSelectAyah, // ◄◄◄
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
            final isSelected = selectedAyah == ayah.ayahNumber;

            spans.add(
              TextSpan(
                text: "$text ",
                recognizer: LongPressGestureRecognizer()
                  ..onLongPress = () async {
                    // تحديد الآية
                    onSelectAyah?.call(ayah.ayahNumber);

                    // فتح القائمة
                    await showModalBottomSheet(
                      context: context,
                      backgroundColor: const Color(0xfff8f3e8),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (_) {
                        return SizedBox(
                          height: 320,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),

                              ListTile(
                                title: const Text("التفسير"),
                                trailing: const Icon(Icons.menu_book),
                                onTap: () {
                                  Navigator.pop(context);

                                  final prompt =
                                      "فسر لي الآية التالية شرحاً مفصلاً وواضحاً:\n\n"
                                      "سورة $surahName\n"
                                      "الآية رقم ${ayah.ayahNumber}\n"
                                      "$text\n\n"
                                      "اشرح المعنى، الكلمات الصعبة، والدروس المستفادة.";

                                  context.push(
                                    '/ai-assistant',
                                    extra: {
                                      'initialPrompt': prompt,
                                      'surahName': surahName,
                                      'ayahNumber': ayah.ayahNumber,
                                      'ayahText': text,
                                    },
                                  );
                                },
                              ),

                              ListTile(
                                title: const Text("تشغيل التلاوة"),
                                trailing: const Icon(Icons.play_arrow),
                                onTap: () {
                                  Navigator.pop(context);

                                  // تشغيل من الآية المحددة
                                  final audioCubit = context.read<AudioCubit>();

                                  final remainingAyahs = sortedAyahs
                                      .where(
                                        (a) => a.ayahNumber >= ayah.ayahNumber,
                                      )
                                      .map((a) => a.ayahNumber)
                                      .toList();

                                  audioCubit.playSurah(remainingAyahs, surahId);
                                },
                              ),
                              // ابحث عن ListTile الخاص بتشغيل التلاوة المتقدم وحدث الـ onTap كالتالي:
                              // ابحث عن ListTile الخاص بتشغيل التلاوة المتقدم وحدث الـ onTap كالتالي:
                              ListTile(
                                title: const Text("تشغيل التلاوة المتقدم"),
                                trailing: const Icon(Icons.play_arrow),
                                onTap: () {
                                  Navigator.pop(
                                    context,
                                  ); // إغلاق القائمة الأساسية أولاً

                                  final audioCubit = context.read<AudioCubit>();

                                  AdvancedPlaybackDialog.show(
                                    context: context,
                                    surahName: surahName,
                                    surahId: surahId,
                                    startAyah: ayah.ayahNumber,
                                    totalAyahs: sortedAyahs.last.ayahNumber,
                                    pageNumber: page,
                                    currentReciter:
                                        audioCubit.repository.currentReciter,
                                    onStart:
                                        (
                                          endOption,
                                          specificAyah,
                                          repeatMode,
                                          verseRepeatCount,
                                          rangeRepeatCount,
                                        ) {
                                          final remainingAyahs = sortedAyahs
                                              .where(
                                                (a) =>
                                                    a.ayahNumber >=
                                                    ayah.ayahNumber,
                                              )
                                              .map((a) => a.ayahNumber)
                                              .toList();

                                          audioCubit.playSurahAdvanced(
                                            surahId: surahId,
                                            ayahs: remainingAyahs,
                                            endOption: endOption,
                                            endAyah: specificAyah,
                                            repeatMode: repeatMode,
                                            verseRepeatCount: verseRepeatCount,
                                            rangeRepeatCount: rangeRepeatCount,
                                          );
                                        },
                                  );
                                },
                              ),

                              ListTile(
                                title: const Text("مشاركة"),
                                trailing: const Icon(Icons.share),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );

                    // بعد غلق القائمة ➜ إلغاء التحديد
                    onSelectAyah?.call(null);
                  },
                style: TextStyle(
                  fontFamily: "Amiri",
                  fontSize: fontSize,
                  height: lineHeight,
                  color: const Color(0xff1c2a1f),

                  backgroundColor: (isCurrent || isSelected)
                      ? const Color(0xffc8a96b).withOpacity(.5)
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
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "الجزء ${_toArabicNumbers('${sortedAyahs.first.juz}')}",
                          style: const TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 14,
                            color: Color(0xff1a472a),
                          ),
                        ),
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

                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text.rich(
                          TextSpan(children: spans),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),
                  ),

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
                        Text(
                          "الحزب ${_toArabicNumbers('${sortedAyahs.first.hizb}')}",
                          style: const TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 14,
                            color: Color(0xff1a472a),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
