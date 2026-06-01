import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:noor_quran/core/errors/failures.dart';
import '../../domain/entities/reciter_model.dart';
import '../../domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription? _stateSub;

  AudioRepositoryImpl() {
    // Only log in debug mode when explicitly needed
    if (kDebugMode) {
      _stateSub = _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _player.stop();
        }
      });
    }
  }

  Reciter _currentReciter = allReciters.first;

  String get baseUrl => _currentReciter.baseUrl;
  Reciter get currentReciter => _currentReciter;

  void setReciter(Reciter reciter) => _currentReciter = reciter;

  String formatNumber(int surah, int ayah) {
    return '${surah.toString().padLeft(3, '0')}${ayah.toString().padLeft(3, '0')}';
  }

  Stream<PlayerState> get playerState => _player.playerStateStream;
  Stream<int?> get currentIndex => _player.currentIndexStream;
  Stream<Duration?> get position => _player.positionStream;
  Stream<Duration?> get duration => _player.durationStream;

  @override
  Future<Either<Failure, void>> playAyah(int surahId, int ayahNumber) async {
    try {
      final url = '$baseUrl${formatNumber(surahId, ayahNumber)}.mp3';
      await _player.setUrl(url);
      await _player.play();
      return const Right(null);
    } on PlayerException catch (e) {
      return Left(AudioFailure('فشل تشغيل الآية: ${e.message}'));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  Future<void> seek(Duration position) async => _player.seek(position);
  Future<void> next() async => _player.seekToNext();
  Future<void> previous() async => _player.seekToPrevious();

  Future<void> reset() async {
    await _player.pause();
    if (_player.duration != null) {
      await _player.seek(Duration.zero);
    }
  }

  /// Plays a full Surah sequentially. Returns [Either] so errors propagate.
  Future<Either<Failure, void>> playSurahSequential(
    int surahId,
    List<int> ayahs,
  ) async {
    try {
      if (ayahs.isEmpty) {
        return Left(AudioFailure('قائمة الآيات فارغة'));
      }

      final sources = ayahs.map((ayah) {
        final url = '$baseUrl${formatNumber(surahId, ayah)}.mp3';
        return AudioSource.uri(Uri.parse(url), tag: ayah);
      }).toList();

      final playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: sources,
      );

      await _player.stop();
      await _player.setAudioSource(playlist, initialIndex: 0, preload: true);
      await _player.play();
      return const Right(null);
    } on PlayerException catch (e) {
      debugPrint('PlayerException [${e.code}]: ${e.message}');
      return Left(AudioFailure('خطأ في تشغيل الصوت: ${e.message}'));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setRepeatMode(
    String mode, {
    int count = 1,
  }) async {
    try {
      if (mode == "verse") {
        int repeated = 0;

        _player.playerStateStream.listen((state) async {
          if (state.processingState == ProcessingState.completed) {
            repeated++;

            if (repeated < count) {
              await _player.seek(Duration.zero);

              await _player.play();
            } else {
              await _player.stop();
            }
          }
        });
      } else if (mode == "range") {
        int repeated = 0;

        _player.playerStateStream.listen((state) async {
          if (state.processingState == ProcessingState.completed &&
              _player.currentIndex == _player.sequence!.length - 1) {
            repeated++;

            if (repeated < count) {
              await _player.seek(Duration.zero, index: 0);

              await _player.play();
            } else {
              await _player.stop();
            }
          }
        });
      }

      return const Right(null);
    } catch (e) {
      return Left(AudioFailure(e.toString()));
    }
  }
  Future<void> playSingleAyahLoop({
    required int surahId,
    required int ayah,
    required int count,
  }) async {
    int repeated = 0;

    await _player.stop();

    final url = '$baseUrl${formatNumber(surahId, ayah)}.mp3';
    await _player.setUrl(url);

    _player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        repeated++;

        if (repeated < count) {
          await _player.seek(Duration.zero);
          await _player.play();
        } else {
          await _player.stop();
        }
      }
    });

    await _player.play();
  }
  @override
  Future<Either<Failure, void>> pause() async {
    await _player.pause();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> resume() async {
    await _player.play();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> stop() async {
    await _player.stop();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> downloadRecitation(int surahId) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> playSurah(int surahId) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> setSpeed(double speed) =>
      throw UnimplementedError();

  Future<void> dispose() async {
    await _stateSub?.cancel();
    await _player.dispose();
  }
}
