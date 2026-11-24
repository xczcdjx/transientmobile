class MusicState {
  final Duration position;
  final Duration bufferedPosition;
  final String lyric;
  final bool isBuffering;

  MusicState(
      {this.position = Duration.zero,
      this.bufferedPosition = Duration.zero,
      this.lyric = "",
      this.isBuffering = false});

  MusicState copyWith(
      {Duration? position,
      Duration? bufferedPosition,
      String? lyric,
      bool? isBuffering}) {
    return MusicState(
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      lyric: lyric ?? this.lyric,
      isBuffering: isBuffering ?? this.isBuffering,
    );
  }
}
