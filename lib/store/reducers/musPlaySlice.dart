part of '../index.dart';


class MusPlaySlice extends StateNotifier<MusPlayState> {
  final AudioPlayerHandlerImpl handler;
  StreamSubscription<List<MediaItem>>? _qSub;
  StreamSubscription<QueueState>? _qsSub;
  // StreamSubscription<PlayerState>? _psSub;
  StreamSubscription<PlaybackState>? _psSub;
  MusPlaySlice(this.handler) : super(MusPlayState()){
  /*  // 列表
    _qSub = handler.queue.listen((q) {
      state = state.copyWith(playList: q);
    });*/

    // 索引 + 播放模式
    _qsSub = handler.queueState.listen((qs) {
      state = state.copyWith(
        curIndex: qs.queueIndex ?? 0,
        mode: qs.repeatMode,
      );
    });
    // 播放状态 playing
    _psSub = handler.playbackState.listen((qs) {
      state = state.copyWith(
        isPlay: qs.playing,
      );
    });
    // 播放状态（playState）
    /*_psSub = handler.playerState.listen((s){
      state=state.copyWith(playState: s);
    });*/

  }

  // 控制方法（你也可以完全不放，直接从 UI 调 handler）
  Future<void> play() => handler.play();
  Future<void> pause() => handler.pause();
  Future<void> stop() => handler.stop();
  Future<void> seek(Duration p) => handler.seek(p);
  Future<void> skipNext() => handler.skipToNext();
  Future<void> skipPrev() => handler.skipToPrevious();
  Future<void> skipTo(int index) => handler.skipToQueueItem(index);
  Future<void> setRepeat(AudioServiceRepeatMode m) => handler.setRepeatMode(m);

  @override
  void dispose() {
    _qSub?.cancel();
    _qsSub?.cancel();
    _psSub?.cancel();
    super.dispose();
  }
}

