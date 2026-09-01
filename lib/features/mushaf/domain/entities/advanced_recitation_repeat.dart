enum AdvancedRecitationRepeat {
  none,
  ayah,
  range,
  surah,
}

extension AdvancedRecitationRepeatLabel on AdvancedRecitationRepeat {
  String get title => switch (this) {
        AdvancedRecitationRepeat.none => 'بدون تكرار',
        AdvancedRecitationRepeat.ayah => 'تكرار الآية',
        AdvancedRecitationRepeat.range => 'تكرار النطاق',
        AdvancedRecitationRepeat.surah => 'تكرار السورة',
      };

  String get description => switch (this) {
        AdvancedRecitationRepeat.none => 'يتوقف عند نهاية الحد المختار',
        AdvancedRecitationRepeat.ayah => 'اختر عدد مرات إعادة الآية التي بدأت منها',
        AdvancedRecitationRepeat.range => 'اختر عدد مرات إعادة النطاق حتى الحد المختار',
        AdvancedRecitationRepeat.surah => 'يعيد السورة كاملة من أولها إلى آخرها',
      };
}
