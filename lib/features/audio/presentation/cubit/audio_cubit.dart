import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/audio_repository_impl.dart';
import '../../domain/entities/reciter_model.dart'; // ◄ استيراد
import 'audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  final AudioRepositoryImpl repository;

  AudioCubit(this.repository)
    : super(AudioInitial(reciterName: repository.currentReciter.name));

  StreamSubscription? _sub;
  Stream<Duration?> get position => repository.position;
  Stream<Duration?> get duration => repository.duration;

  Future<void> seek(Duration pos) async {
    await repository.seek(pos);
  }

  Future<void> next() async {
    await repository.next();
  }

  Future<void> previous() async {
    await repository.previous();
  }

  // ◄ تغيير القارئ
  Future<void> changeReciter(Reciter reciter) async {
    final currentAyah = state is AudioPlaying
        ? (state as AudioPlaying).currentAyah
        : null;

    repository.setReciter(reciter);

    await repository.reset();

    emit(AudioStopped(reciterName: reciter.name));
  }

  Future<void> playSurah(List<int> ayahs, int surahId) async {
    await repository.reset();
    _sub?.cancel();

    _sub = repository.currentIndex.listen((index) {
      if (index != null) {
        emit(
          AudioPlaying(
            currentAyah: ayahs[index],
            reciterName: repository.currentReciter.name,
          ),
        );
      }
    });

    await repository.playSurahSequential(surahId, ayahs);
  }

  Future<void> pause() async {
    await repository.pause();
    emit(AudioPaused(reciterName: repository.currentReciter.name));
  }

  Future<void> resume() async {
    await repository.resume();

    final ayah = state is AudioPaused
        ? (state as AudioPaused).currentAyah
        : null;

    emit(
      AudioPlaying(
        currentAyah: ayah,
        reciterName: repository.currentReciter.name,
      ),
    );
  }

  Future<void> stop() async {
    await repository.stop();
    emit(AudioStopped(reciterName: repository.currentReciter.name));
  }

  Future<void> reset() async {
    _sub?.cancel();
    await repository.reset();
    emit(AudioStopped(reciterName: repository.currentReciter.name));
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await repository.dispose();
    return super.close();
  }
}
