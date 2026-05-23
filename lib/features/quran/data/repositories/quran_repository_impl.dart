import 'package:dartz/dartz.dart';
import 'package:noor_quran/core/database/dao/quran_dao.dart';
import 'package:noor_quran/core/database/dao/last_read_dao.dart';
import 'package:noor_quran/core/errors/failures.dart';
import 'package:noor_quran/features/quran/domain/entities/surah.dart';
import 'package:noor_quran/features/quran/domain/entities/ayah.dart';
import 'package:noor_quran/features/quran/domain/entities/tafsir.dart';
import 'package:noor_quran/features/quran/domain/entities/last_read.dart';
import 'package:noor_quran/features/quran/domain/repositories/quran_repository.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranDao _quranDao;
  final LastReadDao _lastReadDao;
  
  QuranRepositoryImpl(this._quranDao, this._lastReadDao);
  
  @override
  Future<Either<Failure, List<Surah>>> getAllSurahs() async {
    try {
      final surahs = await _quranDao.getAllSurahs();
      return Right(surahs);
    } catch (e) {
      return Left(DatabaseFailure('Failed to load surahs: $e'));
    }
  }
  
  @override
  Future<Either<Failure, Surah>> getSurahById(int id) async {
    try {
      final surah = await _quranDao.getSurahById(id);
      if (surah != null) {
        return Right(surah);
      } else {
        return Left(DatabaseFailure('Surah not found'));
      }
    } catch (e) {
      return Left(DatabaseFailure('Failed to load surah: $e'));
    }
  }
  
  @override
  Future<Either<Failure, List<Ayah>>> getAyahsBySurah(int surahId) async {
    try {
      final ayahs = await _quranDao.getAyahsBySurah(surahId);
      return Right(ayahs);
    } catch (e) {
      return Left(DatabaseFailure('Failed to load ayahs: $e'));
    }
  }
  
  @override
  Future<Either<Failure, Ayah>> getAyah(int surahId, int ayahNumber) async {
    try {
      final ayah = await _quranDao.getAyah(surahId, ayahNumber);
      if (ayah != null) {
        return Right(ayah);
      } else {
        return Left(DatabaseFailure('Ayah not found'));
      }
    } catch (e) {
      return Left(DatabaseFailure('Failed to load ayah: $e'));
    }
  }
  
  @override
  Future<Either<Failure, Tafsir?>> getTafsir(int surahId, int ayahNumber) async {
    try {
      final tafsir = await _quranDao.getTafsir(surahId, ayahNumber);
      return Right(tafsir);
    } catch (e) {
      return Left(DatabaseFailure('Failed to load tafsir: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> saveLastRead(LastRead lastRead) async {
    try {
      await _lastReadDao.saveLastRead(lastRead);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save last read: $e'));
    }
  }
  
  @override
  Future<Either<Failure, LastRead?>> getLastRead() async {
    try {
      final lastRead = await _lastReadDao.getLastRead();
      return Right(lastRead);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get last read: $e'));
    }
  }
}