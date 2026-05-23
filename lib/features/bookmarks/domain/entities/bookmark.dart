import 'package:equatable/equatable.dart';

class Bookmark extends Equatable {
  final int id;
  final int surahId;
  final int ayahNumber;
  final String? note;
  final DateTime createdAt;
  final String folderName;
  
  const Bookmark({
    required this.id,
    required this.surahId,
    required this.ayahNumber,
    this.note,
    required this.createdAt,
    this.folderName = 'Default',
  });
  
  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'],
      surahId: map['surah_id'],
      ayahNumber: map['ayah_number'],
      note: map['note'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      folderName: map['folder_name'] ?? 'Default',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surah_id': surahId,
      'ayah_number': ayahNumber,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
      'folder_name': folderName,
    };
  }
  
  @override
  List<Object?> get props => [id, surahId, ayahNumber];
}