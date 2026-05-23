import 'package:equatable/equatable.dart';

abstract class AIAssistantState extends Equatable {
  const AIAssistantState();
  
  @override
  List<Object?> get props => [];
}

class AIAssistantInitial extends AIAssistantState {}

class AIAssistantLoading extends AIAssistantState {}

class AIAssistantResponse extends AIAssistantState {
  final String response;
  const AIAssistantResponse(this.response);
  
  @override
  List<Object?> get props => [response];
}

class AIAssistantStreaming extends AIAssistantState {
  final String partialResponse;
  const AIAssistantStreaming(this.partialResponse);
  
  @override
  List<Object?> get props => [partialResponse];
}

class AIAssistantError extends AIAssistantState {
  final String message;
  const AIAssistantError(this.message);
  
  @override
  List<Object?> get props => [message];
}