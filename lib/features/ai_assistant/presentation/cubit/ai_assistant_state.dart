import 'package:equatable/equatable.dart';
import 'package:noor_quran/features/ai_assistant/data/models/chat_session.dart';

abstract class AIAssistantState extends Equatable {
  const AIAssistantState();
  @override
  List<Object?> get props => [];
}

class AIAssistantInitial extends AIAssistantState {}

class AIAssistantLoading extends AIAssistantState {}

class AIAssistantError extends AIAssistantState {
  final String message;
  const AIAssistantError(this.message);
  @override
  List<Object?> get props => [message];
}

class AIAssistantSessionLoaded extends AIAssistantState {
  final ChatSession session;
  const AIAssistantSessionLoaded(this.session);
  @override
  List<Object?> get props => [session];
}

class AIAssistantSessionsUpdated extends AIAssistantState {
  final List<ChatSession> sessions;
  const AIAssistantSessionsUpdated(this.sessions);
  @override
  List<Object?> get props => [sessions];
}