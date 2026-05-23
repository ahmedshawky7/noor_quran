// import 'package:equatable/equatable.dart';
// import 'package:noor_quran/features/quran/domain/entities/surah.dart';
// import 'package:noor_quran/features/quran/domain/entities/ayah.dart';
// import 'package:noor_quran/features/quran/domain/entities/tafsir.dart';
// import 'package:noor_quran/features/quran/domain/entities/last_read.dart';
//
// abstract class QuranState extends Equatable {
//   const QuranState();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class QuranInitial extends QuranState {}
//
// class QuranLoading extends QuranState {}
//
// class SurahsLoaded extends QuranState {
//   final List<Surah> surahs;
//   const SurahsLoaded(this.surahs);
//
//   @override
//   List<Object?> get props => [surahs];
// }
//
// class AyahsLoaded extends QuranState {
//   final List<Ayah> ayahs;
//   final Surah surah;
//   const AyahsLoaded(this.ayahs, this.surah);
//
//   @override
//   List<Object?> get props => [ayahs, surah];
// }
//
// class TafsirLoaded extends QuranState {
//   final Tafsir? tafsir;
//   const TafsirLoaded(this.tafsir);
//
//   @override
//   List<Object?> get props => [tafsir];
// }
//
// class LastReadLoaded extends QuranState {
//   final LastRead? lastRead;
//   const LastReadLoaded(this.lastRead);
//
//   @override
//   List<Object?> get props => [lastRead];
// }
//
// class QuranError extends QuranState {
//   final String message;
//   const QuranError(this.message);
//
//   @override
//   List<Object?> get props => [message];
// }