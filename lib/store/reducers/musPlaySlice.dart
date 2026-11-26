part of '../index.dart';

class MusPlaySlice extends StateNotifier<MusPlayState> {
  final AudioPlayerHandlerImpl handler;
  late final VoidCallback _removeStorageListener;
  StreamSubscription<PlaybackState>? _pbSub;
  StreamSubscription<Duration>? _positionSub;
  Duration _savedPosition = Duration.zero;
  bool _restoring = true;

  Future<void> restorePlayback() async {
    try {
      await handler.setMediaItemOnly(state.curSong, position: _savedPosition);
    } finally {
      _restoring = false;
    }
  }

  Future<void> savePlayback() => PlaybackStorage.save(state, _savedPosition);

  MusPlaySlice(this.handler) : super(MusPlayState()) {
    final (savedState, position) = PlaybackStorage.read();
    state = savedState;
    _savedPosition = position;
    var previousState = state;
    _removeStorageListener = addListener((next) {
      final changed = !identical(previousState.playList, next.playList) ||
          previousState.curIndex != next.curIndex ||
          previousState.repeatMode != next.repeatMode ||
          previousState.isShuffling != next.isShuffling ||
          !identical(previousState.randomIdList, next.randomIdList) ||
          previousState.isPlaying != next.isPlaying;
      if (previousState.curSong?.id != next.curSong?.id) {
        _savedPosition = Duration.zero;
      }
      previousState = next;
      if (changed && !_restoring) unawaited(savePlayback());
    }, fireImmediately: false);
    _positionSub = handler.positionStream.listen((position) {
      if (_restoring || handler.mediaItem.value?.id != state.curSong?.id) {
        return;
      }
      final previousSecond = _savedPosition.inSeconds;
      _savedPosition = position;
      if (position.inSeconds != previousSecond) unawaited(savePlayback());
    });
    // 监听底层播放状态，只同步 playing 标记
    _pbSub = handler.playbackState.listen((s) {
      if (state.isPlaying != s.playing) {
        state = state.copyWith(isPlaying: s.playing);
      }
    });
    // 初始化歌单列表
/*    state = state.copyWith(playList: mediaItemsFromJson(musTest));
    handler.setMediaItemOnly(state.curSong!);*/
    //
    handler.onCompleted = (_) async {
      if (state.playList.isEmpty) return;
      if (state.repeatMode == AudioServiceRepeatMode.one) {
        await _playCurrent();
      } else if (state.repeatMode == AudioServiceRepeatMode.none &&
          ((!state.isShuffling &&
                  state.curIndex == state.playList.length - 1) ||
              (state.isShuffling &&
                  state.curSong?.id == state.randomIdList.lastOrNull))) {
        await stop();
      } else {
        await next();
      }
    };
    handler.onSkipTo = (forward) => forward ? next() : previous();
    handler.onRepeatMode = (mode) async => setRepeat(mode);
    handler.onShuffleMode =
        (mode) async => toggleShuffle(mode == AudioServiceShuffleMode.all);
  }

  MediaItem? get curMedia => state.curSong;
  // 增删改
  Future<void> addMusOne(MediaItem item) async {
    final list = [...state.playList];
    final index = list.indexWhere((entry) => entry.id == item.id);
    if (index == state.curIndex) {
      await playToggle();
    } else if (index >= 0) {
      await playAt(index);
    } else {
      final insertIndex = (state.curIndex + 1).clamp(0, list.length);
      list.insert(insertIndex, item);
      state = state.copyWith(playList: List.unmodifiable(list));
      _rebuildShuffleIfNeeded();
      await playAt(insertIndex);
    }
  }
  // ============== 列表管理 ==============

  /// 覆盖播放队列；可指定起始 index，并决定是否自动播放
  Future<void> setQueue(List<MediaItem> list,
      {int startIndex = 0, bool autoPlay = true}) async {
    if (list.isEmpty) {
      state = state.copyWith(
          playList: const [],
          curIndex: 0,
          isShuffling: false,
          randomIdList: const []);
      await handler.setMediaItemOnly(null);
      return;
    }
    final idx = startIndex.clamp(0, list.length - 1);
    state = state.copyWith(playList: List.unmodifiable(list), curIndex: idx);
    _rebuildShuffleIfNeeded();
    if (autoPlay) {
      await _playCurrent();
    } else {
      await handler.setMediaItemOnly(state.curSong);
    }
  }

  /// 追加到队尾
  void append(List<MediaItem> items) {
    final newList = [...state.playList, ...items];
    state = state.copyWith(playList: List.unmodifiable(newList));
    _rebuildShuffleIfNeeded();
  }

  /// 插入
  void insertAt(int index, MediaItem item) {
    final list = [...state.playList];
    final i = index.clamp(0, list.length);
    list.insert(i, item);
    final cur = state.curSong != null && i <= state.curIndex
        ? state.curIndex + 1
        : state.curIndex;
    state = state.copyWith(playList: List.unmodifiable(list), curIndex: cur);
    _rebuildShuffleIfNeeded();
  }

  /// 移动
  void move(int from, int to) {
    final list = [...state.playList];
    if (from < 0 || from >= list.length || to < 0 || to >= list.length) return;
    final item = list.removeAt(from);
    list.insert(to, item);

    // 当前曲目在移动中的索引修正
    var cur = state.curIndex;
    if (from == cur) {
      cur = to;
    } else if (from < cur && to >= cur) {
      cur -= 1;
    } else if (from > cur && to <= cur) {
      cur += 1;
    }

    state = state.copyWith(playList: List.unmodifiable(list), curIndex: cur);
    _rebuildShuffleIfNeeded();
  }

