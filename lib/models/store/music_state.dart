import 'package:audio_service/audio_service.dart';

class MusicState {
  final Duration position;
  final Duration bufferedPosition;

  MusicState({
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
  });

  MusicState copyWith({
    Duration? position,
    Duration? bufferedPosition,
  }) {
    return MusicState(
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
    );
  }
}