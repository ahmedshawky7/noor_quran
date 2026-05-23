import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_quran/features/ai_assistant/domain/repositories/ai_repository.dart';
import 'package:noor_quran/features/ai_assistant/presentation/cubit/ai_assistant_state.dart';

class AIAssistantCubit extends Cubit<AIAssistantState> {
  final AIRepository _repository;
  List<Map<String, String>> _chatHistory = [];
  
  AIAssistantCubit(this._repository) : super(AIAssistantInitial());
  
  Future<void> explainAyah({required String surahName, required String ayahText, required int ayahNumber}) async {
    emit(AIAssistantLoading());
    final result = await _repository.explainAyah(surahName, ayahText, ayahNumber);
    result.fold(
      (failure) => emit(AIAssistantError(failure.message)),
      (response) => emit(AIAssistantResponse(response)),
    );
  }
  
  Future<void> summarizeSurah(String surahName, String surahContent) async {
    emit(AIAssistantLoading());
    final result = await _repository.summarizeSurah(surahName, surahContent);
    result.fold(
      (failure) => emit(AIAssistantError(failure.message)),
      (response) => emit(AIAssistantResponse(response)),
    );
  }
  
  Future<void> checkMemorization(String userInput, String correctAyah) async {
    emit(AIAssistantLoading());
    final result = await _repository.checkMemorization(userInput, correctAyah);
    result.fold(
      (failure) => emit(AIAssistantError(failure.message)),
      (response) => emit(AIAssistantResponse(response)),
    );
  }
  
  Future<void> sendChatMessage(String message) async {
    emit(AIAssistantLoading());
    _chatHistory.add({'user': message});
    final result = await _repository.chat(message, _chatHistory);
    result.fold(
      (failure) => emit(AIAssistantError(failure.message)),
      (response) {
        _chatHistory.add({'assistant': response});
        emit(AIAssistantResponse(response));
      },
    );
  }
  
  void clearChatHistory() {
    _chatHistory.clear();
    emit(AIAssistantInitial());
  }
}