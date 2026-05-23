import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:just_audio/just_audio.dart';
import 'package:noor_quran/core/errors/failures.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/reciter_model.dart'; // ◄ استيراد الموديل
import '../../domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioPlayer _player = AudioPlayer();

  Reciter _currentReciter = allReciters.first; // ◄ السديس افتراضي

  String get baseUrl => _currentReciter.baseUrl;

  Reciter get currentReciter => _currentReciter;

  // ◄ دالة تغيير القارئ
  void setReciter(Reciter reciter) {
    _currentReciter = reciter;
  }

  String formatNumber(int surah, int ayah) {
    return surah.toString().padLeft(3, '0') + ayah.toString().padLeft(3, '0');
  }

  Stream<int?> get currentIndex => _player.currentIndexStream;
  Stream<Duration?> get position => _player.positionStream;
  Stream<Duration?> get duration => _player.durationStream;

  @override
  Future<Either<Failure, void>> playAyah(int surahId, int ayahNumber) async {
    try {
      final file = "${formatNumber(surahId, ayahNumber)}.mp3";
      final url = "$baseUrl$file";
      await _player.setUrl(url);
      await _player.play();
      await _player.playerStateStream.firstWhere(
        (s) => s.processingState == ProcessingState.completed,
      );
      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> next() async {
    await _player.seekToNext();
  }

  Future<void> previous() async {
    await _player.seekToPrevious();
  }

  Future<void> reset() async {
    await _player.stop();

    await _player.seek(Duration.zero, index: 0);

    await _player.clearAudioSources();
  }

  Future<void> playSurahSequential(int surahId, List<int> ayahs) async {
    try {
      final playlist = ConcatenatingAudioSource(
        children: ayahs.map((ayah) {
          final file = "${formatNumber(surahId, ayah)}.mp3";

          return AudioSource.uri(Uri.parse("$baseUrl$file"));
        }).toList(),
      );

      await _player.setAudioSource(playlist);

      await _player.play();
    } catch (e) {
      print("Audio Error: $e");
    }
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
  Future<Either<Failure, void>> downloadRecitation(int surahId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> playSurah(int surahId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> setRepeatMode(String mode) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> setSpeed(double speed) {
    throw UnimplementedError();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
