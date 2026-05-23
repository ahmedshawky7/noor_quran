import 'package:dartz/dartz.dart';
import 'package:noor_quran/core/errors/failures.dart';
import 'package:noor_quran/features/quran/domain/entities/surah.dart';
import 'package:noor_quran/features/quran/domain/entities/ayah.dart';
import 'package:noor_quran/features/quran/domain/entities/tafsir.dart';
import 'package:noor_quran/features/quran/domain/entities/last_read.dart';

abstract class QuranRepository {
  Future<Either<Failure, List<Surah>>> getAllSurahs();
  Future<Either<Failure, Surah>> getSurahById(int id);
  Future<Either<Failure, List<Ayah>>> getAyahsBySurah(int surahId);
  Future<Either<Failure, Ayah>> getAyah(int surahId, int ayahNumber);
  Future<Either<Failure, Tafsir?>> getTafsir(int surahId, int ayahNumber);
  Future<Either<Failure, void>> saveLastRead(LastRead lastRead);
  Future<Either<Failure, LastRead?>> getLastRead();
}