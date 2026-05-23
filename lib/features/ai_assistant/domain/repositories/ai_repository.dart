import 'package:dartz/dartz.dart';
import 'package:noor_quran/core/errors/failures.dart';

abstract class AIRepository {
  Future<Either<Failure, String>> explainAyah(String surahName, String ayahText, int ayahNumber);
  Future<Either<Failure, String>> summarizeSurah(String surahName, String surahContent);
  Future<Either<Failure, String>> completeAyah(String partialText);
  Future<Either<Failure, String>> checkMemorization(String userInput, String correctAyah);
  Future<Either<Failure, String>> chat(String userMessage, List<Map<String, String>> history);
  Future<Either<Failure, String>> recommendDailyWird(Map<String, dynamic> userStats);
  Future<Either<Failure, String>> generateReflection(String ayahText);
}