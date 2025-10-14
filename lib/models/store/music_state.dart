import 'package:audio_service/audio_service.dart';

class MusicState {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  MediaItem? curPlayMedia;

  MusicState({
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.duration = Duration.zero,
    this.curPlayMedia
  });

  MusicState copyWith({
    Duration? position,
    Duration? bufferedPosition,
    Duration? duration,
    MediaItem? curPlayMedia
  }) {
    return MusicState(
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      duration: duration ?? this.duration,
      curPlayMedia: curPlayMedia ?? this.curPlayMedia,
    );
  }
}