  /// 删除
  Future<void> removeAt(int index) async {
    final list = [...state.playList];
    if (index < 0 || index >= list.length) return;

    final removingCurrent = index == state.curIndex;
    list.removeAt(index);

    if (list.isEmpty) {
      state = state.copyWith(
          playList: const [],
          curIndex: 0,
          isShuffling: false,
          randomIdList: const []);
      await handler.setMediaItemOnly(null);
      return;
    }

    var cur = state.curIndex;
    if (removingCurrent) {
      // 删除当前：保持播放不间断，选“原位”的下一首，否则往前一首
      cur = (cur < list.length) ? cur : list.length - 1;
      state = state.copyWith(playList: List.unmodifiable(list), curIndex: cur);
      await _playCurrent();
    } else {
      // 删除的是前面的项，当前索引需要前移 1
      if (index < cur) cur -= 1;
      state = state.copyWith(playList: List.unmodifiable(list), curIndex: cur);
    }

    _rebuildShuffleIfNeeded();
  }

  // ============== 播放控制（对外 API，UI 只调这些） ==============

  Future<void> playToggle() async {
    if (state.isPlaying) {
      await handler.pause();
    } else {
      await handler.play();
    }
  }

  Future<void> play() => handler.play();

  Future<void> pause() => handler.pause();

  Future<void> stop() => handler.stop();

  Future<void> seek(Duration p) => handler.seek(p);

  /// 播放指定索引
  Future<void> playAt(int index) async {
    if (state.playList.isEmpty) return;
    final i = index.clamp(0, state.playList.length - 1);
    state = state.copyWith(curIndex: i);
    await _playCurrent();
  }

  /// 下一首
  Future<void> next() async {
    if (state.playList.isEmpty) return;

    final nextIndex = _calcNextIndex(forward: true);

    state = state.copyWith(curIndex: nextIndex);
    await _playCurrent();
  }

  /// 上一首
  Future<void> previous() async {
    if (state.playList.isEmpty) return;

    final prevIndex = _calcNextIndex(forward: false);
    state = state.copyWith(curIndex: prevIndex);
    await _playCurrent();
  }

  /// 设置循环模式（none/one/all）
  void setRepeat(AudioServiceRepeatMode mode) {
    state = state.copyWith(repeatMode: mode);
    // 仅状态存上层；底层 handler 不再管理 repeat
  }

// 切换随机播放（洗牌）：使用 MediaItem.id
  void toggleShuffle([bool? enable]) {
    final willEnable = enable ?? !state.isShuffling;
    if (state.playList.isEmpty) return;
    if (!willEnable) {
      state =
          state.copyWith(isShuffling: false, randomIdList: const <String>[]);
    } else {
      // 以 id 构建并打乱
      final ids = state.playList.map((m) => m.id).toList()..shuffle();
      // 确保当前曲目的 id 在第 1 位（保持“当前位置”）
      final curId = state.playList[state.curIndex].id;
      ids.remove(curId);
      ids.insert(0, curId);
      state = state.copyWith(isShuffling: true, randomIdList: ids);
    }
  }

  int? _calcNextIndex({required bool forward}) {
    final n = state.playList.length;
    final cur = state.curIndex;
    if (n == 0) return null;

    // 随机播放：randomIdList 是 id 的队列
    if (state.isShuffling && state.randomIdList.isNotEmpty) {
      final curId = state.playList[cur].id;
      final pos = state.randomIdList.indexOf(curId);
      final nextPos = forward ? pos + 1 : pos - 1;

      int wrappedPos = nextPos;
      if (nextPos >= state.randomIdList.length) {
        wrappedPos = 0; // 超出上限 -> 回到第一个
      } else if (nextPos < 0) {
        wrappedPos = state.randomIdList.length - 1; // 小于 0 -> 回到最后一个
      }

      final nextId = state.randomIdList[wrappedPos];
      final idx = state.playList.indexWhere((m) => m.id == nextId);
      return idx >= 0 ? idx : null;
    }

    // 普通顺序
    int next = forward ? cur + 1 : cur - 1;

    if (next >= n) {
      next = 0; // 超过最大 -> 回到 0
    } else if (next < 0) {
      next = n - 1; // 小于 0 -> 回到最后
    }

    return next;
  }

  Future<void> _playCurrent() async {
    final item = state.playList.elementAtOrNull(state.curIndex);
    if (item == null) return;

    // 将最终要播的 MediaItem 交给底层
    await handler.playMediaItem(item);
  }

// 根据当前队列重建随机 id 队列（保持当前曲目 id 在首位）
  void _rebuildShuffleIfNeeded() {
    if (!state.isShuffling || state.playList.isEmpty) return;
    final curId = state.playList[state.curIndex].id;

    final ids = state.playList.map((m) => m.id).toList()..shuffle();
    ids.remove(curId);
    ids.insert(0, curId);

    state = state.copyWith(randomIdList: ids);
  }

  @override
  void dispose() {
    _removeStorageListener();
    _positionSub?.cancel();
    _pbSub?.cancel();
    handler.onCompleted = null;
    handler.onSkipTo = null;
    handler.onRepeatMode = null;
    handler.onShuffleMode = null;
    super.dispose();
  }
}
