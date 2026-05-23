import 'package:equatable/equatable.dart';

class Zikr extends Equatable {
  final int id;
  final String category;
  final String textArabic;
  final String textEnglish;
  final String? translation;
  final int count;
  final String? reference;
  
  const Zikr({
    required this.id,
    required this.category,
    required this.textArabic,
    required this.textEnglish,
    this.translation,
    this.count = 1,
    this.reference,
  });
  
  factory Zikr.fromMap(Map<String, dynamic> map) {
    return Zikr(
      id: map['id'],
      category: map['category'],
      textArabic: map['text_arabic'],
      textEnglish: map['text_english'],
      translation: map['translation'],
      count: map['count'] ?? 1,
      reference: map['reference'],
    );
  }
  
  @override
  List<Object?> get props => [id, category, textArabic];
}