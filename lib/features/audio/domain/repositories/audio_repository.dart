import 'package:dartz/dartz.dart';
import 'package:noor_quran/core/errors/failures.dart';

abstract class AudioRepository {
  Future<Either<Failure, void>> playSurah(int surahId);
  Future<Either<Failure, void>> playAyah(int surahId, int ayahNumber);
  Future<Either<Failure, void>> pause();
  Future<Either<Failure, void>> resume();
  Future<Either<Failure, void>> stop();
  Future<Either<Failure, void>> setSpeed(double speed);
  Future<Either<Failure, void>> setRepeatMode(String mode);
  Future<Either<Failure, void>> downloadRecitation(int surahId);
}