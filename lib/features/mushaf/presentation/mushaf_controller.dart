import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/entities/advanced_recitation_mode.dart';
import '../domain/entities/advanced_recitation_repeat.dart';
import '../domain/entities/ayah_ref.dart';
import '../domain/entities/reading_position.dart';
import '../domain/entities/quran_audio_preferences.dart';
import '../domain/entities/quran_verse_search_result.dart';
import '../domain/entities/surah_summary.dart';
import '../domain/repositories/mushaf_repository.dart';
import '../domain/repositories/quran_audio_repository.dart';
import '../domain/repositories/reading_position_repository.dart';

class MushafController extends ChangeNotifier {
  MushafController({
    required MushafRepository mushafRepository,
    required QuranAudioRepository audioRepository,
    required ReadingPositionRepository positionRepository,
  })  : _mushafRepository = mushafRepository,
        _audioRepository = audioRepository,
        _positionRepository = positionRepository {
    _audioSubscription = _audioRepository.status.listen(_onAudioStatus);
    _downloadSubscription = _audioRepository.downloadUpdates.listen((_) => notifyListeners());
    _activeAyahSubscription = _audioRepository.activeAyahChanges.listen(_onActiveAyahChanged);
  }

  final MushafRepository _mushafRepository;
  final QuranAudioRepository _audioRepository;
  final ReadingPositionRepository _positionRepository;
  late final StreamSubscription<AudioPlaybackStatus> _audioSubscription;
  late final StreamSubscription<AudioDownloadProgress> _downloadSubscription;
  late final StreamSubscription<AyahRef> _activeAyahSubscription;

  int _currentPage = 1;
  int? _pageCommand;
  AyahRef? _selectedAyah;
  AyahRef? _activePlaybackAyah;
  ReadingPosition? _bookmark;
  ReadingPosition? _lastPosition;
  bool _isFollowingActivePlayback = true;
  // يظل هذا المرجع بلا تمييز بصري إلى أن يضغط المستخدم تشغيل.
  // الغرض منه تمييز السورة المختارة عن السور الأخرى في الصفحة نفسها.
  AyahRef? _pendingSurahStart;
  AyahRef? _advancedStopAt;
  AyahRef? _advancedStartAt;
  AdvancedRecitationMode? _advancedMode;
  AdvancedRecitationRepeat _advancedRepeat = AdvancedRecitationRepeat.none;
  int _advancedRepeatRemaining = 0;
  AudioPlaybackStatus _audioStatus = AudioPlaybackStatus.idle;
  double _speed = 1;
  bool _repeatAyah = false;
  bool _repeatSurah = false;
  bool _isHandlingCompletion = false;
  bool _awaitingPlaybackConfirmation = false;
  int _playGeneration = 0;
  int _lastCompletedGeneration = -1;

  int get currentPage => _currentPage;
  int? get pageCommand => _pageCommand;
  AyahRef? get selectedAyah => _selectedAyah;
  AyahRef? get activePlaybackAyah => _activePlaybackAyah;
  ReadingPosition? get bookmark => _bookmark;
  ReadingPosition? get lastPosition => _lastPosition;
  bool get hasBookmark => _bookmark != null;
  bool get isCurrentPageBookmarked => _bookmark?.pageNumber == _currentPage;
  bool get hasActivePlaybackAyah => _activePlaybackAyah != null;
  String get playbackSurahName => _mushafRepository.arabicSurahName(
        (_activePlaybackAyah ?? _selectedAyah ?? _mushafRepository.firstAyahOnPage(_currentPage))
            .surahNumber,
      );
  AudioPlaybackStatus get audioStatus => _audioStatus;
  double get speed => _speed;
  bool get repeatAyah => _repeatAyah;
  bool get repeatSurah => _repeatSurah;
  AdvancedRecitationMode? get advancedMode => _advancedMode;
  AyahRef? get advancedStopAt => _advancedStopAt;
  AdvancedRecitationRepeat get advancedRepeat => _advancedRepeat;
  int get advancedRepeatRemaining => _advancedRepeatRemaining;
  bool get isPlaying => _audioStatus == AudioPlaybackStatus.playing;
  QuranReciter get reciter => _audioRepository.reciter;
  List<QuranReciter> get reciters => _audioRepository.reciters;
  AudioDownloadMode get downloadMode => _audioRepository.downloadMode;
  AudioDownloadProgress get downloadProgress => _audioRepository.downloadProgress;
  List<SurahSummary> get surahs => _mushafRepository.getAllSurahs();
  List<QuranVerseSearchResult> searchVerses(String query) =>
      _mushafRepository.searchVerses(query);
  int ayahCountForSurah(int surahNumber) => _mushafRepository.ayahCountForSurah(surahNumber);
  int juzForAyah(AyahRef ayah) => _mushafRepository.juzForAyah(ayah);
  String verseText(AyahRef ayah) => _mushafRepository.verseText(ayah);

