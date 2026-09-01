enum AudioDownloadMode {
  prefetchNext,
  fullSurah,
  smart,
}

extension AudioDownloadModeLabel on AudioDownloadMode {
  String get title => switch (this) {
        AudioDownloadMode.prefetchNext => 'تحميل مسبق للآيات التالية',
        AudioDownloadMode.fullSurah => 'تنزيل السورة كاملة',
        AudioDownloadMode.smart => 'وضع ذكي',
      };

  String get description => switch (this) {
        AudioDownloadMode.prefetchNext =>
            'يحفظ الآية الحالية والآيات الثلاث التالية لتستمر التلاوة بسلاسة.',
        AudioDownloadMode.fullSurah =>
            'ينزل السورة الحالية كاملة أولاً ثم يشغلها من الهاتف دون إنترنت.',
        AudioDownloadMode.smart =>
            'يجهز الآيات الأولى سريعاً ثم يشغل السورة في قائمة متصلة ويحفظ الباقي في الخلفية.',
      };
}

class QuranReciter {
  const QuranReciter({
    required this.id,
    required this.name,
    required this.sourceFolder,
    required this.bitrateLabel,
  });

  final String id;
  final String name;
  final String sourceFolder;
  final String bitrateLabel;

  static const available = <QuranReciter>[
    QuranReciter(id: 'shuraym', name: 'الشيخ سعود الشريم', sourceFolder: 'Saood_ash-Shuraym_64kbps', bitrateLabel: '64 kbps'),
    QuranReciter(id: 'alafasy', name: 'الشيخ مشاري العفاسي', sourceFolder: 'Alafasy_128kbps', bitrateLabel: '128 kbps'),
    QuranReciter(id: 'sudais', name: 'الشيخ عبد الرحمن السديس', sourceFolder: 'Abdurrahmaan_As-Sudais_192kbps', bitrateLabel: '192 kbps'),
    QuranReciter(id: 'muaiqly', name: 'الشيخ ماهر المعيقلي', sourceFolder: 'MaherAlMuaiqly128kbps', bitrateLabel: '128 kbps'),
    QuranReciter(id: 'minshawy', name: 'الشيخ محمد صديق المنشاوي', sourceFolder: 'Minshawy_Murattal_128kbps', bitrateLabel: '128 kbps'),
    QuranReciter(id: 'husary', name: 'الشيخ محمود خليل الحصري', sourceFolder: 'Husary_128kbps', bitrateLabel: '128 kbps'),
    QuranReciter(id: 'abdul_basit', name: 'الشيخ عبد الباسط عبد الصمد', sourceFolder: 'Abdul_Basit_Murattal_192kbps', bitrateLabel: '192 kbps'),
    QuranReciter(id: 'shatry', name: 'الشيخ أبو بكر الشاطري', sourceFolder: 'Abu_Bakr_Ash-Shaatree_128kbps', bitrateLabel: '128 kbps'),
    QuranReciter(id: 'ajmy', name: 'الشيخ أحمد بن علي العجمي', sourceFolder: 'ahmed_ibn_ali_al_ajamy_128kbps', bitrateLabel: '128 kbps'),
    QuranReciter(id: 'hani_rifai', name: 'الشيخ هاني الرفاعي', sourceFolder: 'Hani_Rifai_192kbps', bitrateLabel: '192 kbps'),
    QuranReciter(id: 'hudhaify', name: 'الشيخ علي الحذيفي', sourceFolder: 'Hudhaify_128kbps', bitrateLabel: '128 kbps'),
    QuranReciter(id: 'ayyoub', name: 'الشيخ محمد أيوب', sourceFolder: 'Muhammad_Ayyoub_128kbps', bitrateLabel: '128 kbps'),
    QuranReciter(id: 'jibreel', name: 'الشيخ محمد جبريل', sourceFolder: 'Muhammad_Jibreel_128kbps', bitrateLabel: '128 kbps'),
    QuranReciter(id: 'tablawy', name: 'الشيخ محمد محمود الطبلاوي', sourceFolder: 'Mohammad_al_Tablaway_128kbps', bitrateLabel: '128 kbps'),
    QuranReciter(id: 'fares_abbad', name: 'الشيخ فارس عباد', sourceFolder: 'Fares_Abbad_64kbps', bitrateLabel: '64 kbps'),
    QuranReciter(id: 'budair', name: 'الشيخ صلاح البدير', sourceFolder: 'Salah_Al_Budair_128kbps', bitrateLabel: '128 kbps'),
    QuranReciter(id: 'yasser_dussary', name: 'الشيخ ياسر الدوسري', sourceFolder: 'Yasser_Ad-Dussary_128kbps', bitrateLabel: '128 kbps'),
    QuranReciter(id: 'qatami', name: 'الشيخ ناصر القطامي', sourceFolder: 'Nasser_Alqatami_128kbps', bitrateLabel: '128 kbps'),
    QuranReciter(id: 'banna', name: 'الشيخ محمود علي البنا', sourceFolder: 'mahmoud_ali_al_banna_32kbps', bitrateLabel: '32 kbps'),
    QuranReciter(id: 'juhany', name: 'الشيخ عبد الله عواد الجهني', sourceFolder: 'Abdullaah_3awwaad_Al-Juhaynee_128kbps', bitrateLabel: '128 kbps'),
    QuranReciter(id: 'bukhatir', name: 'الشيخ صلاح عبد الرحمن بكحاتير', sourceFolder: 'Salaah_AbdulRahman_Bukhatir_128kbps', bitrateLabel: '128 kbps'),
  ];

  @override
  bool operator ==(Object other) => other is QuranReciter && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class AudioDownloadProgress {
  const AudioDownloadProgress({
    this.isDownloading = false,
    this.completed = 0,
    this.total = 0,
    this.label = '',
  });

  final bool isDownloading;
  final int completed;
  final int total;
  final String label;

  double get fraction => total == 0 ? 0 : completed / total;
  String get text => total == 0 ? label : '$label ($completed / $total)';
}
