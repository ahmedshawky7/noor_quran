import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/ayah_ref.dart';
import '../../domain/entities/quran_audio_preferences.dart';
import '../../domain/repositories/mushaf_repository.dart';
import '../../domain/repositories/quran_audio_repository.dart';

/// ينزّل ملفات الآيات مرة واحدة إلى الهاتف، ثم يشغّل النسخة المحلية دائماً.
class _AudioNetworkUnavailableException implements Exception {
  const _AudioNetworkUnavailableException();
}

class JustAudioQuranRepository implements QuranAudioRepository {
  JustAudioQuranRepository({
    required SharedPreferences preferences,
    required MushafRepository mushafRepository,
  })  : _preferences = preferences,
        _mushafRepository = mushafRepository {
    _subscription = _player.playerStateStream.listen(_mapState);
    _sequenceSubscription = _player.sequenceStateStream.listen(_mapSequenceState);
  }

  static const _reciterKey = 'quran_audio_reciter';
  static const _downloadModeKey = 'quran_audio_download_mode';
  static const _baseUrl = 'https://everyayah.com/data';

  final SharedPreferences _preferences;
  final MushafRepository _mushafRepository;
  final AudioPlayer _player = AudioPlayer();
  final http.Client _client = http.Client();
  final StreamController<AudioPlaybackStatus> _statusController =
      StreamController<AudioPlaybackStatus>.broadcast();
  final StreamController<AudioDownloadProgress> _downloadController =
      StreamController<AudioDownloadProgress>.broadcast();
  final StreamController<AyahRef> _activeAyahController =
      StreamController<AyahRef>.broadcast();
  final Map<String, Future<File>> _activeDownloads = {};
  late final StreamSubscription<PlayerState> _subscription;
  late final StreamSubscription<SequenceState?> _sequenceSubscription;
  late Directory _cacheRoot;

  Future<void> _operationQueue = Future<void>.value();
  AyahRef? _loadedAyah;
  List<AyahRef> _playlistAyahs = const [];
  QuranReciter _reciter = QuranReciter.available.first;
  AudioDownloadMode _downloadMode = AudioDownloadMode.smart;
  AudioDownloadProgress _downloadProgress = const AudioDownloadProgress();
  bool _isStoppedByUser = false;
  bool _isDisposed = false;
  bool _isDisposing = false;
  bool _initialized = false;
  int _playRequestId = 0;
  int _smartPlaylistGeneration = 0;

