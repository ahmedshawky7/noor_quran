import 'package:dartz/dartz.dart';
import 'package:noor_quran/core/errors/failures.dart';
import 'package:noor_quran/features/khatma/domain/entities/khatma_progress.dart';

abstract class KhatmaRepository {
  Future<Either<Failure, void>> startKhatma(int targetDays, int pagesPerDay);
  Future<Either<Failure, void>> updateProgress(int pagesRead);
  Future<Either<Failure, KhatmaProgress?>> getCurrentKhatma();
  Future<Either<Failure, void>> completeKhatma();
}