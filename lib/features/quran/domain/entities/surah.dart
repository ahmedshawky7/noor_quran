import 'dart:convert';

import 'package:equatable/equatable.dart';

class Surah extends Equatable {
  final int id;
  final String name;
  final String nameArabic;
  final String englishName;
  final String revelationType;
  final int totalAyahs;
  final int page;
  final List<dynamic> juzList;
  
  const Surah({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.englishName,
    required this.revelationType,
    required this.totalAyahs,
    required this.page,
    required this.juzList,
  });

  factory Surah.fromMap(Map<String, dynamic> map) {
    return Surah(
      id: map['id'] as int,
      name: map['name'] ?? '',
      nameArabic: map['name_arabic'] ?? '',
      englishName: map['english_name'] ?? '',
      revelationType: map['revelation_type'] ?? '',
      totalAyahs: map['total_ayahs'] as int,
      page: map['page'] as int,
      juzList: map['juz_list'] != null
          ? jsonDecode(map['juz_list'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_arabic': nameArabic,
      'english_name': englishName,
      'revelation_type': revelationType,
      'total_ayahs': totalAyahs,
      'page': page,
      'juz_list': jsonEncode(juzList),
    };
  }
  
  @override
  List<Object?> get props => [id, name, nameArabic];
}