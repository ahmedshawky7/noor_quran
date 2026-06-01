import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../../domain/entities/surah.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/repositories/quran_repository.dart';
import 'ayah_state.dart';

class AyahCubit extends Cubit<AyahState> {
  final QuranRepository _repository;

  AyahCubit(this._repository) : super(AyahInitial());

  Future<void> loadAyahs(int surahId) async {
    emit(AyahLoading());

    final surahResult = await _repository.getSurahById(surahId);
    final ayahsResult = await _repository.getAyahsBySurah(surahId);

    surahResult.fold(
          (failure) => emit(AyahError(failure.message)),
          (surah) {
        ayahsResult.fold(
              (failure) => emit(AyahError(failure.message)),
              (ayahs) => emit(AyahLoaded(ayahs, surah)),
        );
      },
    );
  }

  /// الحصول على آيتين عشوائيتين يومياً من قاعدة البيانات
  Future<void> loadDailyAyahs() async {
    emit(AyahLoading());

    // احصل على جميع السور
    final surahsResult = await _repository.getAllSurahs();

    surahsResult.fold(
          (failure) => emit(AyahError(failure.message)),
          (surahs) async {
        try {
          // احصل على جميع الآيات من كل السور
          final allAyahs = <Ayah>[];

          for (final surah in surahs) {
            final ayahsResult = await _repository.getAyahsBySurah(surah.id);
            ayahsResult.fold(
                  (failure) => null,
                  (ayahs) => allAyahs.addAll(ayahs),
            );
          }

          if (allAyahs.isEmpty) {
            emit(AyahError('لا توجد آيات في قاعدة البيانات'));
            return;
          }

          // اختر آيتين عشوائيتين بناءً على التاريخ الحالي
          final now = DateTime.now();
          final seed = now.year * 10000 + now.month * 100 + now.day;
          final random = Random(seed);

          allAyahs.shuffle(random);
          final selectedAyahs = allAyahs.take(2).toList();

          // احصل على بيانات السور للآيات المختارة
          final surahMap = {for (var surah in surahs) surah.id: surah};
          final surah = surahMap[selectedAyahs.first.surahId] ?? surahs.first;

          emit(AyahLoaded(selectedAyahs, surah));
        } catch (e) {
          emit(AyahError('خطأ في تحميل الآيات: $e'));
        }
      },
    );
  }
}