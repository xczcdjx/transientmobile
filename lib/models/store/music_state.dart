class MusicState {
  final Duration position;
  final Duration bufferedPosition;
  String lyric;

  MusicState({
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.lyric=""
  });

  MusicState copyWith({
    Duration? position,
    Duration? bufferedPosition,
    String? lyric
  }) {
    return MusicState(
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      lyric: lyric ?? this.lyric,
    );
  }
}