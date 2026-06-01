import 'package:flutter/material.dart';
import '../../../audio/domain/entities/reciter_model.dart';

enum PlaybackEndOption { ayahOnly, pageEnd, surahEnd, continuous, specificAyah }

enum RepeatMode { off, verse, range }

class AdvancedPlaybackDialog extends StatefulWidget {
  final String surahName;
  final int surahId;
  final int startAyah;
  final int totalAyahs;
  final int pageNumber;
  final Reciter currentReciter;
  final Function(
    PlaybackEndOption endOption,
    int? endAyah,
    RepeatMode repeatMode,
    int verseRepeatCount,
    int rangeRepeatCount,
  )?
  onStart;

  const AdvancedPlaybackDialog({
    super.key,
    required this.surahName,
    required this.surahId,
    required this.startAyah,
    required this.totalAyahs,
    required this.pageNumber,
    required this.currentReciter,
    this.onStart,
  });

  static Future<void> show({
    required BuildContext context,
    required String surahName,
    required int surahId,
    required int startAyah,
    required int totalAyahs,
    required int pageNumber,
    required Reciter currentReciter,
    Function(
      PlaybackEndOption endOption,
      int? endAyah,
      RepeatMode repeatMode,
      int verseRepeatCount,
      int rangeRepeatCount,
    )?
    onStart,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xfff8f3e8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => AdvancedPlaybackDialog(
        surahName: surahName,
        surahId: surahId,
        startAyah: startAyah,
        totalAyahs: totalAyahs,
        pageNumber: pageNumber,
        currentReciter: currentReciter,
        onStart: onStart,
      ),
    );
  }

  @override
  State<AdvancedPlaybackDialog> createState() => _AdvancedPlaybackDialogState();
}

class _AdvancedPlaybackDialogState extends State<AdvancedPlaybackDialog> {
  PlaybackEndOption? _endOption; // ← null = لسه محددش حاجة
  RepeatMode _repeatMode = RepeatMode.off;
  int? _specificAyah;

  int _verseRepeatCount = 1;
  int _rangeRepeatCount = 1;

  String _toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < 10; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xff1a472a)),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'تشغيل من ${widget.surahName}: ${_toArabicNumbers(widget.startAyah.toString())}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1c2a1f),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'قم باختيار موضع نهاية التلاوة:',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),

            // قائمة الخيارات
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // ⬇️ الخيار الجديد
                  _buildOptionRow(
                    label: 'الآية المحددة فقط',
                    value:
                        'آية ${_toArabicNumbers(widget.startAyah.toString())}',
                    isSelected: _endOption == PlaybackEndOption.ayahOnly,
                    onTap: () =>
                        setState(() => _endOption = PlaybackEndOption.ayahOnly),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildOptionRow(
                    label: 'إلى نهاية الصفحة',
                    value:
                        'الصفحة ${_toArabicNumbers(widget.pageNumber.toString())}',
                    isSelected: _endOption == PlaybackEndOption.pageEnd,
                    onTap: () =>
                        setState(() => _endOption = PlaybackEndOption.pageEnd),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildOptionRow(
                    label: 'إلى نهاية السورة',
                    value: widget.surahName,
                    isSelected: _endOption == PlaybackEndOption.surahEnd,
                    onTap: () =>
                        setState(() => _endOption = PlaybackEndOption.surahEnd),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildOptionRow(
                    label: 'تلاوة مستمرة',
                    value: '∞',
                    isSelected: _endOption == PlaybackEndOption.continuous,
                    onTap: () => setState(
                      () => _endOption = PlaybackEndOption.continuous,
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildOptionRow(
                    label: 'إلى آية معينة',
                    value: _specificAyah != null
                        ? _toArabicNumbers(_specificAyah.toString())
                        : 'اختر الآية',
                    isSelected: _endOption == PlaybackEndOption.specificAyah,
                    trailingWidget: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 14,
                      color: Colors.grey,
                    ),
                    onTap: () => _showAyahSelector(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'التكرار',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1a472a),
                ),
              ),
            ),

            // أزرار التبديل (Switches)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'تكرار النطاق',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                    value: _repeatMode == RepeatMode.range,
                    onChanged: (v) {
                      setState(() {
                        _repeatMode = v ? RepeatMode.range : RepeatMode.off;
                      });
                    },
                  ),
                  if (_repeatMode == RepeatMode.range)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButton<int>(
                        value: _rangeRepeatCount,
                        isExpanded: true,
                        items: List.generate(
                          10,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text("${i + 1} مرات"),
                          ),
                        ),
                        onChanged: (v) {
                          setState(() {
                            _rangeRepeatCount = v!;
                          });
                        },
                      ),
                    ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: const Text(
                      "تكرار الآية",
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                    value: _repeatMode == RepeatMode.verse,
                    onChanged: (v) {
                      setState(() {
                        _repeatMode = v ? RepeatMode.verse : RepeatMode.off;
                      });
                    },
                  ),
                  if (_repeatMode == RepeatMode.verse)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButton<int>(
                        value: _verseRepeatCount,
                        isExpanded: true,
                        items: List.generate(
                          10,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text("${i + 1} مرات"),
                          ),
                        ),
                        onChanged: (v) {
                          setState(() {
                            _verseRepeatCount = v!;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ⬇️ زر التشغيل مع الحماية من الـ null
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _endOption == null
                    ? null
                    : () {
                        widget.onStart?.call(
                          _endOption!,
                          _specificAyah,
                          _repeatMode,
                          _verseRepeatCount,
                          _rangeRepeatCount,
                        );
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _endOption == null
                      ? Colors.grey.shade400
                      : const Color(0xff839969),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _endOption == null
                      ? 'اختر موضع النهاية أولاً'
                      : 'تشغيل التلاوة',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? trailingWidget,
  }) {
    return ListTile(
      onTap: onTap,
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xff1a472a) : const Color(0xff1c2a1f),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: isSelected ? const Color(0xff7fa069) : Colors.grey,
            ),
          ),
          if (trailingWidget != null) ...[
            const SizedBox(width: 8),
            trailingWidget,
          ] else if (isSelected) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check, size: 18, color: Color(0xff7fa069)),
          ],
        ],
      ),
    );
  }

  void _showAyahSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xfff8f3e8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: 350,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'اختر آية النهاية (${widget.surahName})',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.totalAyahs,
                  itemBuilder: (context, index) {
                    final ayahNum = index + 1;
                    if (ayahNum < widget.startAyah) {
                      return const SizedBox.shrink();
                    }
                    return ListTile(
                      title: Text(
                        'الآية ${_toArabicNumbers(ayahNum.toString())}',
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      trailing: _specificAyah == ayahNum
                          ? const Icon(Icons.check, color: Color(0xff7fa069))
                          : null,
                      onTap: () {
                        setState(() {
                          _specificAyah = ayahNum;
                          _endOption = PlaybackEndOption.specificAyah;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
