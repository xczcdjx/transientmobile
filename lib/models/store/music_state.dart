import 'package:audio_service/audio_service.dart';

class MusicState {
  final Duration position;
  final Duration bufferedPosition;
  List<Map<String,dynamic>> lyric;

  MusicState({
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.lyric=const []
  });

  MusicState copyWith({
    Duration? position,
    Duration? bufferedPosition,
    List<Map<String,dynamic>>? lyric
  }) {
    return MusicState(
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      lyric: lyric ?? this.lyric,
    );
  }
}