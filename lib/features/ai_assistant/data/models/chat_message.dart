import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 0)
class ChatMessage extends Equatable {
  @HiveField(0)
  final String role;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
  });

  // JSON Serialization
  Map<String, dynamic> toJson() => {
    'role': role,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: json['role'] as String,
    text: json['text'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  @override
  List<Object?> get props => [role, text, timestamp];
}