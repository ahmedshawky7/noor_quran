// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:noor_quran/features/quran/domain/entities/last_read.dart';
// import 'package:noor_quran/features/quran/domain/repositories/quran_repository.dart';
// import 'package:noor_quran/features/quran/presentation/cubit/quran_state.dart';
//
// class QuranCubit extends Cubit<QuranState> {
//   final QuranRepository _repository;
//
//   QuranCubit(this._repository) : super(QuranInitial());
//
//   Future<void> loadSurahs() async {
//     if (state is SurahsLoaded) return; // مهم جدًا
//
//     emit(QuranLoading());
//
//     final result = await _repository.getAllSurahs();
//
//     result.fold(
//           (failure) => emit(QuranError(failure.message)),
//           (surahs) => emit(SurahsLoaded(surahs)),
//     );
//   }
//
//   Future<void> loadAyahs(int surahId) async {
//     emit(QuranLoading());
//     final surahResult = await _repository.getSurahById(surahId);
//     final ayahsResult = await _repository.getAyahsBySurah(surahId);
//
//     surahResult.fold((failure) => emit(QuranError(failure.message)), (surah) {
//       ayahsResult.fold(
//         (failure) => emit(QuranError(failure.message)),
//         (ayahs) => emit(AyahsLoaded(ayahs, surah)),
//       );
//     });
//   }
//
//   Future<void> loadTafsir(int surahId, int ayahNumber) async {
//     final result = await _repository.getTafsir(surahId, ayahNumber);
//     result.fold(
//       (failure) => emit(QuranError(failure.message)),
//       (tafsir) => emit(TafsirLoaded(tafsir)),
//     );
//   }
//
//   Future<void> loadLastRead() async {
//     final result = await _repository.getLastRead();
//     result.fold(
//       (failure) => emit(QuranError(failure.message)),
//       (lastRead) => emit(LastReadLoaded(lastRead)),
//     );
//   }
//
//   Future<void> saveLastRead(int surahId, int ayahNumber, int pageNumber) async {
//     final lastRead = LastRead(
//       id: 0,
//       surahId: surahId,
//       ayahNumber: ayahNumber,
//       pageNumber: pageNumber,
//       timestamp: DateTime.now(),
//     );
//     final result = await _repository.saveLastRead(lastRead);
//
//     result.fold((failure) => emit(QuranError(failure.message)), (_) {});
//   }
// }
