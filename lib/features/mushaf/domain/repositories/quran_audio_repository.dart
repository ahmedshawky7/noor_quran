import '../entities/ayah_ref.dart';
import '../entities/quran_audio_preferences.dart';

class AudioStoredSurahStats {
  const AudioStoredSurahStats({required this.surahNumber, required this.fileCount, required this.bytes});

  final int surahNumber;
  final int fileCount;
  final int bytes;
}

class AudioStorageReciterStats {
  const AudioStorageReciterStats({required this.reciterId, required this.reciterName, required this.fileCount, required this.bytes, required this.surahs});

  final String reciterId;
  final String reciterName;
  final int fileCount;
  final int bytes;
  final List<AudioStoredSurahStats> surahs;

  Set<int> get surahNumbers => surahs.map((item) => item.surahNumber).toSet();
}

class AudioStorageStats {
  const AudioStorageStats({required this.fileCount, required this.bytes, required this.byReciter});

  final int fileCount;
  final int bytes;
  final List<AudioStorageReciterStats> byReciter;
}

enum AudioPlaybackStatus { idle, loading, playing, paused, completed, offline, failure }

abstract interface class QuranAudioRepository {
  Stream<AudioPlaybackStatus> get status;
  Stream<AudioDownloadProgress> get downloadUpdates;
  Stream<AyahRef> get activeAyahChanges;
  QuranReciter get reciter;
  List<QuranReciter> get reciters;
  AudioDownloadMode get downloadMode;
  AudioDownloadProgress get downloadProgress;

  Future<void> initialize();
  Future<void> play(
    AyahRef ayah, {
    required double speed,
    AyahRef? stopAt,
    bool forceRestart = false,
  });
  Future<void> pause();
  Future<void> stop();
  Future<void> setSpeed(double speed);
  Future<void> selectReciter(QuranReciter reciter);
  Future<void> setDownloadMode(AudioDownloadMode mode);
  Future<void> downloadSurah(int surahNumber);
  Future<int> cachedAudioBytes();
  Future<AudioStorageStats> audioStorageStats();
  Future<void> deleteSurahAudio(String reciterId, int surahNumber);
  Future<void> clearAudioCache();
  Future<void> dispose();
}
