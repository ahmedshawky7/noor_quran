import 'package:equatable/equatable.dart';
import '../../domain/entities/surah.dart';

abstract class SurahState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SurahInitial extends SurahState {}
class SurahLoading extends SurahState {}

class SurahLoaded extends SurahState {
  final List<Surah> surahs;

  SurahLoaded(this.surahs);

  @override
  List<Object?> get props => [surahs];
}

class SurahError extends SurahState {
  final String message;

  SurahError(this.message);

  @override
  List<Object?> get props => [message];
}