part of '../index.dart';

class MusSlice extends StateNotifier<MusicState> {
  MusSlice() : super(MusicState()) {
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
      // 如果当前歌曲存在，就尝试刷新歌词
      final cur = _audioHandler.musPlaySlice.curMedia;
      if (cur != null) {
        _upLrc(cur);
      }
    });
  }

  final _audioHandler = AudioHandlerService.instance.handler;
  final Http _http = Http();
  LrcParser? lrc;
  double _lastLyricUpdate = -1; // 上次更新时间（秒）

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _bufSub;
  ProviderSubscription<MusPlayState>? _musPlayListen;

  List<Map<String,dynamic>> get lines {
    if(lrc==null) {
      return [];
    } else {
      return lrc!.lines;
    }
  }
  // === 供 position 流驱动 ===
  void updatePosition(Duration pos) {
    // print("pos ${pos.inMilliseconds}");
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
  Future<void> _upLrc(MediaItem? cur) async {
    _resetLrcTick();
    if (cur == null) {
      lrc = null;
      return;
    }
    final res = await _http.get<Map<String, dynamic>>(ExploreU.lycdetail,
        queryParameters: {"musId": cur.id});
    if (res.data != null) {
      final lyr =
          LyricEntity.fromJson(res.data!["data"]); // 你现有的歌词 Map：id -> lrc 文本
      final lyricData=lyr.lyric?.lyric ?? "";
      lrc = LrcParser.from(lyricData);
      state = state.copyWith(lyric: lyricData);
    } else {
      lrc = null;
    }
  }

  void _resetLrcTick() {
    _lastLyricUpdate = -1;
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _bufSub?.cancel();
    _musPlayListen?.close();
    super.dispose();
  }
}
