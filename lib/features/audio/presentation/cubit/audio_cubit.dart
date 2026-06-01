import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../../quran/presentation/widgets/advanced_playback_dialog.dart';
import '../../data/repositories/audio_repository_impl.dart';
import '../../domain/entities/reciter_model.dart';
import 'audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  final AudioRepositoryImpl repository;

  StreamSubscription? _sub;
  StreamSubscription? _playerStateSub; // ← أضفها هنا جوه الكلاس

  Stream<Duration?> get position => repository.position;
  Stream<Duration?> get duration => repository.duration;

  AudioCubit(this.repository)
      : super(AudioInitial(reciterName: repository.currentReciter.name)) {
    _playerStateSub = repository.playerState.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _sub?.cancel();
        _sub = null;
        if (this.state is! AudioStopped) {
          emit(AudioStopped(reciterName: repository.currentReciter.name));
        }
      }
    });
  }

  Future<void> seek(Duration pos) async => repository.seek(pos);
  Future<void> next() async => repository.next();
  Future<void> previous() async => repository.previous();

  Future<int?> changeReciter(Reciter reciter) async {
    final currentAyah = state is AudioPlaying
        ? (state as AudioPlaying).currentAyah
        : null;
    try {
      repository.setReciter(reciter);
      await repository.reset();
      emit(AudioStopped(reciterName: reciter.name));
    } catch (e) {
      emit(AudioError(message: "القارئ غير متوفر", reciterName: reciter.name));
    }
    return currentAyah;
  }

  Future<void> playSurah(List<int> ayahs, int surahId) async {
    _sub?.cancel();

    emit(AudioPlaying(
      currentAyah: ayahs.first,
      reciterName: repository.currentReciter.name,
    ));

    _sub = repository.currentIndex.listen((index) {
      if (index != null && index < ayahs.length) {
        emit(AudioPlaying(
          currentAyah: ayahs[index],
          reciterName: repository.currentReciter.name,
        ));
      }
    });

    await repository.playSurahSequential(surahId, ayahs);
  }

  Future<void> pause() async {
    await repository.pause();
    emit(AudioPaused(
      currentAyah: state is AudioPlaying
          ? (state as AudioPlaying).currentAyah
          : null,
      reciterName: repository.currentReciter.name,
    ));
  }

  Future<void> resume() async {
    await repository.resume();
    emit(AudioPlaying(
      currentAyah: state is AudioPaused
          ? (state as AudioPaused).currentAyah
          : null,
      reciterName: repository.currentReciter.name,
    ));
  }

  Future<void> stop() async {
    await repository.stop();
    emit(AudioStopped(reciterName: repository.currentReciter.name));
  }

  Future<void> reset() async {
    _sub?.cancel();
    _sub = null;
    await repository.reset();
    emit(AudioStopped(reciterName: repository.currentReciter.name));
  }

  Future<void> playSurahAdvanced({
    required int surahId,
    required List<int> ayahs,
    required PlaybackEndOption endOption,
    int? endAyah,
    required RepeatMode repeatMode,
    int verseRepeatCount = 1,
    int rangeRepeatCount = 1,
  }) async {
    if (state is AudioLoading) return;

    _sub?.cancel();
    emit(AudioLoading(reciterName: repository.currentReciter.name));

    List<int> filteredAyahs = [...ayahs];

    switch (endOption) {
      case PlaybackEndOption.ayahOnly:
        filteredAyahs = ayahs.isNotEmpty ? [ayahs.first] : [];
        break;
      case PlaybackEndOption.specificAyah:
        if (endAyah != null) {
          filteredAyahs = ayahs.where((a) => a <= endAyah).toList();
        }
        break;
      case PlaybackEndOption.pageEnd:
      case PlaybackEndOption.surahEnd:
      case PlaybackEndOption.continuous:
        break;
    }

    if (filteredAyahs.isEmpty) {
      emit(AudioError(
        message: 'لا توجد آيات في النطاق المحدد',
        reciterName: repository.currentReciter.name,
      ));
      return;
    }

    if (repeatMode == RepeatMode.verse && verseRepeatCount > 1) {
      filteredAyahs = filteredAyahs
          .expand((a) => List.filled(verseRepeatCount, a))
          .toList();
    } else if (repeatMode == RepeatMode.range && rangeRepeatCount > 1) {
      final original = [...filteredAyahs];
      filteredAyahs =
          List.generate(rangeRepeatCount, (_) => original).expand((x) => x).toList();
    }

    await repository.setRepeatMode('off');

    _sub = repository.currentIndex.listen((index) {
      if (index == null || index >= filteredAyahs.length) return;
      emit(AudioPlaying(
        currentAyah: filteredAyahs[index],
        reciterName: repository.currentReciter.name,
      ));
    });

    final result = await repository.playSurahSequential(surahId, filteredAyahs);

    result.fold(
          (failure) {
        _sub?.cancel();
        emit(AudioError(
          message: failure.message,
          reciterName: repository.currentReciter.name,
        ));
      },
          (_) {
        if (state is AudioLoading) {
          emit(AudioPlaying(
            currentAyah: filteredAyahs.first,
            reciterName: repository.currentReciter.name,
          ));
        }
      },
    );
  }

  @override
  Future<void> close() async {
    _sub?.cancel();
    _playerStateSub?.cancel();
    await repository.dispose();
    return super.close();
  }
}