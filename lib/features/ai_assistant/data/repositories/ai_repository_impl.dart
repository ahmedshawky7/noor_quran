import 'package:dartz/dartz.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:noor_quran/core/errors/failures.dart';
import 'package:noor_quran/core/constants/app_constants.dart';
import 'package:noor_quran/features/ai_assistant/domain/repositories/ai_repository.dart';

class AIRepositoryImpl implements AIRepository {
  late final GenerativeModel _model;

  AIRepositoryImpl() {
    final apiKey = AppConstants.geminiApiKey;
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(_getSystemPrompt()),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
        topP: 0.95,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
      ],
    );
  }

  String _getSystemPrompt() {
    return '''
You are "Noor AI" - a helpful, respectful, and educational Islamic assistant.

IMPORTANT RULES:
- Never issue fatwas or religious rulings. Always direct users to qualified scholars.
- Never promote violence, extremism, or sectarianism.
- Stay educational, motivational, and focused on Quran, memorization, and Islamic knowledge.
- Be kind, patient, and inclusive.
- Respond in Arabic by default unless the user asks in English.
''';
  }

  @override
  Future<Either<Failure, String>> chat(
      String userMessage,
      List<Map<String, String>> history,
      ) async {
    try {
      final List<Content> contents = [];

      for (var msg in history) {
        final role = msg['role'] ?? 'user';
        final text = msg['text'] ?? '';
        if (text.isEmpty) continue;

        if (role == 'user') {
          contents.add(Content.text(text));
        } else {
          contents.add(Content.model([TextPart(text)]));
        }
      }

      contents.add(Content.text(userMessage));

      final response = await _model.generateContent(contents);
      final text = response.text?.trim();

      return Right(text?.isNotEmpty == true
          ? text!
          : 'عفواً، لم أفهم الطلب جيداً. هل يمكنك إعادة صياغته؟');
    } catch (e) {
      return Left(AIServiceFailure('خطأ في خدمة الذكاء الاصطناعي: $e'));
    }
  }

  // باقي الدوال (يمكن توسيعها لاحقاً)
  @override
  Future<Either<Failure, String>> explainAyah(
      String surahName, String ayahText, int ayahNumber) async {
    // ... (نفس الكود السابق مع try-catch)
    try {
      final prompt = 'Task: شرح الآية...\nSurah: $surahName\nAyah $ayahNumber: $ayahText';
      final response = await _model.generateContent([Content.text(prompt)]);
      return Right(response.text ?? 'لا توجد إجابة حالياً');
    } catch (e) {
      return Left(AIServiceFailure('خطأ في خدمة الذكاء الاصطناعي: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> summarizeSurah(
      String surahName, String surahContent) async {
    // ... نفس المنهج
    try {
      final prompt = 'Task: لخص السورة...\nSurah: $surahName';
      final response = await _model.generateContent([Content.text(prompt)]);
      return Right(response.text ?? 'لا توجد ملخص حالياً');
    } catch (e) {
      return Left(AIServiceFailure('خطأ في خدمة الذكاء الاصطناعي: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> completeAyah(String partialText) async =>
      Left(AIServiceFailure('غير مفعل حالياً'));

  @override
  Future<Either<Failure, String>> checkMemorization(
      String userInput, String correctAyah) async =>
      Left(AIServiceFailure('غير مفعل حالياً'));

  @override
  Future<Either<Failure, String>> recommendDailyWird(
      Map<String, dynamic> userStats) async =>
      Left(AIServiceFailure('غير مفعل حالياً'));

  @override
  Future<Either<Failure, String>> generateReflection(String ayahText) async =>
      Left(AIServiceFailure('غير مفعل حالياً'));
}