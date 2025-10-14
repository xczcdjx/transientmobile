class MusicState {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  const MusicState({
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.duration = Duration.zero,
  });

  MusicState copyWith({
    Duration? position,
    Duration? bufferedPosition,
    Duration? duration,
  }) {
    return MusicState(
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      duration: duration ?? this.duration,
    );
  }
}