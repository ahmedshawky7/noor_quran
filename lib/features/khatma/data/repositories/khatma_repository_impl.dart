import 'package:dartz/dartz.dart';
import 'package:noor_quran/core/database/dao/khatma_dao.dart';
import 'package:noor_quran/core/errors/failures.dart';
import 'package:noor_quran/features/khatma/domain/entities/khatma_progress.dart';
import 'package:noor_quran/features/khatma/domain/repositories/khatma_repository.dart';

class KhatmaRepositoryImpl implements KhatmaRepository {
  final KhatmaDao _khatmaDao;
  
  KhatmaRepositoryImpl(this._khatmaDao);
  
  @override
  Future<Either<Failure, void>> startKhatma(int targetDays, int pagesPerDay) async {
    try {
      final progress = KhatmaProgress(
        id: 0,
        targetDays: targetDays,
        pagesPerDay: pagesPerDay,
        currentPage: 1,
        startDate: DateTime.now(),
        lastUpdate: DateTime.now(),
      );
      await _khatmaDao.saveKhatmaProgress(progress);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to start khatma: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> updateProgress(int pagesRead) async {
    try {
      final current = await _khatmaDao.getCurrentKhatma();
      if (current != null) {
        final newPage = current.currentPage + pagesRead;
        final completed = newPage >= (current.pagesPerDay * current.targetDays);
        final updated = KhatmaProgress(
          id: current.id,
          targetDays: current.targetDays,
          pagesPerDay: current.pagesPerDay,
          currentPage: newPage,
          startDate: current.startDate,
          lastUpdate: DateTime.now(),
          completed: completed,
        );
        await _khatmaDao.updateKhatmaProgress(updated);
      }
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update progress: $e'));
    }
  }
  
  @override
  Future<Either<Failure, KhatmaProgress?>> getCurrentKhatma() async {
    try {
      final progress = await _khatmaDao.getCurrentKhatma();
      return Right(progress);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get khatma: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> completeKhatma() async {
    try {
      final current = await _khatmaDao.getCurrentKhatma();
      if (current != null) {
        final completed = KhatmaProgress(
          id: current.id,
          targetDays: current.targetDays,
          pagesPerDay: current.pagesPerDay,
          currentPage: current.currentPage,
          startDate: current.startDate,
          lastUpdate: DateTime.now(),
          completed: true,
        );
        await _khatmaDao.updateKhatmaProgress(completed);
      }
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to complete khatma: $e'));
    }
  }
}