  /// نص جاهز للمشاركة من دون ربط طبقة العرض بمصدر بيانات المصحف مباشرة.
  String shareTextForAyah(AyahRef ayah) {
    // نص الحزمة قد يحمل فواصل أسطر من تخطيط صفحة المصحف؛ لا نمررها
    // إلى المشاركة كي تلتف الآية طبيعياً حسب التطبيق الذي يستقبلها.
    final verse = _mushafRepository
        .verseText(ayah)
        .replaceAll(RegExp(r'[\n\r\u2028\u2029]+'), ' ')
        .replaceAll(RegExp(r'[\u00A0\s]+'), ' ')
        .trim();
    final surahName = _mushafRepository.arabicSurahName(ayah.surahNumber);
    return '$verse\n\nسورة $surahName — الآية ${ayah.ayahNumber}\nالصفحة ${ayah.pageNumber}\n\nمشاركة من تطبيق قلم';
  }
  String get currentSurahName => _mushafRepository.arabicSurahName(
        (_selectedAyah ?? _pendingSurahStart ??
                _mushafRepository.firstAyahOnPage(_currentPage))
            .surahNumber,
      );
  int get currentJuz => _mushafRepository.juzForAyah(
        _selectedAyah ??
            _pendingSurahStart ??
            _mushafRepository.firstAyahOnPage(_currentPage),
      );

  Future<void> initialize() async {
    final position = await _positionRepository.getLastPosition();
    _lastPosition = position;
    _bookmark = await _positionRepository.getBookmark();
    if (position != null) {
      _currentPage = position.pageNumber;
      // آخر موضع للقراءة لا يعني أن الآية مختارة.
      _selectedAyah = null;
      _pageCommand = position.pageNumber;
    }
    notifyListeners();
  }

  Future<void> onPageChanged(int pageNumber) async {
    // تتبع الصفحة الآية النشطة فقط عندما يكون موضع الصوت هو المعروض فعلاً.
    // بذلك السحب إلى صفحة أخرى يفتح الاستعراض الحر، والعودة يدوياً للآية
    // النشطة تعيد المتابعة الطبيعية من دون الحاجة إلى زر إضافي.
    final activeAyah = _activePlaybackAyah;
    _isFollowingActivePlayback =
        activeAyah == null || pageNumber == activeAyah.pageNumber;
    if (activeAyah != null && pageNumber == activeAyah.pageNumber) {
      _selectedAyah = activeAyah;
    }
    _currentPage = pageNumber;
    _pageCommand = null;
    // نحافظ على بداية السورة المختارة إذا كانت ضمن هذه الصفحة فقط.
    final pendingOnThisPage = _pendingSurahStart?.pageNumber == pageNumber
        ? _pendingSurahStart
        : null;
    if (pendingOnThisPage == null) _pendingSurahStart = null;
    // لا نحتفظ بتحديد آية من صفحة أخرى بعد التنقل اليدوي.
    if (_selectedAyah?.pageNumber != pageNumber ||
        _audioStatus == AudioPlaybackStatus.idle) {
      _selectedAyah = null;
    }
    final anchor = pendingOnThisPage ?? _mushafRepository.firstAyahOnPage(pageNumber);
    await _savePosition(anchor);
    notifyListeners();
  }

