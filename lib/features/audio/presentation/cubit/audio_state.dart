abstract class AudioState {
  final String? reciterName;
  const AudioState({this.reciterName});
}

class AudioInitial extends AudioState {
  const AudioInitial({super.reciterName});
}

class AudioLoading extends AudioState {
  const AudioLoading({super.reciterName});
}
class AudioPlaying extends AudioState {
  final int? currentAyah;
  const AudioPlaying({this.currentAyah, super.reciterName});
}

class AudioError extends AudioState {
  final String message;
  const AudioError({required this.message, required super.reciterName});
}

class AudioPaused extends AudioState {
  final int? currentAyah;

  AudioPaused({this.currentAyah, required super.reciterName});
}

class AudioStopped extends AudioState {
  const AudioStopped({super.reciterName});
}
