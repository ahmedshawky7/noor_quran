import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_quran/core/theme/app_theme.dart';
import 'package:noor_quran/features/quran/presentation/cubit/ayah_cubit.dart';
import 'package:noor_quran/features/quran/presentation/cubit/ayah_state.dart';
import 'package:to_arabic_number/to_arabic_number.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int _currentAyahIndex = 0;

  @override
  void initState() {
    super.initState();
    // حمّل الآيات اليومية من قاعدة البيانات
    context.read<AyahCubit>().loadDailyAyahs();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xff1a1a1a) : const Color(0xfff8f3e8);
    final cardColor = isDark ? const Color(0xff2a2a2a) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff795547);

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: bgColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text(
          'القرآن الكريم',
          style: TextStyle(
            color: Color(0xff6d5d55),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,

        leading: IconButton(
          icon: Icon(Icons.search, color: textColor),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: textColor),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Prayer Time Card
            _buildPrayerTimeCard(isDark, cardColor),

            // Daily Ayahs Section من قاعدة البيانات
            _buildDailyAyahsSection(isDark, cardColor, textColor),

            // Features Grid
            _buildFeaturesGrid(context, isDark, cardColor),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeCard(bool isDark, Color cardColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xfff5ede0), const Color(0xffebe5d9)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xffe8dcc8),
              ),
              child: const Image(
                image: AssetImage('assets/icons/azkarIcon.png'),
                width: 60,
                //color: Color(0xffb8860b),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Prayer info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'الظهر',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Text(
                  '11:45',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ص',
                  style: TextStyle(color: AppTheme.primaryColor, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'الصلاة التالية: العصر',
                  style: TextStyle(color: AppTheme.primaryColor, fontSize: 11),
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  'مساء 2:50',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyAyahsSection(
      bool isDark,
      Color cardColor,
      Color textColor,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'الآيات اليومية',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 12),
          // Carousel من قاعدة البيانات
          BlocBuilder<AyahCubit, AyahState>(
            builder: (context, state) {
              if (state is AyahLoading) {
                return Center(
                  child: SizedBox(
                    height: 220,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        Text(
                          'جاري تحميل الآيات...',
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is AyahLoaded && state.ayahs.isNotEmpty) {
                final ayahs = state.ayahs;
                return Column(
                  children: [
                    SizedBox(
                      height: 220,
                      child: PageView.builder(
                        reverse: true,
                        onPageChanged: (index) {
                          setState(() => _currentAyahIndex = index);
                        },
                        itemCount: ayahs.length,
                        itemBuilder: (context, index) {
                          return _buildAyahCard(
                            ayahs[index],
                            state.surah.nameArabic,
                            isDark,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Dots indicator
                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        ayahs.length,
                            (index) => Container(
                          width: index == _currentAyahIndex ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: index == _currentAyahIndex
                                ? const Color(0xffd4a574)
                                : const Color(0xffc4a080),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (state is AyahError) {
                return Center(
                  child: SizedBox(
                    height: 220,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox(height: 220);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAyahCard(dynamic ayah, String surahName, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xff2a2a2a),
        border: Border.symmetric(
          vertical: BorderSide(color: AppTheme.accentColor, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, color: AppTheme.accentColor, size: 20),
          //const SizedBox(height: 5),
          Spacer(),
          Text(
            ayah.textUthmani,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          //const SizedBox(height: 5),
          Spacer(),
          Text(
            'الآية ${Arabic.number(ayah.ayahNumber.toString())} من سورة $surahName',
            style: TextStyle(
              color: AppTheme.accentColor,
              fontSize: 13,
              height: 1.6,
              fontFamily: 'Amiri',
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 5),

          Text(
            'الجزء: ${Arabic.number(ayah.juz.toString())}',
            style: TextStyle(
              color: AppTheme.accentColor,
              fontSize: 13,
              fontFamily: 'Amiri',
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(
      BuildContext context,
      bool isDark,
      Color cardColor,
      ) {
    final features = [
      {
        'icon': AssetImage('assets/icons/quranIcon.png'),
        'label': 'القرآن',
        'route': '/quran',
      },
      {
        'icon': AssetImage('assets/icons/asmaAllahIcon.png'),
        'label': 'أسماء الله الحسنى',
        'route': '/quran',
      },
      {
        'icon': AssetImage('assets/icons/sebhaIcon.png'),
        'label': 'التسبيح الدائم',
        'route': '/azkar',
      },
      {
        'icon': AssetImage('assets/icons/duaIcon.png'),
        'label': 'الأدعية',
        'route': '/azkar',
      },
      {
        'icon': AssetImage('assets/icons/hadithIcon.png'),
        'label': 'الأحاديث',
        'route': '/hadith',
      },
      {
        'icon': AssetImage('assets/icons/azkarIcon.png'),
        'label': 'الذكار',
        'route': '/azkar',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return _buildFeatureCard(
            context,
            feature['icon'] as AssetImage,
            feature['label'] as String,
            feature['route'] as String,
            isDark,
            cardColor,
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context,
      AssetImage icon,
      String label,
      String route,
      bool isDark,
      Color cardColor,
      ) {
    return GestureDetector(
      onTap: () => GoRouter.of(context).go(route),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xfff0e8d8),
          border: Border.all(color: const Color(0xffe5d9cc), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: icon, width: 48, height: 48),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff6d5d55),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textDirection: TextDirection.rtl,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}