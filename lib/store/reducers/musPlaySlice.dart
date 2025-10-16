part of '../index.dart';


class MusPlaySlice extends StateNotifier<MusPlayState> {
  final AudioPlayerHandlerImpl handler;
  StreamSubscription<List<MediaItem>>? _qSub;
  StreamSubscription<QueueState>? _qsSub;
  StreamSubscription<MediaItem?>? _mSub;
  StreamSubscription<PlayerState>? _psSub;
  MusPlaySlice(this.handler) : super(MusPlayState()){
    // 列表
    _qSub = handler.queue.listen((q) {
      state = state.copyWith(playList: q);
    });

    // 索引 + 播放模式
    _qsSub = handler.queueState.listen((qs) {
      state = state.copyWith(
        curIndex: qs.queueIndex ?? 0,
        mode: qs.repeatMode,
      );
    });
    // 播放状态（playing、processing、缓冲/当前位置）
    _psSub = handler.playerState.listen((s){
      state=state.copyWith(playState: s);
    });

  }
  @override
  void dispose() {
    _qSub?.cancel();
    _qsSub?.cancel();
    _mSub?.cancel();
    _psSub?.cancel();
    super.dispose();
  }
}

