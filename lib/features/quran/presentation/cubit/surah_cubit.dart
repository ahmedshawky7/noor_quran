import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/surah.dart';
import '../../domain/repositories/quran_repository.dart';
import 'surah_state.dart';

class SurahCubit extends Cubit<SurahState> {
  final QuranRepository _repository;

  SurahCubit(this._repository) : super(SurahInitial()) {
    loadSurahs(); // هنا
  }

  Future<void> loadSurahs() async {
    emit(SurahLoading());

    final result = await _repository.getAllSurahs();

    result.fold(
      (failure) => emit(SurahError(failure.message)),
      (surahs) => emit(SurahLoaded(surahs)),
    );
  }
}
