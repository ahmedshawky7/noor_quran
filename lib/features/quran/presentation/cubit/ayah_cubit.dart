import 'package:flutter_bloc/flutter_bloc.dart';
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




}