  /// ينتقل إلى نتيجة البحث بصرياً مع استمرار التلاوة الحالية في الخلفية.
  Future<void> selectAyahFromSearch(int surahNumber, int ayahNumber) async {
    final page = _mushafRepository.pageForAyah(surahNumber, ayahNumber);
    _selectedAyah = AyahRef(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      pageNumber: page,
    );
    _pendingSurahStart = null;
    _isFollowingActivePlayback = false;
    if (page != _currentPage) {
      _currentPage = page;
      _pageCommand = page;
    }
    await _savePosition(_selectedAyah!);
    notifyListeners();
  }

  Future<void> followActivePlaybackAyah() async {
    final activeAyah = _activePlaybackAyah;
    if (activeAyah == null) return;
    _isFollowingActivePlayback = true;
    _selectedAyah = activeAyah;
    _pendingSurahStart = null;
    if (activeAyah.pageNumber != _currentPage) {
      _currentPage = activeAyah.pageNumber;
      _pageCommand = activeAyah.pageNumber;
    }
    await _savePosition(activeAyah);
    notifyListeners();
  }

  /// يحفظ مرجعية صريحة في الصفحة الحالية، أو يستبدل المرجعية السابقة.
  Future<void> saveBookmark() async {
    final active = _activePlaybackAyah;
    if (active != null && active.pageNumber == _currentPage) {
      await saveBookmarkForAyah(active);
      return;
    }
    final selected = _selectedAyah;
    if (selected != null && selected.pageNumber == _currentPage) {
      await saveBookmarkForAyah(selected);
      return;
    }
    await saveBookmarkForAyah(_mushafRepository.firstAyahOnPage(_currentPage));
  }

  /// يحفظ مرجعية للآية التي اختارها المستخدم من قائمة إجراءات الآية.
  Future<void> saveBookmarkForAyah(AyahRef ayah) async {
    final bookmark = ReadingPosition(
      pageNumber: ayah.pageNumber,
      anchorAyah: ayah,
      updatedAt: DateTime.now(),
    );
    await _positionRepository.saveBookmark(bookmark);
    _bookmark = bookmark;
    notifyListeners();
  }

  /// يحذف المرجعية المحفوظة من دون التأثير في آخر موضع قراءة تلقائي.
  Future<void> clearBookmark() async {
    await _positionRepository.clearBookmark();
    _bookmark = null;
    notifyListeners();
  }

  /// يفتح المرجعية مع الحفاظ على استمرار التلاوة في الخلفية عند وجودها.
  Future<void> goToBookmark() async {
    final bookmark = _bookmark;
    if (bookmark == null) return;
    final active = _activePlaybackAyah;
    _isFollowingActivePlayback =
        active == null || active.pageNumber == bookmark.pageNumber;
    _currentPage = bookmark.pageNumber;
    _pageCommand = bookmark.pageNumber;
    _selectedAyah = bookmark.anchorAyah;
    _pendingSurahStart = null;
    await _savePosition(bookmark.anchorAyah ??
        _mushafRepository.firstAyahOnPage(bookmark.pageNumber));
    notifyListeners();
  }

  Future<void> selectAyah(int surahNumber, int ayahNumber) async {
    final page = _mushafRepository.pageForAyah(surahNumber, ayahNumber);
    _selectedAyah = AyahRef(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      pageNumber: page,
    );
    _pendingSurahStart = null;
    _clearAdvancedRecitation();
    if (page != _currentPage) {
      _currentPage = page;
      _pageCommand = page;
    }
    await _savePosition(_selectedAyah!);
    notifyListeners();
  }

  /// يزيل اختيار قائمة الضغط المطول إذا لم يتحول إلى تشغيل أو إجراء آخر.
  void clearTemporaryAyahSelection(AyahRef expectedAyah) {
    if (_audioStatus == AudioPlaybackStatus.playing) return;
    final selected = _selectedAyah;
    if (selected == null ||
        selected.surahNumber != expectedAyah.surahNumber ||
        selected.ayahNumber != expectedAyah.ayahNumber ||
        selected.pageNumber != expectedAyah.pageNumber) {
      return;
    }
    _selectedAyah = null;
    notifyListeners();
  }

