import 'package:flutter/material.dart';
import 'package:noor_quran/features/quran/domain/entities/ayah.dart';

class AyahCard extends StatelessWidget {
  final Ayah ayah;
  final String surahName;

  final VoidCallback onBookmarkPressed;
  final VoidCallback onTafsirPressed;
  final VoidCallback onAISexplainPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onCopyPressed;

  const AyahCard({
    super.key,
    required this.ayah,
    required this.surahName,
    required this.onBookmarkPressed,
    required this.onTafsirPressed,
    required this.onAISexplainPressed,
    required this.onSharePressed,
    required this.onCopyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🔹 Text (reading style)
          Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  ayah.textUthmani,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 2.0,
                  ),
                  textAlign: TextAlign.right,
                ),

                const SizedBox(width: 6),

                // 🔹 Ayah number bubble
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: Text(
                    '${ayah.ayahNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 🔹 Actions (smaller + cleaner)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: onBookmarkPressed,
              ),
              IconButton(
                icon: const Icon(Icons.description_outlined),
                onPressed: onTafsirPressed,
              ),
              IconButton(
                icon: const Icon(Icons.smart_toy_outlined),
                onPressed: onAISexplainPressed,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: onSharePressed,
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: onCopyPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}