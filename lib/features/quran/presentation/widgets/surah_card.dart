import 'package:flutter/material.dart';
import 'package:noor_quran/features/quran/domain/entities/surah.dart';

class SurahCard extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const SurahCard({
    super.key,
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xff1a472a);

    return Directionality(
      textDirection: TextDirection.rtl, // ⭐ أهم سطر

      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),

          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),

            child: Row(
              children: [

                // 🔵 رقم السورة (يمين فعليًا)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${surah.id}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // 📖 النص (في اليمين)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // ⚠️ مهم: start هنا = يمين بسبب RTL

                    children: [

                      // ⭐ اسم السورة (هيفضل في اليمين)
                      Text(
                        surah.nameArabic,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Amiri',
                          color: Color(0xff1a472a),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // التفاصيل
                      Text(
                        '${surah.englishName} • ${surah.totalAyahs} verses • ${surah.revelationType}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // ⬅️ السهم (يسار طبيعي في RTL)
                const Icon(
                  Icons.chevron_left,
                  color: Color(0xff1a472a),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}