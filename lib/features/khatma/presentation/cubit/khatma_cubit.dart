import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_quran/features/khatma/domain/repositories/khatma_repository.dart';
import 'package:noor_quran/features/khatma/presentation/cubit/khatma_state.dart';

class KhatmaCubit extends Cubit<KhatmaState> {
  final KhatmaRepository _repository;
  
  KhatmaCubit(this._repository) : super(KhatmaInitial());
  
  Future<void> loadCurrentKhatma() async {
    emit(KhatmaLoading());
    final result = await _repository.getCurrentKhatma();
    result.fold(
      (failure) => emit(KhatmaError(failure.message)),
      (progress) {
        if (progress != null) {
          if (progress.completed) {
            emit(KhatmaCompleted());
          } else {
            emit(KhatmaActive(progress));
          }
        } else {
          emit(KhatmaInitial());
        }
      },
    );
  }
  
  Future<void> startKhatma(int targetDays, int pagesPerDay) async {
    emit(KhatmaLoading());
    final result = await _repository.startKhatma(targetDays, pagesPerDay);
    result.fold(
      (failure) => emit(KhatmaError(failure.message)),
      (_) => loadCurrentKhatma(),
    );
  }
  
  Future<void> updateProgress(int pagesRead) async {
    final result = await _repository.updateProgress(pagesRead);
    result.fold(
      (failure) => emit(KhatmaError(failure.message)),
      (_) => loadCurrentKhatma(),
    );
  }
}