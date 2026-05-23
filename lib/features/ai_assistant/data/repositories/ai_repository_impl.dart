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
      model: 'gemini-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 1024,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
      ],
    );
  }
  
  String _getSystemPrompt(String task) {
    return '''
You are a helpful Islamic educational assistant called "Noor AI". 
IMPORTANT RULES:
- NEVER give fatwas or religious rulings. Always advise consulting qualified scholars for legal matters.
- NEVER promote extremism, violence, or sectarianism.
- NEVER engage in political or divisive religious debates.
- ONLY provide educational explanations, Quranic context, language help, memorization tips, and motivational reminders.
- For any question that asks for a ruling, respond: "I cannot provide a fatwa. Please consult a qualified scholar."
- Be respectful, inclusive, and kind.

Task: $task
''';
  }
  
  @override
  Future<Either<Failure, String>> explainAyah(String surahName, String ayahText, int ayahNumber) async {
    try {
      final prompt = '''
${_getSystemPrompt('Explain this ayah in simple Arabic/English, focusing on vocabulary, lessons, and reflection.')}

Surah: $surahName, Ayah $ayahNumber
Text: $ayahText

Provide a clear, concise explanation (max 200 words) that helps the user understand and reflect. Include:
- Basic meaning
- Key vocabulary
- Practical lesson
- Reflection question
''';
      final response = await _model.generateContent([Content.text(prompt)]);
      return Right(response.text ?? 'No explanation available.');
    } catch (e) {
      return Left(AIServiceFailure('AI service error: $e'));
    }
  }
  
  @override
  Future<Either<Failure, String>> summarizeSurah(String surahName, String surahContent) async {
    try {
      final prompt = '''
${_getSystemPrompt('Summarize this surah')}

Surah: $surahName
Content: $surahContent

Provide a 100-150 word summary mentioning main themes, key stories, and lessons.
''';
      final response = await _model.generateContent([Content.text(prompt)]);
      return Right(response.text ?? 'No summary available.');
    } catch (e) {
      return Left(AIServiceFailure('AI service error: $e'));
    }
  }
  
  @override
  Future<Either<Failure, String>> completeAyah(String partialText) async {
    try {
      final prompt = '''
${_getSystemPrompt('Complete the ayah')}

The user started: "$partialText"
Complete this Quranic verse in a way that matches the Quran. If unsure, suggest similar verses.
''';
      final response = await _model.generateContent([Content.text(prompt)]);
      return Right(response.text ?? 'Could not complete the ayah.');
    } catch (e) {
      return Left(AIServiceFailure('AI service error: $e'));
    }
  }
  
  @override
  Future<Either<Failure, String>> checkMemorization(String userInput, String correctAyah) async {
    try {
      final prompt = '''
${_getSystemPrompt('Help with memorization')}

User's attempt: "$userInput"
Correct ayah: "$correctAyah"

Highlight differences, suggest corrections, and give a memorization tip. Be encouraging.
''';
      final response = await _model.generateContent([Content.text(prompt)]);
      return Right(response.text ?? 'No feedback available.');
    } catch (e) {
      return Left(AIServiceFailure('AI service error: $e'));
    }
  }
  
  @override
  Future<Either<Failure, String>> chat(String userMessage, List<Map<String, String>> history) async {
    try {
      final messages = [
        Content.text(_getSystemPrompt('General Islamic educational chat')),
        ...history.map((msg) => Content.text(msg.values.first)).toList(),
        Content.text(userMessage),
      ];
      final response = await _model.generateContent(messages);
      return Right(response.text ?? 'I cannot answer that. Please ask something else.');
    } catch (e) {
      return Left(AIServiceFailure('AI service error: $e'));
    }
  }
  
  @override
  Future<Either<Failure, String>> recommendDailyWird(Map<String, dynamic> userStats) async {
    try {
      final prompt = '''
${_getSystemPrompt('Recommend daily wird (reading plan)')}

User stats: $userStats
Based on their activity, suggest a personalized daily reading plan (number of pages, surahs, or azkar) that is achievable and motivating.
''';
      final response = await _model.generateContent([Content.text(prompt)]);
      return Right(response.text ?? 'Recommendation: Read 1 juz per day.');
    } catch (e) {
      return Left(AIServiceFailure('AI service error: $e'));
    }
  }
  
  @override
  Future<Either<Failure, String>> generateReflection(String ayahText) async {
    try {
      final prompt = '''
${_getSystemPrompt('Generate a reflection')}

Ayah: "$ayahText"
Write a short, inspiring reflection (max 150 words) that helps the user apply the verse's wisdom in daily life.
''';
      final response = await _model.generateContent([Content.text(prompt)]);
      return Right(response.text ?? 'Reflect on the mercy and wisdom of Allah.');
    } catch (e) {
      return Left(AIServiceFailure('AI service error: $e'));
    }
  }
}