  @override
  Stream<AudioPlaybackStatus> get status => _statusController.stream;
  @override
  Stream<AudioDownloadProgress> get downloadUpdates => _downloadController.stream;
  @override
  Stream<AyahRef> get activeAyahChanges => _activeAyahController.stream;
  @override
  QuranReciter get reciter => _reciter;
  @override
  List<QuranReciter> get reciters => QuranReciter.available;
  @override
  AudioDownloadMode get downloadMode => _downloadMode;
  @override
  AudioDownloadProgress get downloadProgress => _downloadProgress;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    final savedReciter = _preferences.getString(_reciterKey);
    _reciter = QuranReciter.available.firstWhere(
      (item) => item.id == savedReciter,
      orElse: () => QuranReciter.available.first,
    );
    final savedMode = _preferences.getInt(_downloadModeKey);
    if (savedMode != null && savedMode >= 0 && savedMode < AudioDownloadMode.values.length) {
      _downloadMode = AudioDownloadMode.values[savedMode];
    }
    final supportDirectory = await getApplicationSupportDirectory();
    _cacheRoot = Directory('${supportDirectory.path}/quran_audio_cache');
    if (!await _cacheRoot.exists()) await _cacheRoot.create(recursive: true);
    _initialized = true;
  }

  @override
  Future<void> pause() => _enqueue(() async {
        _isStoppedByUser = false;
        await _player.pause();
      });

  @override
  Future<void> play(
    AyahRef ayah, {
    required double speed,
    AyahRef? stopAt,
    bool forceRestart = false,
  }) => _enqueue(() async {
        _isStoppedByUser = false;
        try {
          // أمر من قائمة الآية: أوقف المصدر الحالي ولا تسمح بإشارة قديمة
          // أن تجعل الطلب الجديد يبدو كاستئناف.
          if (forceRestart) {
            await _player.pause();
            _loadedAyah = null;
            _playlistAyahs = const [];
          }
          // الإيقاف المؤقت يحتفظ بالـ playlist وبموضع الثواني الحالي.
          // يجب فحصه قبل وضع تنزيل السورة حتى لا تُبنى القائمة من جديد.
          final canResume = !forceRestart &&
              _loadedAyah == ayah &&
              _player.processingState != ProcessingState.idle &&
              _player.processingState != ProcessingState.completed;
          if (canResume) {
            await _player.setSpeed(speed);
            _startPlayback();
            return;
          }
          _smartPlaylistGeneration++;
          _emitStatus(AudioPlaybackStatus.loading);
          if (_downloadMode == AudioDownloadMode.fullSurah) {
            await _downloadSurahInternal(ayah.surahNumber);
            await _playDownloadedSurah(ayah, speed: speed, stopAt: stopAt);
            return;
          }
          if (_downloadMode == AudioDownloadMode.smart) {
            await _playSmartPlaylist(ayah, speed: speed, stopAt: stopAt);
            return;
          }
          final audioFile = await _downloadAyah(ayah);
          _playlistAyahs = const [];
          await _player.setSpeed(speed);
          await _player.pause();
          _loadedAyah = ayah;
          await _player.setFilePath(audioFile.path);
          _startPlayback();
          unawaited(_prepareFollowingAudio(ayah));
        } on _AudioNetworkUnavailableException {
          _emitStatus(AudioPlaybackStatus.offline);
        } on PlayerInterruptedException {
          _emitStatus(AudioPlaybackStatus.idle);
        } catch (_) {
          _emitStatus(AudioPlaybackStatus.failure);
        }
      });

  /// يبني قائمة تشغيل من ملفات السورة المحفوظة؛ ينتقل JustAudio بينها
  /// داخل نفس المشغل، فلا ينشأ MediaCodec جديد بين آية وأخرى.
  Future<void> _playDownloadedSurah(
    AyahRef startAyah, {
    required double speed,
    AyahRef? stopAt,
  }) async {
    final ayahs = _playlistRange(startAyah, stopAt: stopAt);
    final sources = <AudioSource>[];
    for (final ayah in ayahs) {
      final file = await _downloadAyah(ayah);
      sources.add(AudioSource.file(file.path));
    }
    _playlistAyahs = ayahs;
    _loadedAyah = startAyah;
    await _player.pause();
    await _player.setSpeed(speed);
    await _player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: 0,
      initialPosition: Duration.zero,
    );
    _startPlayback();
  }

  /// ينشئ الوضع الذكي مخزوناً قصيراً قبل التشغيل، ثم يضيف الآيات التالية
  /// إلى قائمة المشغل نفسها أثناء القراءة؛ لذلك لا تصدر نهاية وهمية بين الآيات.
  Future<void> _playSmartPlaylist(
    AyahRef startAyah, {
    required double speed,
    AyahRef? stopAt,
  }) async {
    final ayahs = _playlistRange(startAyah, stopAt: stopAt);
    final prebufferCount = ayahs.length < 3 ? ayahs.length : 3;
    final initialAyahs = ayahs.take(prebufferCount).toList();
    final initialFiles = await Future.wait(initialAyahs.map(_downloadAyah));
    final playlist = ConcatenatingAudioSource(
      children: initialFiles.map((file) => AudioSource.file(file.path)).toList(),
    );
    final generation = _smartPlaylistGeneration;
    _playlistAyahs = ayahs;
    _loadedAyah = startAyah;
    await _player.pause();
    await _player.setSpeed(speed);
    await _player.setAudioSource(
      playlist,
      initialIndex: 0,
      initialPosition: Duration.zero,
    );
    _startPlayback();
    unawaited(_appendSmartPlaylistSources(
      playlist,
      ayahs.skip(prebufferCount),
      generation: generation,
    ));
  }

  Future<void> _appendSmartPlaylistSources(
    ConcatenatingAudioSource playlist,
    Iterable<AyahRef> ayahs, {
    required int generation,
  }) async {
    try {
      for (final ayah in ayahs) {
        final file = await _downloadAyah(ayah);
        if (_isDisposed || generation != _smartPlaylistGeneration) return;
        await playlist.add(AudioSource.file(file.path));
      }
    } catch (_) {
      // يظل المخزون الذي أُضيف قابلاً للتشغيل، ويعيد المتحكم المحاولة عند الحاجة.
    }
  }

  List<AyahRef> _playlistRange(AyahRef start, {AyahRef? stopAt}) {
    final result = <AyahRef>[];
    var current = start;
    while (true) {
      result.add(current);
      if (current == stopAt) break;
      final count = _mushafRepository.ayahCountForSurah(current.surahNumber);
      // دون حد متقدم، تحافظ القائمة على السورة الحالية فقط؛ المتحكم ينتقل بعدها للسورة التالية.
      if (stopAt == null && current.ayahNumber >= count) break;
      if (current.ayahNumber < count) {
        current = AyahRef(
          surahNumber: current.surahNumber,
          ayahNumber: current.ayahNumber + 1,
          pageNumber: _mushafRepository.pageForAyah(current.surahNumber, current.ayahNumber + 1),
        );
      } else if (current.surahNumber < 114) {
        current = AyahRef(
          surahNumber: current.surahNumber + 1,
          ayahNumber: 1,
          pageNumber: _mushafRepository.pageForAyah(current.surahNumber + 1, 1),
        );
      } else {
        break;
      }
    }
    return result;
  }

  // AudioPlayer.play() يعيد Future لا يكتمل إلا عند نهاية المقطع؛ لا ننتظره
  // داخل طابور الأوامر حتى يستطيع المتحكم تجهيز الآية التالية فوراً.
  void _startPlayback() {
    final requestId = ++_playRequestId;
    unawaited(_player.play().catchError((Object error, StackTrace stackTrace) {
      // خطأ مقاطعة مقطع قديم طبيعي عند الانتقال إلى المقطع التالي.
      if (_isDisposed || requestId != _playRequestId || error is PlayerInterruptedException) {
        return;
      }
      _emitStatus(AudioPlaybackStatus.failure);
    }));
  }

  @override
  Future<void> setSpeed(double speed) => _enqueue(() => _player.setSpeed(speed));

  @override
  Future<void> stop() => _enqueue(() async {
        _playRequestId++;
        _smartPlaylistGeneration++;
        _isStoppedByUser = true;
        await _player.pause();
        await _player.seek(Duration.zero);
        _loadedAyah = null;
        _playlistAyahs = const [];
        _emitStatus(AudioPlaybackStatus.idle);
      });

  @override
  Future<void> selectReciter(QuranReciter reciter) async {
    if (_reciter == reciter) return;
    await stop();
    _reciter = reciter;
    await _preferences.setString(_reciterKey, reciter.id);
  }

  @override
  Future<void> setDownloadMode(AudioDownloadMode mode) async {
    _downloadMode = mode;
    await _preferences.setInt(_downloadModeKey, mode.index);
  }

  @override
  Future<void> downloadSurah(int surahNumber) => _downloadSurahInternal(surahNumber);

  Future<void> _prepareFollowingAudio(AyahRef ayah) async {
    if (_downloadMode != AudioDownloadMode.prefetchNext) return;
    final next = _nextAyahs(ayah, 3);
    await Future.wait(next.map(_downloadAyah));
  }

  Future<void> _downloadSurahInternal(int surahNumber, {bool quiet = false}) async {
    final ayahCount = _mushafRepository.ayahCountForSurah(surahNumber);
    // إذا كانت السورة مكتملة في ذاكرة الهاتف، لا نعرض عملية تنزيل صورية.
    if (await _isSurahCached(surahNumber, ayahCount)) {
      _setDownloadProgress(const AudioDownloadProgress(label: 'السورة محفوظة محلياً'));
      return;
    }
    _setDownloadProgress(AudioDownloadProgress(
      isDownloading: true,
      completed: 0,
      total: ayahCount,
      label: quiet ? 'يحفظ السورة في الخلفية' : 'ينزل السورة للحفظ دون إنترنت',
    ));
    try {
      for (var ayah = 1; ayah <= ayahCount; ayah++) {
        await _downloadAyah(AyahRef(
          surahNumber: surahNumber,
          ayahNumber: ayah,
          pageNumber: _mushafRepository.pageForAyah(surahNumber, ayah),
        ));
        _setDownloadProgress(AudioDownloadProgress(
          isDownloading: true,
          completed: ayah,
          total: ayahCount,
          label: quiet ? 'يحفظ السورة في الخلفية' : 'ينزل السورة للحفظ دون إنترنت',
        ));
      }
      _setDownloadProgress(const AudioDownloadProgress(label: 'اكتمل تنزيل السورة'));
    } catch (_) {
      _setDownloadProgress(const AudioDownloadProgress(label: 'تعذر تنزيل بعض ملفات السورة'));
    }
  }

  Future<bool> _isSurahCached(int surahNumber, int ayahCount) async {
    final directory = Directory('${_cacheRoot.path}/${_reciter.id}');
    if (!await directory.exists()) return false;
    for (var ayah = 1; ayah <= ayahCount; ayah++) {
      final file = File('${directory.path}/${_fileName(AyahRef(
        surahNumber: surahNumber,
        ayahNumber: ayah,
        pageNumber: _mushafRepository.pageForAyah(surahNumber, ayah),
      ))}');
      if (!await file.exists() || await file.length() == 0) return false;
    }
    return true;
  }

  List<AyahRef> _nextAyahs(AyahRef ayah, int count) {
    final next = <AyahRef>[];
    var surah = ayah.surahNumber;
    var verse = ayah.ayahNumber;
    while (next.length < count && surah <= 114) {
      final total = _mushafRepository.ayahCountForSurah(surah);
      if (verse < total) {
        verse++;
      } else {
        surah++;
        verse = 1;
      }
      if (surah > 114) break;
      next.add(AyahRef(
        surahNumber: surah,
        ayahNumber: verse,
        pageNumber: _mushafRepository.pageForAyah(surah, verse),
      ));
    }
    return next;
  }

  Future<File> _downloadAyah(AyahRef ayah) {
    // نلتقط القارئ عند بداية الطلب حتى لا تختلط ملفات قارئ قديم بآخر جديد.
    final reciterForRequest = _reciter;
    final cacheKey = '${reciterForRequest.id}_${ayah.surahNumber}_${ayah.ayahNumber}';
    return _activeDownloads.putIfAbsent(cacheKey, () async {
      try {
        final directory = Directory('${_cacheRoot.path}/${reciterForRequest.id}');
        if (!await directory.exists()) await directory.create(recursive: true);
        final file = File('${directory.path}/${_fileName(ayah)}');
        if (await file.exists() && await file.length() > 0) return file;

        // لا نحاول تنزيل ملف غير موجود عند عدم وجود إنترنت فعلي.
        if (!await InternetConnection().hasInternetAccess) {
          throw const _AudioNetworkUnavailableException();
        }
        final response = await _client.get(Uri.parse(_sourceUrl(ayah, reciterForRequest)));
        if (response.statusCode != HttpStatus.ok || response.bodyBytes.isEmpty) {
          throw HttpException('Unable to download ${_fileName(ayah)}');
        }
        final temporary = File('${file.path}.part');
        await temporary.writeAsBytes(response.bodyBytes, flush: true);
        if (await file.exists()) await file.delete();
        return temporary.rename(file.path);
      } finally {
        _activeDownloads.remove(cacheKey);
      }
    });
  }

  String _fileName(AyahRef ayah) =>
      '${ayah.surahNumber.toString().padLeft(3, '0')}${ayah.ayahNumber.toString().padLeft(3, '0')}.mp3';
  String _sourceUrl(AyahRef ayah, QuranReciter reciter) =>
      '$_baseUrl/${reciter.sourceFolder}/${_fileName(ayah)}';

  Future<void> _enqueue(Future<void> Function() operation) {
    _operationQueue = _operationQueue.catchError((_) {}).then((_) async {
      if (_isDisposed || _isDisposing) return;
      await operation();
    });
    return _operationQueue.catchError((_) {});
  }

  void _setDownloadProgress(AudioDownloadProgress progress) {
    _downloadProgress = progress;
    if (!_isDisposed && !_downloadController.isClosed) _downloadController.add(progress);
  }

  void _emitStatus(AudioPlaybackStatus status) {
    if (!_isDisposed && !_statusController.isClosed) _statusController.add(status);
  }

  void _mapSequenceState(SequenceState? state) {
    if (_isDisposed || state == null || _playlistAyahs.isEmpty) return;
    final index = state.currentIndex;
    if (index == null || index < 0 || index >= _playlistAyahs.length) return;
    final ayah = _playlistAyahs[index];
    if (_loadedAyah == ayah) return;
    _loadedAyah = ayah;
    if (!_activeAyahController.isClosed) _activeAyahController.add(ayah);
  }

  void _mapState(PlayerState state) {
    if (_isDisposed || _statusController.isClosed) return;
    if (_isStoppedByUser && !state.playing) {
      _emitStatus(AudioPlaybackStatus.idle);
    } else if (state.processingState == ProcessingState.completed) {
      _emitStatus(AudioPlaybackStatus.completed);
    } else if (state.playing) {
      _emitStatus(AudioPlaybackStatus.playing);
    } else if (state.processingState == ProcessingState.idle) {
      _emitStatus(AudioPlaybackStatus.idle);
    } else {
      _emitStatus(AudioPlaybackStatus.paused);
    }
  }

  @override
  Future<int> cachedAudioBytes() async {
    if (!_initialized || !await _cacheRoot.exists()) return 0;
    var total = 0;
    await for (final entity in _cacheRoot.list(recursive: true, followLinks: false)) {
      if (entity is File && !entity.path.endsWith('.part')) {
        total += await entity.length();
      }
    }
    return total;
  }

  @override
  Future<AudioStorageStats> audioStorageStats() async {
    if (!_initialized || !await _cacheRoot.exists()) {
      return const AudioStorageStats(fileCount: 0, bytes: 0, byReciter: []);
    }
    final result = <AudioStorageReciterStats>[];
    var totalFiles = 0;
    var totalBytes = 0;
    for (final reciter in QuranReciter.available) {
      final directory = Directory('${_cacheRoot.path}/${reciter.id}');
      if (!await directory.exists()) continue;
      var fileCount = 0;
      var bytes = 0;
      final surahStats = <int, AudioStoredSurahStats>{};
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is! File || entity.path.endsWith('.part')) continue;
        final name = entity.uri.pathSegments.last;
        final match = RegExp(r'^(\d{3})(\d{3})\.mp3$').firstMatch(name);
        if (match == null) continue;
        final size = await entity.length();
        if (size <= 0) continue;
        final surahNumber = int.parse(match.group(1)!);
        final existing = surahStats[surahNumber];
        surahStats[surahNumber] = AudioStoredSurahStats(
          surahNumber: surahNumber,
          fileCount: (existing?.fileCount ?? 0) + 1,
          bytes: (existing?.bytes ?? 0) + size,
        );
        fileCount++;
        bytes += size;
      }
      if (fileCount == 0) continue;
      totalFiles += fileCount;
      totalBytes += bytes;
      final surahs = surahStats.values.toList()..sort((a, b) => a.surahNumber.compareTo(b.surahNumber));
      result.add(AudioStorageReciterStats(reciterId: reciter.id, reciterName: reciter.name, fileCount: fileCount, bytes: bytes, surahs: surahs));
    }
    result.sort((a, b) => b.bytes.compareTo(a.bytes));
    return AudioStorageStats(fileCount: totalFiles, bytes: totalBytes, byReciter: result);
  }

  @override
Future<void> deleteSurahAudio(String reciterId, int surahNumber) async {
  await stop();

  if (!_initialized) return;

  final directory = Directory('${_cacheRoot.path}/$reciterId');

  if (!await directory.exists()) return;

  final surahPrefix = surahNumber.toString().padLeft(3, '0');

  await for (final entity in directory.list(followLinks: false)) {
    if (entity is! File) continue;

    final name = entity.uri.pathSegments.last;

    if (name.startsWith(surahPrefix) &&
        name.length == 10 &&
        name.endsWith('.mp3')) {
      await entity.delete();
    }
  }
}

  @override

  Future<void> clearAudioCache() async {
    await stop();
    if (!_initialized || !await _cacheRoot.exists()) return;
    await for (final entity in _cacheRoot.list(followLinks: false)) {
      if (entity is Directory) {
        await entity.delete(recursive: true);
      } else if (entity is File) {
        await entity.delete();
      }
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed || _isDisposing) return;
    _isDisposing = true;
    await _operationQueue.catchError((_) {});
    _isDisposed = true;
    await _subscription.cancel();
    await _sequenceSubscription.cancel();
    await _statusController.close();
    await _downloadController.close();
    await _activeAyahController.close();
    _client.close();
    await _player.dispose();
  }
}
