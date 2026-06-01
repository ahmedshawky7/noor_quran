import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_quran/features/ai_assistant/data/datasources/chat_storage.dart';
import 'package:noor_quran/features/ai_assistant/data/models/chat_message.dart';
import 'package:noor_quran/features/ai_assistant/data/models/chat_session.dart';
import 'package:noor_quran/features/ai_assistant/domain/repositories/ai_repository.dart';
import 'package:noor_quran/features/ai_assistant/presentation/cubit/ai_assistant_state.dart';

class AIAssistantCubit extends Cubit<AIAssistantState> {
  final AIRepository _repository;
  final ChatStorage _storage;

  ChatSession? _currentSession;
  List<ChatSession> _allSessions = [];

  AIAssistantCubit(this._repository)
      : _storage = ChatStorage(),
        super(AIAssistantLoading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      await _storage.init();
      await _loadAllSessions();
    } catch (e) {
      emit(AIAssistantError('فشل في تهيئة المحادثات: $e'));
    }
  }

  Future<void> _loadAllSessions() async {
    try {
      _allSessions = await _storage.getAllSessions();
      if (_allSessions.isNotEmpty) {
        await loadSession(_allSessions.first.id);
      } else {
        await newSession();
      }
    } catch (e) {
      emit(AIAssistantError('فشل في تحميل المحادثات: $e'));
    }
  }

  Future<void> loadSession(String sessionId) async {
    try {
      final session = await _storage.getSession(sessionId);
      if (session != null) {
        _currentSession = session;
        emit(AIAssistantSessionLoaded(session));
      } else {
        await newSession();
      }
    } catch (e) {
      emit(AIAssistantError('فشل في تحميل المحادثة: $e'));
    }
  }

  List<Map<String, String>> get chatHistory {
    if (_currentSession == null) return [];
    return _currentSession!.messages
        .map((msg) => {'role': msg.role, 'text': msg.text})
        .toList();
  }

  List<ChatSession> get allSessions => List.unmodifiable(_allSessions);

  Future<void> newSession() async {
    try {
      final newSessionObj = ChatSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'دردشة جديدة',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: [],
      );

      await _storage.saveSession(newSessionObj);
      _allSessions.insert(0, newSessionObj);
      _currentSession = newSessionObj;

      emit(AIAssistantSessionLoaded(newSessionObj));
      emit(AIAssistantSessionsUpdated(List.unmodifiable(_allSessions)));
    } catch (e) {
      emit(AIAssistantError('فشل في إنشاء محادثة جديدة: $e'));
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _storage.deleteSession(sessionId);
      _allSessions.removeWhere((s) => s.id == sessionId);

      if (_currentSession?.id == sessionId) {
        if (_allSessions.isNotEmpty) {
          await loadSession(_allSessions.first.id);
        } else {
          await newSession();
        }
      } else {
        emit(AIAssistantSessionsUpdated(List.unmodifiable(_allSessions)));
      }
    } catch (e) {
      emit(AIAssistantError('فشل في حذف المحادثة: $e'));
    }
  }

  // 🔥 FIXED RENAME - Perfect Solution
  Future<void> renameSession(String sessionId, String newTitle) async {
    try {
      final index = _allSessions.indexWhere((s) => s.id == sessionId);
      if (index == -1) return;

      final oldSession = _allSessions[index];
      final updatedTitle = newTitle.trim().isEmpty ? 'دردشة جديدة' : newTitle.trim();

      // Create completely new ChatSession object with deep copy of messages
      final updatedSession = ChatSession(
        id: oldSession.id,
        title: updatedTitle,
        createdAt: oldSession.createdAt,
        updatedAt: DateTime.now(),
        messages: List<ChatMessage>.from(oldSession.messages), // Deep copy
      );

      // Save to storage
      await _storage.saveSession(updatedSession);

      // Update list
      _allSessions[index] = updatedSession;

      // Update current session if it's the one being renamed
      if (_currentSession?.id == sessionId) {
        _currentSession = updatedSession;
        emit(AIAssistantSessionLoaded(updatedSession));
      }

      // Refresh drawer
      emit(AIAssistantSessionsUpdated(List.unmodifiable(_allSessions)));
    } catch (e) {
      emit(AIAssistantError('فشل في إعادة تسمية المحادثة: $e'));
    }
  }

  Future<void> sendChatMessage(String message) async {
    if (_currentSession == null || message.trim().isEmpty) return;

    try {
      final userMsg = ChatMessage(
        role: 'user',
        text: message.trim(),
        timestamp: DateTime.now(),
      );

      final updatedMessages = List<ChatMessage>.from(_currentSession!.messages)..add(userMsg);

      _currentSession = _currentSession!.copyWith(
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      );

      await _storage.saveSession(_currentSession!);
      emit(AIAssistantSessionLoaded(_currentSession!));

      emit(AIAssistantLoading());

      final result = await _repository.chat(message.trim(), chatHistory);

      result.fold(
            (failure) => emit(AIAssistantError(failure.message)),
            (response) async {
          final modelMsg = ChatMessage(
            role: 'model',
            text: response,
            timestamp: DateTime.now(),
          );

          final newMessages = List<ChatMessage>.from(_currentSession!.messages)..add(modelMsg);

          _currentSession = _currentSession!.copyWith(
            messages: newMessages,
            updatedAt: DateTime.now(),
          );

          await _storage.saveSession(_currentSession!);
          emit(AIAssistantSessionLoaded(_currentSession!));
        },
      );
    } catch (e) {
      emit(AIAssistantError('حدث خطأ أثناء إرسال الرسالة: $e'));
    }
  }
}