  /// يفتح السورة عند أول صفحة لها، من دون اختيار آية تلقائياً.
  Future<void> openSurah(int surahNumber) async {
    final firstAyah = AyahRef(
      surahNumber: surahNumber,
      ayahNumber: 1,
      pageNumber: _mushafRepository.pageForAyah(surahNumber, 1),
    );
    _currentPage = firstAyah.pageNumber;
    _pageCommand = firstAyah.pageNumber;
    _selectedAyah = null;
    _pendingSurahStart = firstAyah;
    _clearAdvancedRecitation();
    await _savePosition(firstAyah);
    notifyListeners();
  }

  Future<void> goToPage(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > 604) return;
    // سحب شريط الصفحات يفتح وضع الاستعراض الحر إلا إذا عاد المستخدم بنفسه
    // إلى صفحة الآية النشطة؛ عندها تستأنف المتابعة تلقائياً.
    final activeAyah = _activePlaybackAyah;
    _isFollowingActivePlayback =
        activeAyah == null || pageNumber == activeAyah.pageNumber;
    if (activeAyah != null && pageNumber == activeAyah.pageNumber) {
      _selectedAyah = activeAyah;
    } else {
      // لا نرسم آية صوت من صفحة أخرى أثناء الاستعراض الحر.
      _selectedAyah = null;
    }
    _currentPage = pageNumber;
    _pageCommand = pageNumber;
    // الانتقال السريع للصفحات يلغي بداية السورة المحفوظة فقط.
    _pendingSurahStart = null;
    _clearAdvancedRecitation();
    await _savePosition(_mushafRepository.firstAyahOnPage(pageNumber));
    notifyListeners();
  }

  Future<void> togglePlayback() async {
    if (isPlaying) {
      await _audioRepository.pause();
      return;
    }
    // الاحتفاظ بخطة التلاوة المتقدمة عند استئناف الإيقاف المؤقت.
    await playSelectedOrPageStart(clearAdvanced: false);
  }

  /// يستخدم من زر التشغيل العام؛ قد يستأنف جلسة موقوفة مؤقتاً.
  Future<void> playSelectedOrPageStart({bool clearAdvanced = true}) async {
    if (clearAdvanced) _clearAdvancedRecitation();
    // السورة المفتوحة من القائمة لها أولوية على أول آية ظاهرة في الصفحة.
    final target = _selectedAyah ??
        _pendingSurahStart ??
        _mushafRepository.firstAyahOnPage(_currentPage);
    if (_selectedAyah == null) {
      _selectedAyah = target;
      _pendingSurahStart = null;
      notifyListeners();
    }
    await _play(target);
  }

  /// يستخدم من قائمة الضغط المطول؛ يقطع أي تلاوة قائمة ويبدأ من الآية المختارة.
  Future<void> playSelectedAyahNow() async {
    _clearAdvancedRecitation();
    final target = _selectedAyah ??
        _pendingSurahStart ??
        _mushafRepository.firstAyahOnPage(_currentPage);
    await _play(target, forceRestart: true);
  }

  /// نقطة توافق لاستدعاءات قديمة؛ تستخرج الآية الحالية ثم تمررها صراحة.
  Future<void> startAdvancedRecitation(
    AdvancedRecitationMode mode, {
    int? untilAyahNumber,
    AdvancedRecitationRepeat repeat = AdvancedRecitationRepeat.none,
    int repeatCount = 3,
  }) {
    final start = _selectedAyah ??
        _pendingSurahStart ??
        _mushafRepository.firstAyahOnPage(_currentPage);
    return startAdvancedRecitationFrom(
      start,
      mode,
      untilAyahNumber: untilAyahNumber,
      repeat: repeat,
      repeatCount: repeatCount,
    );
  }

  /// يبدأ من آية ثابتة جاءت من قائمة الضغط المطول، حتى لو تغيرت الآية النشطة بالخلفية.
  Future<void> startAdvancedRecitationFrom(
    AyahRef start,
    AdvancedRecitationMode mode, {
    int? untilAyahNumber,
    required AdvancedRecitationRepeat repeat,
    required int repeatCount,
  }) async {
    _advancedMode = mode;
    _advancedRepeat = repeat;
    _advancedRepeatRemaining =
        repeat == AdvancedRecitationRepeat.ayah || repeat == AdvancedRecitationRepeat.range
            ? repeatCount.clamp(1, 99).toInt()
            : 0;

    final surahStart = AyahRef(
      surahNumber: start.surahNumber,
      ayahNumber: 1,
      pageNumber: _mushafRepository.pageForAyah(start.surahNumber, 1),
    );
    final surahEnd = AyahRef(
      surahNumber: start.surahNumber,
      ayahNumber: _mushafRepository.ayahCountForSurah(start.surahNumber),
      pageNumber: _mushafRepository.pageForAyah(
        start.surahNumber,
        _mushafRepository.ayahCountForSurah(start.surahNumber),
      ),
    );
    final playbackStart = repeat == AdvancedRecitationRepeat.surah ? surahStart : start;
    _advancedStartAt = playbackStart;
    _advancedStopAt = switch (repeat) {
      AdvancedRecitationRepeat.ayah => start,
      AdvancedRecitationRepeat.surah => surahEnd,
      _ => switch (mode) {
          AdvancedRecitationMode.pageEnd => _lastAyahOnPage(start.pageNumber),
          AdvancedRecitationMode.surahEnd => surahEnd,
          AdvancedRecitationMode.continuous => null,
          AdvancedRecitationMode.untilAyah => AyahRef(
              surahNumber: start.surahNumber,
              ayahNumber: untilAyahNumber ?? start.ayahNumber,
              pageNumber: _mushafRepository.pageForAyah(
                start.surahNumber,
                untilAyahNumber ?? start.ayahNumber,
              ),
            ),
        },
    };
    await _play(playbackStart, forceRestart: true);
  }

  AyahRef _lastAyahOnPage(int pageNumber) {
    AyahRef? last;
    for (var surah = 1; surah <= 114; surah++) {
      final count = _mushafRepository.ayahCountForSurah(surah);
      for (var ayah = 1; ayah <= count; ayah++) {
        final page = _mushafRepository.pageForAyah(surah, ayah);
        if (page == pageNumber) {
          last = AyahRef(surahNumber: surah, ayahNumber: ayah, pageNumber: page);
        } else if (last != null && page > pageNumber) {
          return last;
        }
      }
    }
    return last ?? _mushafRepository.firstAyahOnPage(pageNumber);
  }

  Future<void> playNext({bool followPlayback = true}) async {
    final current = _activePlaybackAyah ??
        _selectedAyah ??
        _mushafRepository.firstAyahOnPage(_currentPage);
    final count = _mushafRepository.ayahCountForSurah(current.surahNumber);
    // لا توجد آية بعد الناس: نغلق الجلسة بهدوء بدلاً من تشغيل الأخيرة مجدداً.
    if (current.surahNumber == 114 && current.ayahNumber >= count) {
      await _finishQuranPlayback();
      return;
    }
    final next = current.ayahNumber < count
        ? AyahRef(
            surahNumber: current.surahNumber,
            ayahNumber: current.ayahNumber + 1,
            pageNumber: _mushafRepository.pageForAyah(current.surahNumber, current.ayahNumber + 1),
          )
        : current.surahNumber < 114
            ? AyahRef(
                surahNumber: current.surahNumber + 1,
                ayahNumber: 1,
                pageNumber: _mushafRepository.pageForAyah(current.surahNumber + 1, 1),
              )
            : current;
    await _play(next, followPlayback: followPlayback);
  }

  Future<void> _finishAdvancedRecitation() async {
    await _audioRepository.stop();
    _activePlaybackAyah = null;
    _audioStatus = AudioPlaybackStatus.idle;
    // انتهت الخطة؛ نزيل التحديد لتعود صفحة المصحف لوضع القراءة العادي.
    _selectedAyah = null;
    _clearAdvancedRecitation();
    notifyListeners();
  }

  void _clearAdvancedRecitation() {
    _advancedStopAt = null;
    _advancedStartAt = null;
    _advancedMode = null;
    _advancedRepeat = AdvancedRecitationRepeat.none;
    _advancedRepeatRemaining = 0;
  }

  Future<void> _finishQuranPlayback() async {
    await _audioRepository.stop();
    _activePlaybackAyah = null;
    // نحتفظ بمرجع آخر آية للعرض، لكن نجعل زر التشغيل في وضعه الطبيعي.
    _audioStatus = AudioPlaybackStatus.idle;
    notifyListeners();
  }

  Future<void> playPrevious() async {
    final current = _activePlaybackAyah ??
        _selectedAyah ??
        _mushafRepository.firstAyahOnPage(_currentPage);
    final previous = current.ayahNumber > 1
        ? AyahRef(
            surahNumber: current.surahNumber,
            ayahNumber: current.ayahNumber - 1,
            pageNumber: _mushafRepository.pageForAyah(current.surahNumber, current.ayahNumber - 1),
          )
        : current.surahNumber > 1
            ? AyahRef(
                surahNumber: current.surahNumber - 1,
                ayahNumber: _mushafRepository.ayahCountForSurah(current.surahNumber - 1),
                pageNumber: _mushafRepository.pageForAyah(current.surahNumber - 1, _mushafRepository.ayahCountForSurah(current.surahNumber - 1)),
              )
            : current;
    await _play(previous);
  }

  Future<void> stop() async {
    await _audioRepository.stop();
    _activePlaybackAyah = null;
    _selectedAyah = null;
    _clearAdvancedRecitation();
    notifyListeners();
  }

  Future<void> selectReciter(QuranReciter value) async {
    await _audioRepository.selectReciter(value);
    _selectedAyah = null;
    notifyListeners();
  }

  Future<int> cachedAudioBytes() => _audioRepository.cachedAudioBytes();

  Future<AudioStorageStats> audioStorageStats() => _audioRepository.audioStorageStats();

  Future<void> deleteSurahAudio(String reciterId, int surahNumber) => _audioRepository.deleteSurahAudio(reciterId, surahNumber);

  Future<void> clearAudioCache() => _audioRepository.clearAudioCache();

  Future<void> setDownloadMode(AudioDownloadMode mode) async {
    await _audioRepository.setDownloadMode(mode);
    notifyListeners();
  }

  Future<void> downloadCurrentSurah() async {
    final surah = _selectedAyah?.surahNumber ??
        _mushafRepository.firstAyahOnPage(_currentPage).surahNumber;
    await _audioRepository.downloadSurah(surah);
    notifyListeners();
  }

  Future<void> setSpeed(double value) async {
    _speed = value;
    await _audioRepository.setSpeed(value);
    notifyListeners();
  }

  void setRepeatAyah(bool value) {
    _repeatAyah = value;
    notifyListeners();
  }

  void setRepeatSurah(bool value) {
    _repeatSurah = value;
    notifyListeners();
  }

  Future<void> _play(
    AyahRef ayah, {
    bool forceRestart = false,
    bool followPlayback = true,
  }) async {
    // تمييز تشغيل جديد يمنع إشارة completed المتأخرة من احتساب الآية التالية.
    _isFollowingActivePlayback = followPlayback;
    _playGeneration++;
    _awaitingPlaybackConfirmation = true;
    _activePlaybackAyah = ayah;
    // لا يملك تشغيل الصوت الداخلي حق تغيير صفحة الاستعراض أو تمييزها.
    if (followPlayback) {
      _selectedAyah = ayah;
      if (ayah.pageNumber != _currentPage) {
        _currentPage = ayah.pageNumber;
        _pageCommand = ayah.pageNumber;
      }
      await _savePosition(ayah);
    }
    notifyListeners();
    await _audioRepository.play(
      ayah,
      speed: _speed,
      stopAt: _advancedStopAt,
      forceRestart: forceRestart,
    );
  }

  Future<void> _savePosition(AyahRef anchor) {
    final position = ReadingPosition(
      pageNumber: _currentPage,
      anchorAyah: anchor,
      updatedAt: DateTime.now(),
    );
    _lastPosition = position;
    notifyListeners();
    return _positionRepository.save(position);
  }

  void _onActiveAyahChanged(AyahRef ayah) {
    _activePlaybackAyah = ayah;
    if (!_isFollowingActivePlayback) {
      notifyListeners();
      return;
    }
    _selectedAyah = ayah;
    _pendingSurahStart = null;
    if (ayah.pageNumber != _currentPage) {
      _currentPage = ayah.pageNumber;
      _pageCommand = ayah.pageNumber;
    }
    unawaited(_savePosition(ayah));
    notifyListeners();
  }

  void _onAudioStatus(AudioPlaybackStatus status) {
    _audioStatus = status;
    if (status == AudioPlaybackStatus.playing) {
      _awaitingPlaybackConfirmation = false;
    }
    notifyListeners();
    if (status != AudioPlaybackStatus.completed) return;

    final completedAyah = _activePlaybackAyah ?? _selectedAyah;
    // الإشارة المتأخرة أثناء تجهيز آية جديدة تخص المقطع السابق، فتُهمل.
    if (completedAyah == null ||
        _awaitingPlaybackConfirmation ||
        _isHandlingCompletion ||
        _lastCompletedGeneration == _playGeneration) {
      return;
    }
    _isHandlingCompletion = true;
    _lastCompletedGeneration = _playGeneration;
    unawaited(_advanceAfterCompletionSafely(completedAyah));
  }

  Future<void> _advanceAfterCompletionSafely(AyahRef completedAyah) async {
    // نلتقط الحالة عند اكتمال الآية: المتابعة مستمرة تلقائياً فقط ما لم
    // يكن المستخدم قد غادر موضع التلاوة بالبحث أو بسحب شريط الصفحات.
    final followPlayback = _isFollowingActivePlayback;
    try {
      // نتجاهل أي إشارة نهاية قديمة وصلت بعد انتقال المستخدم إلى آية أخرى.
      if (_activePlaybackAyah != completedAyah) return;
      if (_advancedStopAt == completedAyah) {
        final repeatStart = _advancedStartAt;
        final hasCountedRepeat =
            (_advancedRepeat == AdvancedRecitationRepeat.ayah ||
                _advancedRepeat == AdvancedRecitationRepeat.range) &&
            _advancedRepeatRemaining > 0;
        if (hasCountedRepeat && repeatStart != null) {
          _advancedRepeatRemaining--;
          await _play(
            repeatStart,
            forceRestart: true,
            followPlayback: followPlayback,
          );
          return;
        }
        if (_advancedRepeat == AdvancedRecitationRepeat.surah &&
            repeatStart != null) {
          await _play(
            repeatStart,
            forceRestart: true,
            followPlayback: followPlayback,
          );
          return;
        }
        await _finishAdvancedRecitation();
        return;
      }
      if (_repeatAyah) {
        await _play(completedAyah, followPlayback: followPlayback);
        return;
      }
      if (_repeatSurah &&
          completedAyah.ayahNumber ==
              _mushafRepository.ayahCountForSurah(completedAyah.surahNumber)) {
        await _play(
          AyahRef(
            surahNumber: completedAyah.surahNumber,
            ayahNumber: 1,
            pageNumber: _mushafRepository.pageForAyah(completedAyah.surahNumber, 1),
          ),
          followPlayback: followPlayback,
        );
        return;
      }
      await playNext(followPlayback: followPlayback);
    } catch (_) {
      _audioStatus = AudioPlaybackStatus.failure;
      notifyListeners();
    } finally {
      _isHandlingCompletion = false;
    }
  }

  @override
  void dispose() {
    _audioSubscription.cancel();
    _downloadSubscription.cancel();
    _activeAyahSubscription.cancel();
    _audioRepository.dispose();
    super.dispose();
  }
}
