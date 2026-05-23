import 'package:equatable/equatable.dart';

class Ayah extends Equatable {
  final int id;
  final int surahId;
  final int ayahNumber;
  final String textUthmani;
  final String textSimple;
  final int juz;
  final int hizb;           // ✅ جديد
  final int hizbQuarter;    // ✅ جديد
  final int page;
  final bool isSajda;

  const Ayah({
    required this.id,
    required this.surahId,
    required this.ayahNumber,
    required this.textUthmani,
    required this.textSimple,
    required this.juz,
    this.hizb = 0,
    this.hizbQuarter = 0,
    required this.page,
    this.isSajda = false,
  });

  Ayah copyWith({
    int? id,
    int? surahId,
    int? ayahNumber,
    String? textUthmani,
    String? textSimple,
    int? juz,
    int? hizb,
    int? hizbQuarter,
    int? page,
    bool? isSajda,
  }) {
    return Ayah(
      id: id ?? this.id,
      surahId: surahId ?? this.surahId,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      textUthmani: textUthmani ?? this.textUthmani,
      textSimple: textSimple ?? this.textSimple,
      juz: juz ?? this.juz,
      hizb: hizb ?? this.hizb,
      hizbQuarter: hizbQuarter ?? this.hizbQuarter,
      page: page ?? this.page,
      isSajda: isSajda ?? this.isSajda,
    );
  }

  factory Ayah.fromMap(Map<String, dynamic> map) {
    return Ayah(
      id: map['id'] as int? ?? 0,
      surahId: map['surah_id'] as int? ?? 0,
      ayahNumber: map['ayah_number'] as int? ?? 0,
      textUthmani: map['text_uthmani'] ?? '',
      textSimple: map['text_simple'] ?? '',
      juz: map['juz'] as int? ?? 0,
      hizb: map['hizb'] as int? ?? 0,
      hizbQuarter: map['hizb_quarter'] as int? ?? 0,
      page: map['page'] as int? ?? 0,
      isSajda: map['sajda'] == 1 || map['sajda'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surah_id': surahId,
      'ayah_number': ayahNumber,
      'text_uthmani': textUthmani,
      'text_simple': textSimple,
      'juz': juz,
      'hizb': hizb,
      'hizb_quarter': hizbQuarter,
      'page': page,
      'sajda': isSajda ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [id, surahId, ayahNumber];
}