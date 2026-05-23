// lib/features/audio/domain/entities/reciter_model.dart
class Reciter {
  final String id;
  final String name;
  final String baseUrl;

  const Reciter({required this.id, required this.name, required this.baseUrl});
}

final List<Reciter> allReciters = [
  // -- القراء المشهورون --
  const Reciter(
    id: 'sudais',
    name: 'عبدالرحمن السديس',
    baseUrl: 'https://everyayah.com/data/Abdurrahmaan_As-Sudais_192kbps/',
  ),
  const Reciter(
    id: 'shuraim',
    name: 'سعود الشريم',
    baseUrl: 'https://everyayah.com/data/Saood_ash-Shuraym_128kbps/',
  ),
  const Reciter(
    id: 'maher',
    name: 'ماهر المعيقلي',
    baseUrl: 'https://everyayah.com/data/Maher_AlMuaiqly_64kbps/',
  ),
  const Reciter(
    id: 'afasy',
    name: 'مشاري العفاسي',
    baseUrl: 'https://everyayah.com/data/Alafasy_128kbps/',
  ),
  const Reciter(
    id: 'husary',
    name: 'محمود خليل الحصري (مرتل)',
    baseUrl: 'https://everyayah.com/data/Husary_128kbps/',
  ),
  const Reciter(
    id: 'husary_mujawwad',
    name: 'محمود خليل الحصري (مجود)',
    baseUrl: 'https://everyayah.com/data/Husary_128kbps_Mujawwad/',
  ),
  const Reciter(
    id: 'husary_muallim',
    name: 'محمود خليل الحصري (معلم)',
    baseUrl: 'https://everyayah.com/data/Husary_Muallim_128kbps/',
  ),
  const Reciter(
    id: 'minshawi',
    name: 'محمد صديق المنشاوي (مرتل)',
    baseUrl: 'https://everyayah.com/data/Minshawy_Murattal_128kbps/',
  ),
  const Reciter(
    id: 'minshawi_mujawwad',
    name: 'محمد صديق المنشاوي (مجود)',
    baseUrl: 'https://everyayah.com/data/Minshawy_Mujawwad_192kbps/',
  ),
  const Reciter(
    id: 'minshawi_teacher',
    name: 'محمد صديق المنشاوي (معلم)',
    baseUrl: 'https://everyayah.com/data/Minshawy_Teacher_128kbps/',
  ),
  const Reciter(
    id: 'ghamdi',
    name: 'سعد الغامدي',
    baseUrl: 'https://everyayah.com/data/Ghamadi_40kbps/',
  ),
  const Reciter(
    id: 'basit',
    name: 'عبدالباسط عبدالصمد (مرتل)',
    baseUrl: 'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/',
  ),
  const Reciter(
    id: 'basit_mujawwad',
    name: 'عبدالباسط عبدالصمد (مجود)',
    baseUrl: 'https://everyayah.com/data/Abdul_Basit_Mujawwad_128kbps/',
  ),
  const Reciter(
    id: 'ajmi',
    name: 'أحمد العجمي',
    baseUrl: 'https://everyayah.com/data/Ahmed_ibn_Ali_al-Ajmy_64kbps_QuranExplorer.Com/',
  ),
  const Reciter(
    id: 'juhany',
    name: 'عبدالله الجهني',
    baseUrl: 'https://everyayah.com/data/Abdullaah_3awwaad_Al-Juhaynee_128kbps/',
  ),
  const Reciter(
    id: 'jaber',
    name: 'علي جابر',
    baseUrl: 'https://everyayah.com/data/Ali_Jaber_64kbps/',
  ),
  const Reciter(
    id: 'abbad',
    name: 'فارس عباد',
    baseUrl: 'https://everyayah.com/data/Fares_Abbad_64kbps/',
  ),

  // -- قراء إضافيون بارزون --
  const Reciter(
    id: 'ayyoub',
    name: 'محمد أيوب',
    baseUrl: 'https://everyayah.com/data/Muhammad_Ayyoub_128kbps/',
  ),
  const Reciter(
    id: 'jibreel',
    name: 'محمد جبريل',
    baseUrl: 'https://everyayah.com/data/Muhammad_Jibreel_128kbps/',
  ),
  const Reciter(
    id: 'budair',
    name: 'صلاح البدير',
    baseUrl: 'https://everyayah.com/data/Salah_Al_Budair_128kbps/',
  ),
  const Reciter(
    id: 'bukhatir',
    name: 'صلاح البخاتير',
    baseUrl: 'https://everyayah.com/data/Salaah_AbdulRahman_Bukhatir_128kbps/',
  ),
  const Reciter(
    id: 'rifai',
    name: 'هاني الرفاعي',
    baseUrl: 'https://everyayah.com/data/Hani_Rifai_192kbps/',
  ),
  const Reciter(
    id: 'huzaify',
    name: 'علي حذيفي',
    baseUrl: 'https://everyayah.com/data/Hudhaify_128kbps/',
  ),
  const Reciter(
    id: 'dossary',
    name: 'ياسر الدوسري',
    baseUrl: 'https://everyayah.com/data/Yasser_Ad-Dussary_128kbps/',
  ),
  const Reciter(
    id: 'salamah',
    name: 'ياسر سلامة',
    baseUrl: 'https://everyayah.com/data/Yaser_Salamah_128kbps/',
  ),
  const Reciter(
    id: 'tablaway',
    name: 'محمد الطبلاوي',
    baseUrl: 'https://everyayah.com/data/Mohammad_al_Tablaway_128kbps/',
  ),
  const Reciter(
    id: 'muhsin',
    name: 'محسن القاسم',
    baseUrl: 'https://everyayah.com/data/Muhsin_Al_Qasim_192kbps/',
  ),
  const Reciter(
    id: 'basfar',
    name: 'عبدالله بصفر',
    baseUrl: 'https://everyayah.com/data/Abdullah_Basfar_192kbps/',
  ),
  const Reciter(
    id: 'matroud',
    name: 'عبدالله متروك',
    baseUrl: 'https://everyayah.com/data/Abdullah_Matroud_128kbps/',
  ),
  const Reciter(
    id: 'akhdar',
    name: 'إبراهيم الأخضر',
    baseUrl: 'https://everyayah.com/data/Ibrahim_Akhdar_64kbps/',
  ),
  const Reciter(
    id: 'mansoori',
    name: 'كريم منصوري',
    baseUrl: 'https://everyayah.com/data/Karim_Mansoori_40kbps/',
  ),
  const Reciter(
    id: 'qahtani',
    name: 'خالد القحطاني',
    baseUrl: 'https://everyayah.com/data/Khaalid_Abdullaah_al-Qahtaanee_192kbps/',
  ),
  const Reciter(
    id: 'abdulkarim',
    name: 'محمد عبدالكريم',
    baseUrl: 'https://everyayah.com/data/Muhammad_AbdulKareem_128kbps/',
  ),
  const Reciter(
    id: 'neana',
    name: 'أحمد نعينع',
    baseUrl: 'https://everyayah.com/data/Ahmed_Neana_128kbps/',
  ),
  const Reciter(
    id: 'suwaysi',
    name: 'علي حجاج السويسي',
    baseUrl: 'https://everyayah.com/data/Ali_Hajjaj_AlSuesy_128kbps/',
  ),
  const Reciter(
    id: 'sowaid',
    name: 'أيمن سويد',
    baseUrl: 'https://everyayah.com/data/Ayman_Sowaid_64kbps/',
  ),
  const Reciter(
    id: 'shaatree',
    name: 'أبو بكر الشاطري',
    baseUrl: 'https://everyayah.com/data/Abu_Bakr_Ash-Shaatree_128kbps/',
  ),
  const Reciter(
    id: 'alili',
    name: 'عزيز العليلي',
    baseUrl: 'https://everyayah.com/data/aziz_alili_128kbps/',
  ),
  const Reciter(
    id: 'banna',
    name: 'محمود علي البنا',
    baseUrl: 'https://everyayah.com/data/mahmoud_ali_al_banna_32kbps/',
  ),
  const Reciter(
    id: 'tunaiji',
    name: 'خليفة الطنيجي',
    baseUrl: 'https://everyayah.com/data/khalefa_al_tunaiji_64kbps/',
  ),
  const Reciter(
    id: 'samad',
    name: 'عبدالصمد',
    baseUrl: 'https://everyayah.com/data/AbdulSamad_64kbps_QuranExplorer.Com/',
  ),
  const Reciter(
    id: 'akram',
    name: 'أكرم العلاقمي',
    baseUrl: 'https://everyayah.com/data/Akram_AlAlaqimy_128kbps/',
  ),
  const Reciter(
    id: 'ismail',
    name: 'مصطفى إسماعيل',
    baseUrl: 'https://everyayah.com/data/Mustafa_Ismail_48kbps/',
  ),
  const Reciter(
    id: 'rifai3',
    name: 'نبيل الرفاعي',
    baseUrl: 'https://everyayah.com/data/Nabil_Rifa3i_48kbps/',
  ),
  const Reciter(
    id: 'yassin',
    name: 'سهل ياسين',
    baseUrl: 'https://everyayah.com/data/Sahl_Yassin_128kbps/',
  ),
  const Reciter(
    id: 'qatami',
    name: 'ناصر القطامي',
    baseUrl: 'https://everyayah.com/data/Nasser_Alqatami_128kbps/',
  ),
];