import 'package:equatable/equatable.dart';

class Hadith extends Equatable {
  final int id;
  final String collection;
  final int? bookNumber;
  final int? hadithNumber;
  final String? textArabic;
  final String textEnglish;
  final String? grade;
  
  const Hadith({
    required this.id,
    required this.collection,
    this.bookNumber,
    this.hadithNumber,
    this.textArabic,
    required this.textEnglish,
    this.grade,
  });
  
  factory Hadith.fromMap(Map<String, dynamic> map) {
    return Hadith(
      id: map['id'],
      collection: map['collection'],
      bookNumber: map['book_number'],
      hadithNumber: map['hadith_number'],
      textArabic: map['text_arabic'],
      textEnglish: map['text_english'],
      grade: map['grade'],
    );
  }
  
  @override
  List<Object?> get props => [id, collection, hadithNumber];
}