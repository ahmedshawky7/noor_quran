import 'package:equatable/equatable.dart';

class Tafsir extends Equatable {
  final int id;
  final int surahId;
  final int ayahNumber;
  final String textArabic;
  final String? textEnglish;
  
  const Tafsir({
    required this.id,
    required this.surahId,
    required this.ayahNumber,
    required this.textArabic,
    this.textEnglish,
  });
  
  factory Tafsir.fromMap(Map<String, dynamic> map) {
    return Tafsir(
      id: map['id'],
      surahId: map['surah_id'],
      ayahNumber: map['ayah_number'],
      textArabic: map['text_arabic'],
      textEnglish: map['text_english'],
    );
  }
  
  @override
  List<Object?> get props => [id, surahId, ayahNumber];
}