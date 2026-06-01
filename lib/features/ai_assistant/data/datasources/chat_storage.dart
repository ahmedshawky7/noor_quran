import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_session.dart';

class ChatStorage {
  static final ChatStorage _instance = ChatStorage._internal();
  factory ChatStorage() => _instance;
  ChatStorage._internal();

  static const String _boxName = 'chat_sessions';
  late final Box<String> _box;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
    _isInitialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) await init();
  }

  Future<void> saveSession(ChatSession session) async {
    await _ensureInitialized();
    await _box.put(session.id, jsonEncode(session.toJson()));
  }

  Future<ChatSession?> getSession(String id) async {
    await _ensureInitialized();
    final jsonString = _box.get(id);
    if (jsonString == null) return null;
    return ChatSession.fromJson(jsonDecode(jsonString));
  }

  Future<List<ChatSession>> getAllSessions() async {
    await _ensureInitialized();
    final List<ChatSession> sessions = [];
    for (var key in _box.keys) {
      final jsonString = _box.get(key);
      if (jsonString != null) {
        try {
          sessions.add(ChatSession.fromJson(jsonDecode(jsonString)));
        } catch (_) {}
      }
    }
    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }

  Future<void> deleteSession(String id) async {
    await _ensureInitialized();
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _ensureInitialized();
    await _box.clear();
  }
}