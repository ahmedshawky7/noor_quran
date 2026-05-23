import 'package:equatable/equatable.dart';

class LastRead extends Equatable {
  final int id;
  final int surahId;
  final int ayahNumber;
  final int pageNumber;
  final DateTime timestamp;
  
  const LastRead({
    required this.id,
    required this.surahId,
    required this.ayahNumber,
    required this.pageNumber,
    required this.timestamp,
  });
  
  factory LastRead.fromMap(Map<String, dynamic> map) {
    return LastRead(
      id: map['id'],
      surahId: map['surah_id'],
      ayahNumber: map['ayah_number'],
      pageNumber: map['page_number'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surah_id': surahId,
      'ayah_number': ayahNumber,
      'page_number': pageNumber,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
  
  @override
  List<Object?> get props => [id, surahId, ayahNumber, timestamp];
}