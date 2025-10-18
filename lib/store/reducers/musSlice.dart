part of '../index.dart';

class MusSlice extends StateNotifier<MusicState> {
  MusSlice(this.ref) : super(MusicState()) {
    // 1) 监听 handler.mediaItem：当前曲目变化时，更新 curPlayMedia & 重建歌词
    _mediaSub = _audioHandler.mediaItem.listen((mi) {
      if (mi == null) return;
      _upLrc(mi); // 换歌后重建歌词解析器
    });

    // 2) 监听 musPlayProvider：当上层切歌/改队列时，重建歌词解析器
    _musPlayListen = ref.listen<MusPlayState>(
      musPlayProvider,
          (prev, next) {
        if (prev == null) {
          // _upLrc(next.curSong); // 首次
          return;
        }
        final changedIndex = prev.curIndex != next.curIndex;
        final changedLen   = prev.playList.length != next.playList.length;
        // 也可加：标题/ID 变化等
        if (changedIndex || changedLen) {
          _upLrc(next.curSong);
        }
      },
    );

    // 3) 进度流：用你的 handler 的 position/duration/buffered 流
    //    你上面有 createPositionStream，可直接用：
    _posSub = _audioHandler.durationStream.listen(updatePosition);

    // 如果你也有 buffered 流，这里一并监听
    _bufSub = _audioHandler.playbackState
        .map((s) => s.bufferedPosition)
        .distinct()
        .listen((buf) {
      // print("buf $buf");
      updateBuffered(buf);
    });
  }

  final Ref ref;
  final _audioHandler = AudioHandlerService.instance.handler;

  LrcParser? lrc;
  double _lastLyricUpdate = -1; // 上次更新时间（秒）

  StreamSubscription<MediaItem?>? _mediaSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _bufSub;
  ProviderSubscription<MusPlayState>? _musPlayListen;

  // === 供 position 流驱动 ===
  void updatePosition(Duration pos) {
    state = state.copyWith(position: pos);

    // 节流：仅每0.5秒更新一次歌词行 -> 同步到通知栏（updateArtist）
    if (lrc == null) return;
    final sec = pos.inMilliseconds / 1000.0;
    if (sec - _lastLyricUpdate < 0.5) return;
    _lastLyricUpdate = sec;

    final line = lrc!.getByTime(sec);
    if (line != null) _audioHandler.updateArtist(line);
  }

  void updateBuffered(Duration buf) {
    state = state.copyWith(bufferedPosition: buf);
    // 缓冲变化时可以重置歌词节流，避免卡顿后不刷行
    _resetLrcTick();
  }

  // === 内部：重建歌词解析器 ===
  void _upLrc(MediaItem? cur) {
    _resetLrcTick();
    if (cur == null) {
      lrc = null;
      return;
    }
    final data = lyricDataTest[cur.id]; // 你现有的歌词 Map：id -> lrc 文本
    if (data != null) {
      lrc = LrcParser.from(data);
    } else {
      lrc = null;
    }
  }

  void _resetLrcTick() {
    _lastLyricUpdate = -1;
  }

  @override
  void dispose() {
    _mediaSub?.cancel();
    _posSub?.cancel();
    _bufSub?.cancel();
    _musPlayListen?.close();
    super.dispose();
  }
}
