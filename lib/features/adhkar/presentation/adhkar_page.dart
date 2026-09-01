import 'package:flutter/material.dart';

import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:qcf_quran_plus/src/data/quran_data.dart' show quran;

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_surface.dart';
import '../../../core/widgets/qalam_header.dart';

class AdhkarPage extends StatefulWidget {
  const AdhkarPage({super.key, required this.onOpenQibla, required this.onOpenSettings});

  final VoidCallback onOpenQibla;
  final VoidCallback onOpenSettings;

  @override
  State<AdhkarPage> createState() => _AdhkarPageState();
}

class _AdhkarPageState extends State<AdhkarPage> {
  static const _categories = <_AdhkarCategory>[
    _AdhkarCategory.morning,
    _AdhkarCategory.evening,
    _AdhkarCategory.afterPrayer,
    _AdhkarCategory.sleep,
    _AdhkarCategory.daily,
  ];

  // أذكار أساسية موسعة ومراجعة. تفاصيل المصادر في docs/ADHKAR_SOURCES.md.
  static const _itemsByCategory = <_AdhkarCategory, List<_DhikrItem>>{
    _AdhkarCategory.morning: [
      _DhikrItem(text: 'آيَةُ الْكُرْسِيِّ', translation: 'سورة البقرة — الآية 255', target: 1, quranSurahNumber: 2, quranStartAyah: 255, quranEndAyah: 255),
      _DhikrItem(text: 'سُورَةُ الإِخْلَاصِ', translation: 'تُقرأ ثلاث مرات صباحاً', target: 3, quranSurahNumber: 112, quranStartAyah: 1, quranEndAyah: 4),
      _DhikrItem(text: 'سُورَةُ الفَلَقِ', translation: 'تُقرأ ثلاث مرات صباحاً', target: 3, quranSurahNumber: 113, quranStartAyah: 1, quranEndAyah: 5),
      _DhikrItem(text: 'سُورَةُ النَّاسِ', translation: 'تُقرأ ثلاث مرات صباحاً', target: 3, quranSurahNumber: 114, quranStartAyah: 1, quranEndAyah: 6),
      _DhikrItem(text: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ', translation: 'ذكر افتتاح الصباح', target: 1),
      _DhikrItem(text: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ', translation: 'ذكر الصباح', target: 1),
      _DhikrItem(text: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ', translation: 'سيد الاستغفار', target: 1),
      _DhikrItem(text: 'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ ﷺ نَبِيًّا', translation: 'الرضا بالله', target: 3),
      _DhikrItem(text: 'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ', translation: 'شكر النعمة', target: 1),
      _DhikrItem(text: 'اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلٰهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ', translation: 'الشهادة لله', target: 4),
      _DhikrItem(text: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلٰهَ إِلَّا أَنْتَ. اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ، وَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، لَا إِلٰهَ إِلَّا أَنْتَ', translation: 'دعاء العافية في البدن', target: 3),
      _DhikrItem(text: 'حَسْبِيَ اللَّهُ لَا إِلٰهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ', translation: 'التوكل', target: 7),
      _DhikrItem(text: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ وَمِنْ خَلْفِي وَعَنْ يَمِينِي وَعَنْ شِمَالِي وَمِنْ فَوْقِي، وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي', translation: 'دعاء العافية والحفظ', target: 1),
      _DhikrItem(text: 'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ، فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَى نَفْسِي سُوءًا أَوْ أَجُرَّهُ إِلَى مُسْلِمٍ', translation: 'دعاء الحفظ من الشر', target: 1),
      _DhikrItem(text: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ', translation: 'الحفظ', target: 3),
      _DhikrItem(text: 'يَا حَيُّ يَا قَيُّومُ، بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ', translation: 'دعاء الإصلاح', target: 1),
      _DhikrItem(text: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ رَبِّ الْعَالَمِينَ، اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ هَذَا الْيَوْمِ: فَتْحَهُ، وَنَصْرَهُ، وَنُورَهُ، وَبَرَكَتَهُ، وَهُدَاهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِيهِ وَشَرِّ مَا بَعْدَهُ', translation: 'خير اليوم', target: 1),
      _DhikrItem(text: 'أَصْبَحْنَا عَلَى فِطْرَةِ الْإِسْلَامِ، وَعَلَى كَلِمَةِ الْإِخْلَاصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ ﷺ، وَعَلَى مِلَّةِ أَبِينَا إِبْرَاهِيمَ، حَنِيفًا مُسْلِمًا وَمَا كَانَ مِنَ الْمُشْرِكِينَ', translation: 'فطرة الإسلام', target: 1),
      _DhikrItem(text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', translation: 'التسبيح', target: 100),
      _DhikrItem(text: 'لَا إِلٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ', translation: 'التهليل', target: 10),
      _DhikrItem(text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ', translation: 'تسبيح جويرية', target: 3),
      _DhikrItem(text: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا', translation: 'دعاء الصباح', target: 1),
      _DhikrItem(text: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ', translation: 'الصلاة على النبي ﷺ', target: 10),
    ],
    _AdhkarCategory.evening: [
      _DhikrItem(text: 'آيَةُ الْكُرْسِيِّ', translation: 'سورة البقرة — الآية 255', target: 1, quranSurahNumber: 2, quranStartAyah: 255, quranEndAyah: 255),
      _DhikrItem(text: 'سُورَةُ الإِخْلَاصِ', translation: 'تُقرأ ثلاث مرات مساءً', target: 3, quranSurahNumber: 112, quranStartAyah: 1, quranEndAyah: 4),
      _DhikrItem(text: 'سُورَةُ الفَلَقِ', translation: 'تُقرأ ثلاث مرات مساءً', target: 3, quranSurahNumber: 113, quranStartAyah: 1, quranEndAyah: 5),
      _DhikrItem(text: 'سُورَةُ النَّاسِ', translation: 'تُقرأ ثلاث مرات مساءً', target: 3, quranSurahNumber: 114, quranStartAyah: 1, quranEndAyah: 6),
      _DhikrItem(text: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ', translation: 'ذكر افتتاح المساء', target: 1),
      _DhikrItem(text: 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ', translation: 'ذكر المساء', target: 1),
      _DhikrItem(text: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ', translation: 'سيد الاستغفار', target: 1),
      _DhikrItem(text: 'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ ﷺ نَبِيًّا', translation: 'الرضا بالله', target: 3),
      _DhikrItem(text: 'اللَّهُمَّ مَا أَمْسَى بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ', translation: 'شكر النعمة', target: 1),
      _DhikrItem(text: 'اللَّهُمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلٰهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ', translation: 'الشهادة لله', target: 4),
      _DhikrItem(text: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلٰهَ إِلَّا أَنْتَ. اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ، وَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، لَا إِلٰهَ إِلَّا أَنْتَ', translation: 'دعاء العافية في البدن', target: 3),
      _DhikrItem(text: 'حَسْبِيَ اللَّهُ لَا إِلٰهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ', translation: 'التوكل', target: 7),
      _DhikrItem(text: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ وَمِنْ خَلْفِي وَعَنْ يَمِينِي وَعَنْ شِمَالِي وَمِنْ فَوْقِي، وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي', translation: 'دعاء العافية والحفظ', target: 1),
      _DhikrItem(text: 'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ، فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَى نَفْسِي سُوءًا أَوْ أَجُرَّهُ إِلَى مُسْلِمٍ', translation: 'دعاء الحفظ من الشر', target: 1),
      _DhikrItem(text: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ', translation: 'الحفظ', target: 3),
      _DhikrItem(text: 'يَا حَيُّ يَا قَيُّومُ، بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ', translation: 'دعاء الإصلاح', target: 1),
      _DhikrItem(text: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ رَبِّ الْعَالَمِينَ، اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ هَذِهِ اللَّيْلَةِ: فَتْحَهَا، وَنَصْرَهَا، وَنُورَهَا، وَبَرَكَتَهَا، وَهُدَاهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِيهَا وَشَرِّ مَا بَعْدَهَا', translation: 'خير الليلة', target: 1),
      _DhikrItem(text: 'أَمْسَيْنَا عَلَى فِطْرَةِ الْإِسْلَامِ، وَعَلَى كَلِمَةِ الْإِخْلَاصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ ﷺ، وَعَلَى مِلَّةِ أَبِينَا إِبْرَاهِيمَ، حَنِيفًا مُسْلِمًا وَمَا كَانَ مِنَ الْمُشْرِكِينَ', translation: 'فطرة الإسلام', target: 1),
      _DhikrItem(text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', translation: 'التسبيح', target: 100),
      _DhikrItem(text: 'لَا إِلٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ', translation: 'التهليل', target: 10),
      _DhikrItem(text: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ', translation: 'الاستعاذة', target: 3),
      _DhikrItem(text: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ', translation: 'الصلاة على النبي ﷺ', target: 10),
    ],
    _AdhkarCategory.afterPrayer: [
      _DhikrItem(text: 'أَسْتَغْفِرُ اللَّهَ', translation: 'بعد السلام من الصلاة', target: 3),
      _DhikrItem(text: 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ', translation: 'دعاء بعد الصلاة', target: 1),
      _DhikrItem(text: 'لَا إِلٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ. لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ، لَا إِلٰهَ إِلَّا اللَّهُ وَلَا نَعْبُدُ إِلَّا إِيَّاهُ، لَهُ النِّعْمَةُ وَلَهُ الْفَضْلُ وَلَهُ الثَّنَاءُ الْحَسَنُ، لَا إِلٰهَ إِلَّا اللَّهُ مُخْلِصِينَ لَهُ الدِّينَ وَلَوْ كَرِهَ الْكَافِرُونَ', translation: 'التهليل بعد الصلاة', target: 1),
      _DhikrItem(text: 'اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ، وَلَا مُعْطِيَ لِمَا مَنَعْتَ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ', translation: 'دعاء بعد الصلاة', target: 1),
      _DhikrItem(text: 'سُبْحَانَ اللَّهِ', translation: 'تسبيح ما بعد الصلاة', target: 33),
      _DhikrItem(text: 'الْحَمْدُ لِلَّهِ', translation: 'تحميد ما بعد الصلاة', target: 33),
      _DhikrItem(text: 'اللَّهُ أَكْبَرُ', translation: 'تكبير ما بعد الصلاة', target: 33),
      _DhikrItem(text: 'لَا إِلٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ', translation: 'ختام التسبيح', target: 1),
      _DhikrItem(text: 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ', translation: 'دعاء بعد الصلاة', target: 1),
      _DhikrItem(text: 'آيَةُ الْكُرْسِيِّ', translation: 'سورة البقرة — الآية 255', target: 1, quranSurahNumber: 2, quranStartAyah: 255, quranEndAyah: 255),
      _DhikrItem(text: 'سُورَةُ الإِخْلَاصِ', translation: 'بعد كل صلاة؛ وتُكرر 3 بعد الفجر والمغرب', target: 1, quranSurahNumber: 112, quranStartAyah: 1, quranEndAyah: 4),
      _DhikrItem(text: 'سُورَةُ الفَلَقِ', translation: 'بعد كل صلاة؛ وتُكرر 3 بعد الفجر والمغرب', target: 1, quranSurahNumber: 113, quranStartAyah: 1, quranEndAyah: 5),
      _DhikrItem(text: 'سُورَةُ النَّاسِ', translation: 'بعد كل صلاة؛ وتُكرر 3 بعد الفجر والمغرب', target: 1, quranSurahNumber: 114, quranStartAyah: 1, quranEndAyah: 6),
      _DhikrItem(text: 'لَا إِلٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، يُحْيِي وَيُمِيتُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ', translation: 'بعد الفجر والمغرب', target: 10),
      _DhikrItem(text: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا', translation: 'بعد صلاة الفجر', target: 1),
    ],
    _AdhkarCategory.sleep: [
      _DhikrItem(text: 'آيَةُ الْكُرْسِيِّ', translation: 'عند النوم', target: 1, quranSurahNumber: 2, quranStartAyah: 255, quranEndAyah: 255),
      _DhikrItem(text: 'آخِرُ آيَتَيْنِ مِنْ سُورَةِ الْبَقَرَةِ', translation: 'سورة البقرة — الآيتان 285–286', target: 1, quranSurahNumber: 2, quranStartAyah: 285, quranEndAyah: 286),
      _DhikrItem(text: 'سُورَةُ الإِخْلَاصِ', translation: 'مع النفث في الكفين والمسح، ثلاث مرات', target: 3, quranSurahNumber: 112, quranStartAyah: 1, quranEndAyah: 4),
      _DhikrItem(text: 'سُورَةُ الفَلَقِ', translation: 'مع النفث في الكفين والمسح، ثلاث مرات', target: 3, quranSurahNumber: 113, quranStartAyah: 1, quranEndAyah: 5),
      _DhikrItem(text: 'سُورَةُ النَّاسِ', translation: 'مع النفث في الكفين والمسح، ثلاث مرات', target: 3, quranSurahNumber: 114, quranStartAyah: 1, quranEndAyah: 6),
      _DhikrItem(text: 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي وَبِكَ أَرْفَعُهُ، فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ', translation: 'دعاء النوم', target: 1),
      _DhikrItem(text: 'اللَّهُمَّ إِنَّكَ خَلَقْتَ نَفْسِي وَأَنْتَ تَوَفَّاهَا، لَكَ مَمَاتُهَا وَمَحْيَاهَا، إِنْ أَحْيَيْتَهَا فَاحْفَظْهَا، وَإِنْ أَمَتَّهَا فَاغْفِرْ لَهَا، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ', translation: 'دعاء النوم', target: 1),
      _DhikrItem(text: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ', translation: 'دعاء النوم', target: 3),
      _DhikrItem(text: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا', translation: 'دعاء النوم', target: 1),
      _DhikrItem(text: 'سُبْحَانَ اللَّهِ', translation: 'تسبيح فاطمة عند النوم', target: 33),
      _DhikrItem(text: 'الْحَمْدُ لِلَّهِ', translation: 'تحميد فاطمة عند النوم', target: 33),
      _DhikrItem(text: 'اللَّهُ أَكْبَرُ', translation: 'تكبير فاطمة عند النوم', target: 34),
      _DhikrItem(text: 'اللَّهُمَّ رَبَّ السَّمَاوَاتِ السَّبْعِ وَرَبَّ الْأَرْضِ وَرَبَّ الْعَرْشِ الْعَظِيمِ، رَبَّنَا وَرَبَّ كُلِّ شَيْءٍ، فَالِقَ الْحَبِّ وَالنَّوَى، وَمُنْزِلَ التَّوْرَاةِ وَالْإِنْجِيلِ وَالْفُرْقَانِ، أَعُوذُ بِكَ مِنْ شَرِّ كُلِّ شَيْءٍ أَنْتَ آخِذٌ بِنَاصِيَتِهِ، اللَّهُمَّ أَنْتَ الْأَوَّلُ فَلَيْسَ قَبْلَكَ شَيْءٌ، وَأَنْتَ الْآخِرُ فَلَيْسَ بَعْدَكَ شَيْءٌ، وَأَنْتَ الظَّاهِرُ فَلَيْسَ فَوْقَكَ شَيْءٌ، وَأَنْتَ الْبَاطِنُ فَلَيْسَ دُونَكَ شَيْءٌ، اقْضِ عَنَّا الدَّيْنَ وَأَغْنِنَا مِنَ الْفَقْرِ', translation: 'دعاء النوم والدين', target: 1),
      _DhikrItem(text: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا، وَكَفَانَا وَآوَانَا، فَكَمْ مِمَّنْ لَا كَافِيَ لَهُ وَلَا مُؤْوِيَ', translation: 'حمد الله عند النوم', target: 1),
    ],
    _AdhkarCategory.daily: [
      _DhikrItem(text: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ', translation: 'عند الاستيقاظ', target: 1),
      _DhikrItem(text: 'الْحَمْدُ لِلَّهِ الَّذِي عَافَانِي فِي جَسَدِي وَرَدَّ عَلَيَّ رُوحِي، وَأَذِنَ لِي بِذِكْرِهِ', translation: 'عند الاستيقاظ', target: 1),
      _DhikrItem(text: 'الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا الثَّوْبَ وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ', translation: 'عند لبس الثوب', target: 1),
      _DhikrItem(text: 'اللَّهُمَّ لَكَ الْحَمْدُ أَنْتَ كَسَوْتَنِيهِ، أَسْأَلُكَ مِنْ خَيْرِهِ وَخَيْرِ مَا صُنِعَ لَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّهِ وَشَرِّ مَا صُنِعَ لَهُ', translation: 'عند لبس ثوب جديد', target: 1),
      _DhikrItem(text: 'بِسْمِ اللَّهِ', translation: 'عند وضع الثوب', target: 1),
      _DhikrItem(text: 'بِسْمِ اللَّهِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ', translation: 'عند دخول الخلاء', target: 1),
      _DhikrItem(text: 'غُفْرَانَكَ', translation: 'عند الخروج من الخلاء', target: 1),
      _DhikrItem(text: 'بِسْمِ اللَّهِ', translation: 'قبل الوضوء', target: 1),
      _DhikrItem(text: 'أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ. اللَّهُمَّ اجْعَلْنِي مِنَ التَّوَّابِينَ وَاجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ', translation: 'بعد الوضوء', target: 1),
      _DhikrItem(text: 'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ. اللَّهُمَّ إِنِّي أَعُوذُ بِكَ أَنْ أَضِلَّ أَوْ أُضَلَّ، أَوْ أَزِلَّ أَوْ أُزَلَّ، أَوْ أَظْلِمَ أَوْ أُظْلَمَ، أَوْ أَجْهَلَ أَوْ يُجْهَلَ عَلَيَّ', translation: 'عند الخروج من المنزل', target: 1),
      _DhikrItem(text: 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى رَبِّنَا تَوَكَّلْنَا، ثُمَّ يُسَلِّمُ عَلَى أَهْلِهِ', translation: 'عند دخول المنزل', target: 1),
      _DhikrItem(text: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ', translation: 'عند دخول المسجد', target: 1),
      _DhikrItem(text: 'بِسْمِ اللَّهِ وَالصَّلَاةُ وَالسَّلَامُ عَلَى رَسُولِ اللَّهِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ، اللَّهُمَّ اعْصِمْنِي مِنَ الشَّيْطَانِ الرَّجِيمِ', translation: 'عند الخروج من المسجد', target: 1),
      _DhikrItem(text: 'بِسْمِ اللَّهِ', translation: 'قبل الطعام', target: 1),
      _DhikrItem(text: 'بِسْمِ اللَّهِ فِي أَوَّلِهِ وَآخِرِهِ', translation: 'إذا نسي التسمية أول الطعام', target: 1),
      _DhikrItem(text: 'اللَّهُمَّ بَارِكْ لَنَا فِيهِ وَأَطْعِمْنَا خَيْرًا مِنْهُ', translation: 'عند الطعام', target: 1),
      _DhikrItem(text: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ', translation: 'بعد الطعام', target: 1),
      _DhikrItem(text: 'الْحَمْدُ لِلَّهِ حَمْدًا كَثِيرًا طَيِّبًا مُبَارَكًا فِيهِ، غَيْرَ مَكْفِيٍّ وَلَا مُوَدَّعٍ وَلَا مُسْتَغْنًى عَنْهُ رَبَّنَا', translation: 'بعد الطعام', target: 1),
      _DhikrItem(text: 'الْحَمْدُ لِلَّهِ', translation: 'عند العطاس؛ والرد: يَرْحَمُكَ اللَّهُ، ثم: يَهْدِيكُمُ اللَّهُ وَيُصْلِحُ بَالَكُمْ', target: 1),
      _DhikrItem(text: 'بِسْمِ اللَّهِ، الْحَمْدُ لِلَّهِ، سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ. الْحَمْدُ لِلَّهِ ثَلَاثًا، اللَّهُ أَكْبَرُ ثَلَاثًا، سُبْحَانَكَ اللَّهُمَّ إِنِّي ظَلَمْتُ نَفْسِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ', translation: 'دعاء الركوب', target: 1),
      _DhikrItem(text: 'اللَّهُ أَكْبَرُ ثَلَاثًا، سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ. اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى، وَمِنَ الْعَمَلِ مَا تَرْضَى، اللَّهُمَّ هَوِّنْ عَلَيْنَا سَفَرَنَا هَذَا وَاطْوِ عَنَّا بُعْدَهُ، اللَّهُمَّ أَنْتَ الصَّاحِبُ فِي السَّفَرِ وَالْخَلِيفَةُ فِي الْأَهْلِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ وَعْثَاءِ السَّفَرِ وَكَآبَةِ الْمَنْظَرِ وَسُوءِ الْمُنْقَلَبِ فِي الْمَالِ وَالْأَهْلِ', translation: 'دعاء السفر', target: 1),
      _DhikrItem(text: 'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ، إِنَّكَ أَنْتَ التَّوَّابُ الْغَفُورُ', translation: 'في المجلس', target: 100),
      _DhikrItem(text: 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا أَنْتَ، أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ', translation: 'كفارة المجلس', target: 1),
    ],
  };

  final Map<_AdhkarCategory, List<int>> _counts = {
    for (final category in _categories)
      category: List<int>.filled(_itemsByCategory[category]!.length, 0),
  };

  _AdhkarCategory _category = _AdhkarCategory.morning;
  int _selectedIndex = 0;

  List<_DhikrItem> get _items => _itemsByCategory[_category]!;
  _DhikrItem get _selectedItem => _items[_selectedIndex];
  int get _selectedCount => _counts[_category]![_selectedIndex];

  void _selectCategory(_AdhkarCategory category) {
    setState(() {
      _category = category;
      _selectedIndex = 0;
    });
  }

  void _incrementSelected() {
    setState(() {
      final counts = _counts[_category]!;
      if (counts[_selectedIndex] >= _selectedItem.target) return;
      counts[_selectedIndex]++;
      // عند اكتمال الذكر ننتقل مباشرة إلى الذي يليه داخل المجموعة.
      if (counts[_selectedIndex] == _selectedItem.target &&
          _selectedIndex < _items.length - 1) {
        _selectedIndex++;
      }
    });
  }

  void _resetCategory() {
    setState(() {
      final counts = _counts[_category]!;
      for (var index = 0; index < counts.length; index++) {
        counts[index] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _selectedItem.target == 0
        ? 0.0
        : (_selectedCount / _selectedItem.target).clamp(0.0, 1.0);
    final complete = _selectedCount >= _selectedItem.target;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          QalamHeader(
            onSettingsPressed: widget.onOpenSettings,
            trailing: IconButton(
              onPressed: widget.onOpenQibla,
              tooltip: 'القبلة',
              icon: const Icon(Icons.explore_outlined, color: AppColors.emeraldLight),
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: const _AdhkarPatternPainter(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                children: [
                  _CategoryTabs(
                    categories: _categories,
                    selected: _category,
                    onSelected: _selectCategory,
                  ),
                  const SizedBox(height: 18),
                  _MainDhikrCard(
                    item: _selectedItem,
                    count: _selectedCount,
                    progress: progress,
                    complete: complete,
                    onTap: _incrementSelected,
                    onReset: _resetCategory,
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'القائمة',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_items.length, (index) {
                    final item = _items[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == _items.length - 1 ? 0 : 10),
                      child: _DhikrListTile(
                        item: item,
                        count: _counts[_category]![index],
                        selected: index == _selectedIndex,
                        onTap: () => setState(() => _selectedIndex = index),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<_AdhkarCategory> categories;
  final _AdhkarCategory selected;
  final ValueChanged<_AdhkarCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: categories
            .map(
              (category) => Padding(
                padding: const EdgeInsetsDirectional.only(start: 6),
                child: InkWell(
                  onTap: () => onSelected(category),
                  borderRadius: BorderRadius.circular(22),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: selected == category
                          ? const Color(0x332D9E82)
                          : const Color(0xCC111922),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: selected == category ? AppColors.gold : AppColors.border,
                      ),
                      boxShadow: selected == category
                          ? const [
                              BoxShadow(
                                color: Color(0x305F4223),
                                blurRadius: 14,
                                offset: Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      category.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected == category ? AppColors.gold : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MainDhikrCard extends StatelessWidget {
  const _MainDhikrCard({
    required this.item,
    required this.count,
    required this.progress,
    required this.complete,
    required this.onTap,
    required this.onReset,
  });

  final _DhikrItem item;
  final int count;
  final double progress;
  final bool complete;
  final VoidCallback onTap;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      borderColor: complete ? AppColors.emeraldLight : const Color(0xFF263240),
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xEE101A29), Color(0xF30A111C)],
      ),
      child: Column(
        children: [
          if (item.isQuran) ...[
            _QcfDhikrText(item: item),
            const SizedBox(height: 20),
            Text(
              item.quranDisplayName,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              item.quranTranslation,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: AppColors.gold, fontSize: 16, height: 1.45),
            ),
          ] else ...[
            Text(
              item.text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, height: 1.55),
            ),
            const SizedBox(height: 7),
            Text(
              item.translation,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.gold, fontSize: 15),
            ),
          ],
          const SizedBox(height: 24),
          if (item.isQuran && item.target == 1)
            _ReadCompletionButton(complete: complete, onTap: onTap)
          else
            Semantics(
              button: true,
              label: 'زيادة عداد الذكر',
              child: GestureDetector(
                onTap: onTap,
                child: SizedBox(
                width: 174,
                height: 174,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 174,
                      height: 174,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                        color: complete ? AppColors.emeraldLight : AppColors.gold,
                        backgroundColor: const Color(0xFF172230),
                      ),
                    ),
                    Container(
                      width: 142,
                      height: 142,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF111B2D),
                        border: Border.all(color: const Color(0xFF26394A), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Color(0x50000000), blurRadius: 18, spreadRadius: 3),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            complete ? Icons.check_rounded : Icons.touch_app_outlined,
                            color: complete ? AppColors.emeraldLight : AppColors.emerald,
                            size: 25,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$count',
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'من ${item.target}',
                            style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),
          const SizedBox(height: 13),
          Text(
            item.isQuran && item.target == 1
                ? 'اضغط بعد إتمام القراءة'
                : complete
                    ? 'تم الذكر'
                    : 'اضغط على العداد',
            style: TextStyle(
              color: complete ? AppColors.emeraldLight : AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text('إعادة العد'),
            style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _QcfDhikrText extends StatefulWidget {
  const _QcfDhikrText({required this.item});

  final _DhikrItem item;

  @override
  State<_QcfDhikrText> createState() => _QcfDhikrTextState();
}

class _QcfDhikrTextState extends State<_QcfDhikrText> {
  bool _fontReady = false;

  @override
  void initState() {
    super.initState();
    _loadQcfFont();
  }

  Future<void> _loadQcfFont() async {
    try {
      await QcfFontLoader.ensureFontLoaded(widget.item.quranPageNumber);
      if (mounted) setState(() => _fontReady = true);
    } catch (_) {
      // العرض بخط حفص أدناه يظل بديلاً آمناً إذا تعذر تحميل خط الصفحة.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_fontReady) return _QuranicDhikrText(item: widget.item);

    final item = widget.item;
    final page = item.quranPageNumber;
    final isLongBaqaraPassage = page == 42 || page == 49;
    final baseStyle = QuranTextStyles.qcfStyle(
      pageNumber: page,
      color: const Color(0xFFF8F3E8),
      fontSize: isLongBaqaraPassage ? 26 : 42,
      height: isLongBaqaraPassage ? 1.54 : 1.46,
    );
    final mainTextStyle = _withGlyphColor(baseStyle, const Color(0xFFF8F3E8));
    final ayahNumberStyle = _withGlyphColor(baseStyle, const Color(0xFFE6B555));
    final qcfText = <InlineSpan>[
      for (var ayah = item.quranStartAyah!; ayah <= item.quranEndAyah!; ayah++)
        ..._qcfVerseSpans(
          item.quranSurahNumber!,
          ayah,
          mainTextStyle,
          ayahNumberStyle,
        ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: FittedBox(
        fit: isLongBaqaraPassage ? BoxFit.contain : BoxFit.scaleDown,

        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(children: qcfText),
          textAlign: TextAlign.center,
          style: baseStyle,
        ),
      ),
    );
  }

  TextStyle _withGlyphColor(TextStyle style, Color color) => style
      .copyWith(color: null)
      .merge(TextStyle(foreground: Paint()..colorFilter = ColorFilter.mode(color, BlendMode.srcIn)));

  List<InlineSpan> _qcfVerseSpans(
    int surah,
    int ayah,
    TextStyle mainTextStyle,
    TextStyle ayahNumberStyle,
  ) {
    final qcfText = _qcfData(surah, ayah);
    final endsLine = qcfText.endsWith('\n');
    final textOnLine = endsLine
        ? qcfText.substring(0, qcfText.length - 1)
        : qcfText;
    final glyph = getaya_noQCF(surah, ayah);
    final textWithoutGlyph = textOnLine.endsWith(glyph)
        ? textOnLine.substring(0, textOnLine.length - glyph.length)
        : textOnLine;

    return [
      TextSpan(text: textWithoutGlyph, style: mainTextStyle),
      TextSpan(text: glyph, style: ayahNumberStyle),
      if (endsLine) TextSpan(text: '\n', style: mainTextStyle),
    ];
  }

  String _qcfData(int surah, int ayah) {
    final verse = quran.firstWhere(
      (item) => item['sora'] == surah && item['aya_no'] == ayah,
    );
    return verse['qcfData'].toString();
  }
}

class _QuranicDhikrText extends StatelessWidget {
  const _QuranicDhikrText({required this.item});

  final _DhikrItem item;

  @override
  Widget build(BuildContext context) {
    final surah = item.quranSurahNumber!;
    final start = item.quranStartAyah!;
    final end = item.quranEndAyah!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text.rich(
        TextSpan(
          children: [
            for (var ayah = start; ayah <= end; ayah++)
              TextSpan(text: '${getVerse(surah, ayah)}  '),
          ],
        ),
        textAlign: TextAlign.center,
        style: QuranTextStyles.hafsStyle(
          color: const Color(0xFFF1F3F7),
          fontSize: surah == 2 ? 23 : 28,
          height: 1.58,
        ),
      ),
    );
  }
}

class _ReadCompletionButton extends StatelessWidget {
  const _ReadCompletionButton({required this.complete, required this.onTap});

  final bool complete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(complete ? Icons.check_rounded : Icons.menu_book_rounded, size: 20),
        label: const Text('تمت القراءة'),
        style: OutlinedButton.styleFrom(
          foregroundColor: complete ? AppColors.emeraldLight : AppColors.gold,
          side: BorderSide(color: complete ? AppColors.emeraldLight : AppColors.gold),
          backgroundColor: complete ? const Color(0x252D9E82) : const Color(0x301F1912),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _DhikrListTile extends StatelessWidget {
  const _DhikrListTile({
    required this.item,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final _DhikrItem item;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final complete = count >= item.target;
    return AppSurface(
      padding: EdgeInsets.zero,
      borderColor: selected ? AppColors.gold : AppColors.border,
      gradient: selected
          ? const LinearGradient(colors: [Color(0xFF24201C), Color(0xFF17191F)])
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? const Color(0xFF3B3326) : AppColors.surfaceRaised,
                ),
                child: complete
                    ? const Icon(Icons.check_rounded, color: AppColors.emeraldLight)
                    : Text(
                        '$count',
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, height: 1.45),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.translation,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Icon(
                selected ? Icons.play_circle_fill_rounded : Icons.play_circle_outline_rounded,
                color: selected ? AppColors.gold : AppColors.textMuted,
                size: 27,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _AdhkarCategory { morning, evening, afterPrayer, sleep, daily }

extension on _AdhkarCategory {
  String get label => switch (this) {
        _AdhkarCategory.morning => 'أذكار الصباح',
        _AdhkarCategory.evening => 'أذكار المساء',
        _AdhkarCategory.afterPrayer => 'بعد الصلاة',
        _AdhkarCategory.sleep => 'النوم',
        _AdhkarCategory.daily => 'يوميات',
      };
}

class _DhikrItem {
  const _DhikrItem({
    required this.text,
    required this.translation,
    required this.target,
    this.quranSurahNumber,
    this.quranStartAyah,
    this.quranEndAyah,
  });

  final String text;
  final String translation;
  final int target;
  final int? quranSurahNumber;
  final int? quranStartAyah;
  final int? quranEndAyah;

  bool get isQuran =>
      quranSurahNumber != null && quranStartAyah != null && quranEndAyah != null;

  int get quranPageNumber {
    if (quranSurahNumber == 2 && quranStartAyah == 255) return 42;
    if (quranSurahNumber == 2 && quranStartAyah == 285) return 49;
    if (quranSurahNumber == 112 || quranSurahNumber == 113 || quranSurahNumber == 114) return 604;
    return 1;
  }

  String get quranDisplayName {
    if (quranSurahNumber == 2 && quranStartAyah == 255) return 'آية الكرسي';
    if (quranSurahNumber == 2 && quranStartAyah == 285) return 'آخر آيتين من البقرة';
    return switch (quranSurahNumber) {
      112 => 'سورة الإخلاص',
      113 => 'سورة الفلق',
      114 => 'سورة الناس',
      _ => '',
    };
  }

  String get quranTranslation => translation;
}

class _AdhkarPatternPainter extends CustomPainter {
  const _AdhkarPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x160E816E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const cell = 42.0;
    for (var row = -1; row < (size.height / cell).ceil() + 1; row++) {
      for (var column = -1; column < (size.width / cell).ceil() + 1; column++) {
        final center = Offset(column * cell + (row.isOdd ? cell / 2 : 0), row * cell);
        final path = Path()
          ..moveTo(center.dx, center.dy - cell / 2)
          ..lineTo(center.dx + cell / 2, center.dy)
          ..lineTo(center.dx, center.dy + cell / 2)
          ..lineTo(center.dx - cell / 2, center.dy)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AdhkarPatternPainter oldDelegate) => false;
}
