import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ayah_ref.dart';
import '../../domain/entities/quran_audio_preferences.dart';
import '../../domain/repositories/quran_audio_repository.dart';

class MushafAudioPanel extends StatelessWidget {
  const MushafAudioPanel({
    super.key,
    required this.ayah,
    required this.status,
    required this.downloadProgress,
    required this.downloadMode,
    required this.speed,
    required this.surahName,
    required this.reciterName,
    required this.onToggle,
    required this.onPrevious,
    required this.onNext,
    required this.onStop,
    required this.onDownloadModeTap,
    required this.onSpeedChanged,
    required this.onReciterTap,
  });

  final AyahRef? ayah;
  final AudioPlaybackStatus status;
  final AudioDownloadProgress downloadProgress;
  final AudioDownloadMode downloadMode;
  final double speed;
  final String surahName;
  final String reciterName;
  final VoidCallback onToggle;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onStop;
  final VoidCallback onDownloadModeTap;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onReciterTap;

  @override
  Widget build(BuildContext context) {
    final isPlaying = status == AudioPlaybackStatus.playing;
    final isLoading = status == AudioPlaybackStatus.loading;
    final isOffline = status == AudioPlaybackStatus.offline;
    final isFailure = status == AudioPlaybackStatus.failure;
    final isActive = ayah != null;
    final isDownloading = downloadProgress.isDownloading;
    final ayahLabel = isActive
        ? '$surahName • الآية ${ayah!.ayahNumber}'
        : 'اضغط تشغيل لبدء تلاوة الصفحة أو السورة المختارة';
    final statusLabel = isOffline
        ? 'لا يوجد إنترنت والملف غير محفوظ. اتصل بالإنترنت ثم أعد التشغيل.'
        : isFailure
            ? 'تعذر تشغيل التلاوة. تأكد من الاتصال ثم حاول مجدداً.'
            : isDownloading
                ? downloadProgress.text
                : ayahLabel;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xF1101727),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: isOffline
              ? const Color(0xFFE9A84E)
              : isDownloading
                  ? AppColors.emerald.withOpacity(.72)
                  : const Color(0xFF26374A),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x70000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          _SpeedButton(
            speed: speed,
            onPressed: () => onSpeedChanged(speed >= 1.5 ? .75 : speed + .25),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(children: [
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onReciterTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        reciterName,
                        style: const TextStyle(
                          color: AppColors.emeraldLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.emeraldLight,
                        size: 19,
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (isOffline) const Icon(Icons.wifi_off_rounded, size: 14, color: Color(0xFFE9A84E)),
                if (isDownloading) const Icon(Icons.downloading_rounded, size: 14, color: AppColors.emeraldLight),
                if (isOffline || isDownloading) const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    statusLabel,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isOffline
                          ? const Color(0xFFF2C26B)
                          : isFailure
                              ? const Color(0xFFE78686)
                              : AppColors.textMuted,
                      fontSize: 11,
                      height: 1.25,
                    ),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'إيقاف التلاوة',
            onPressed: isActive ? onStop : null,
            icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
          ),
        ]),
        if (isDownloading) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: downloadProgress.fraction,
              minHeight: 4,
              color: AppColors.emeraldLight,
              backgroundColor: const Color(0xFF273444),
            ),
          ),
        ],
        const SizedBox(height: 7),
        SizedBox(
          height: 56,
          child: Stack(children: [
            Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _AudioControl(
                  icon: Icons.skip_previous_rounded,
                  onPressed: isActive && !isLoading ? onPrevious : null,
                ),
                const SizedBox(width: 18),
                _PrimaryPlayButton(
                  isPlaying: isPlaying,
                  isLoading: isLoading,
                  isOffline: isOffline,
                  onPressed: isLoading ? null : onToggle,
                ),
                const SizedBox(width: 18),
                _AudioControl(
                  icon: Icons.skip_next_rounded,
                  onPressed: isActive && !isLoading ? onNext : null,
                ),
              ]),
            ),
            PositionedDirectional(
              end: 0,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: 48,
                child: Center(
                  child: Tooltip(
                    message: 'وضع تنزيل الصوت: ${downloadMode.title}',
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(9),
                        onTap: onDownloadModeTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          child: Icon(
                            Icons.download_for_offline_rounded,
                            size: 21,
                            color: downloadMode == AudioDownloadMode.smart
                                ? AppColors.emeraldLight
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _PrimaryPlayButton extends StatelessWidget {
  const _PrimaryPlayButton({
    required this.isPlaying,
    required this.isLoading,
    required this.isOffline,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool isLoading;
  final bool isOffline;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isLoading
          ? 'جارٍ تنزيل التلاوة'
          : isPlaying
              ? 'إيقاف مؤقت'
              : isOffline
                  ? 'إعادة محاولة الاتصال والتنزيل'
                  : 'تشغيل التلاوة',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: Ink(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isLoading
                  ? const [Color(0xFF3B7166), Color(0xFF285A51)]
                  : const [AppColors.emeraldLight, AppColors.emerald],
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.8,
                        color: AppColors.background,
                      ),
                    )
                  : Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: AppColors.background,
                      size: 31,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.speed, required this.onPressed});
  final double speed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0A352F),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          child: Text(
            '${speed.toStringAsFixed(2)}x',
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: AppColors.emeraldLight,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _AudioControl extends StatelessWidget {
  const _AudioControl({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: 30,
      color: AppColors.textPrimary,
      disabledColor: const Color(0xFF48515E),
      icon: Icon(icon),
    );
  }
}
