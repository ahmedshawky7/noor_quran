import 'package:equatable/equatable.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';

abstract class AyahState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AyahInitial extends AyahState {}
class AyahLoading extends AyahState {}

class AyahLoaded extends AyahState {
  final List<Ayah> ayahs;
  final Surah surah;

  AyahLoaded(this.ayahs, this.surah);

  @override
  List<Object?> get props => [ayahs, surah];
}

class AyahError extends AyahState {
  final String message;

  AyahError(this.message);

  @override
  List<Object?> get props => [message];
}