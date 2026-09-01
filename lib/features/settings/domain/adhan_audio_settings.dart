class AdhanVoice {
  const AdhanVoice({required this.id, required this.name, required this.previewUrl, required this.assetPath});

  final String id;
  final String name;
  final String previewUrl;
  final String assetPath;
}

class AdhanAudioSettings {
  const AdhanAudioSettings({
    this.fajr = 'ali_mulla',
    this.sunrise = 'ali_mulla',
    this.dhuhr = 'ali_mulla',
    this.asr = 'ali_mulla',
    this.maghrib = 'ali_mulla',
    this.isha = 'ali_mulla',
  });

  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  String forPrayer(String prayer) {
    switch (prayer) {
      case 'fajr': return fajr;
      case 'sunrise': return sunrise;
      case 'dhuhr': return dhuhr;
      case 'asr': return asr;
      case 'maghrib': return maghrib;
      case 'isha': return isha;
      default: return fajr;
    }
  }

  AdhanAudioSettings copyWith({String? fajr, String? sunrise, String? dhuhr, String? asr, String? maghrib, String? isha}) {
    return AdhanAudioSettings(
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
    );
  }
}

class AdhanVoices {
  static const all = <AdhanVoice>[
    AdhanVoice(id: 'ali_mulla', name: 'الشيخ علي أحمد ملا — أذان مكة', previewUrl: 'https://praytimes.org/audio/sunni/Adhan-Makkah.mp3', assetPath: 'assets/audio/adhan/ali_mulla.mp3'),
    AdhanVoice(id: 'abdul_basit', name: 'الشيخ عبدالباسط عبدالصمد', previewUrl: 'https://praytimes.org/audio/sunni/Abdul-Basit.mp3', assetPath: 'assets/audio/adhan/abdul_basit.mp3'),
    AdhanVoice(id: 'abdul_ghaffar', name: 'الشيخ عبدالغفار', previewUrl: 'https://praytimes.org/audio/sunni/Abdul-Ghaffar.mp3', assetPath: 'assets/audio/adhan/abdul_ghaffar.mp3'),
    AdhanVoice(id: 'abdul_hakam', name: 'الشيخ عبدالحكم', previewUrl: 'https://praytimes.org/audio/sunni/Abdul-Hakam.mp3', assetPath: 'assets/audio/adhan/abdul_hakam.mp3'),
    AdhanVoice(id: 'makkah', name: 'أذان الحرم المكي', previewUrl: 'https://praytimes.org/audio/sunni/Adhan-Makkah.mp3', assetPath: 'assets/audio/adhan/ali_mulla.mp3'),
    AdhanVoice(id: 'madinah', name: 'أذان المدينة المنورة', previewUrl: 'https://praytimes.org/audio/sunni/Adhan-Madinah.mp3', assetPath: 'assets/audio/adhan/madinah.mp3'),
    AdhanVoice(id: 'alaqsa', name: 'أذان المسجد الأقصى', previewUrl: 'https://praytimes.org/audio/sunni/Adhan-Alaqsa.mp3', assetPath: 'assets/audio/adhan/alaqsa.mp3'),
    AdhanVoice(id: 'egypt', name: 'أذان مصر', previewUrl: 'https://praytimes.org/audio/sunni/Adhan-Egypt.mp3', assetPath: 'assets/audio/adhan/egypt.mp3'),
  ];
}
