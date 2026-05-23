abstract class AudioState {
  final String? reciterName;
  const AudioState({this.reciterName});
}

class AudioInitial extends AudioState {
  const AudioInitial({super.reciterName});
}

class AudioPlaying extends AudioState {
  final int? currentAyah;
  const AudioPlaying({this.currentAyah, super.reciterName});
}

class AudioPaused extends AudioState {

  final int? currentAyah;

  final String reciterName;

  AudioPaused({
    this.currentAyah,
    required this.reciterName,
  });

}

class AudioStopped extends AudioState {
  const AudioStopped({super.reciterName});
}