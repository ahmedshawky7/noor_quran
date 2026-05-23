import 'package:equatable/equatable.dart';
import 'package:noor_quran/features/khatma/domain/entities/khatma_progress.dart';

abstract class KhatmaState extends Equatable {
  const KhatmaState();
  
  @override
  List<Object?> get props => [];
}

class KhatmaInitial extends KhatmaState {}

class KhatmaLoading extends KhatmaState {}

class KhatmaActive extends KhatmaState {
  final KhatmaProgress progress;
  const KhatmaActive(this.progress);
  
  @override
  List<Object?> get props => [progress];
}

class KhatmaCompleted extends KhatmaState {}

class KhatmaError extends KhatmaState {
  final String message;
  const KhatmaError(this.message);
  
  @override
  List<Object?> get props => [message];
}