enum AdvancedRecitationMode {
  pageEnd,
  surahEnd,
  continuous,
  untilAyah,
}

extension AdvancedRecitationModeLabel on AdvancedRecitationMode {
  String get title => switch (this) {
        AdvancedRecitationMode.pageEnd => 'حتى نهاية الصفحة',
        AdvancedRecitationMode.surahEnd => 'حتى نهاية السورة',
        AdvancedRecitationMode.continuous => 'تلاوة مستمرة',
        AdvancedRecitationMode.untilAyah => 'حتى آية تحددها',
      };

  String get description => switch (this) {
        AdvancedRecitationMode.pageEnd =>
            'يتوقف تلقائياً بعد آخر آية ظاهرة في الصفحة الحالية.',
        AdvancedRecitationMode.surahEnd =>
            'يتوقف تلقائياً بعد آخر آية من السورة الحالية.',
        AdvancedRecitationMode.continuous =>
            'يتابع بين الصفحات والسور حتى توقفه أنت أو يصل لنهاية المصحف.',
        AdvancedRecitationMode.untilAyah =>
            'اختر رقم آية في السورة الحالية ليتوقف بعدها.',
      };
}
