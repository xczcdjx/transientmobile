// audio_player_handler_impl.dart
import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rxdart/rxdart.dart';

import '../store/index.dart';

class AudioPlayerHandlerImpl extends BaseAudioHandler
    with SeekHandler
    implements AudioHandler {
  final AudioPlayer _audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // 绑定musPlaySlice
  late MusPlaySlice musPlaySlice;

  // 外部（上层 Slice）可监听，播放完成触发
  Future<void> Function(PlayerState state)? onCompleted;
  Future<void> Function(bool isNext)? onSkipTo;
  Future<void> Function(AudioServiceRepeatMode mode)? onRepeatMode;

  // AudioPlayerHandlerImpl
  /*Stream<Duration> get positionStream =>
      _audioPlayer.onPositionChanged.distinct();*/

  // 公开：进度 / 音量 / 速度
  @override
  final BehaviorSubject<double> volume = BehaviorSubject.seeded(1.0);
  @override
  final BehaviorSubject<double> speed = BehaviorSubject.seeded(1.0);

  // 当前位置（可选）
  Duration currentPosition = Duration.zero;
  bool _isLoading = false;
  PlayerState state = PlayerState.disposed;
  Duration _duration = Duration.zero;

  // 初始化监听
  void bindMusPlaySlice(MusPlaySlice mus){
    musPlaySlice=mus;
  }

  AudioPlayerHandlerImpl() {
    _audioPlayer.onPlayerStateChanged.listen(
            (state) async {
      print('onPlayerStateChanged $state');
      this.state = state;
      if (state == PlayerState.completed) {
        await onCompleted?.call(state);
      } else if (state == PlayerState.playing) {
        _duration = await _audioPlayer.getDuration() as Duration;
        print(_duration.inMilliseconds.toString());
        playbackState.add(playbackState.value.copyWith(
            processingState: AudioProcessingState.ready,
            playing: true,
            controls: [
              MediaControl.skipToPrevious,
              MediaControl.pause,
              // MediaControl.stop,
              MediaControl.skipToNext,
            ],
            bufferedPosition: _duration,
            updatePosition: currentPosition));
        _isLoading = false;
      } else if (state == PlayerState.paused) {
        playbackState.add(playbackState.value.copyWith(
          processingState: AudioProcessingState.ready,
          bufferedPosition: _duration,
          updatePosition: currentPosition,
          playing: false,
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.play,
            // MediaControl.stop,
            MediaControl.skipToNext,
          ],
        ));
      }
    });
  }

  Stream<Duration> get durationStream => createPositionStream(
      steps: 800,
      minPeriod: const Duration(milliseconds: 16),
      maxPeriod: const Duration(milliseconds: 200));

  Stream<Duration> createPositionStream({
    int steps = 800,
    Duration minPeriod = const Duration(milliseconds: 200),
    Duration maxPeriod = const Duration(milliseconds: 200),
  }) {
    assert(minPeriod <= maxPeriod);
    assert(minPeriod > Duration.zero);
    Duration? last;
    late StreamController<Duration> controller;
    late StreamSubscription<MediaItem?> mediaItemSubscription;
    late StreamSubscription<PlaybackState> playbackStateSubscription;
    Timer? currentTimer;
    Duration duration() => mediaItem.value?.duration ?? Duration.zero;
    Duration step() {
      var s = duration() ~/ steps;
      if (s < minPeriod) s = minPeriod;
      if (s > maxPeriod) s = maxPeriod;
      return s;
    }

    void yieldPosition(Timer? timer) {
      _audioPlayer.getCurrentPosition().then((value) {
        currentPosition = value ?? Duration.zero;
        if (last != currentPosition && currentPosition.inMilliseconds != -1) {
          controller.add(last = currentPosition);
        }
      });
    }

    controller = StreamController.broadcast(
      sync: true,
      onListen: () {
        mediaItemSubscription = mediaItem.listen((MediaItem? mediaItem) {
          // Potentially a new duration
          currentTimer?.cancel();
          currentTimer = Timer.periodic(step(), yieldPosition);
        });
        playbackStateSubscription = playbackState.listen((PlaybackState state) {
          // Potentially a time discontinuity
          yieldPosition(currentTimer);
        });
      },
      onCancel: () {
        mediaItemSubscription.cancel();
        playbackStateSubscription.cancel();
      },
    );
    return controller.stream;
  }

  // ======== 仅保留“如何播放一个 MediaItem” ========
  /// 仅设置当前 mediaItem，不播放。
  /// 可用于：预载歌词 / 展示封面 / 准备播放队列中的下一首。
  Future<void> setMediaItemOnly(MediaItem? item) async {
    // 更新当前 mediaItem（通知系统与 UI）
    mediaItem.add(item);

    // 更新播放状态为 idle（非播放中）
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
      playing: false,
      updatePosition: Duration.zero,
      controls: const [
        MediaControl.play,
        MediaControl.stop,
      ],
    ));
  }


  /// 直接播放一个媒体；由上层决定哪一个是“当前曲目”
  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.ready,
      playing: true,
      controls: [
        MediaControl.pause,
        MediaControl.stop,
      ],
    ));
    this.mediaItem.add(mediaItem);
    await play();
  }

  /// 直接播放一个媒体；由上层决定哪一个是“当前曲目”
  Future<void> switchMediaItem() async {
    await _audioPlayer.stop();
    await play();
  }


  /// 通用播放控制：
  /// - 若暂停则 resume
  /// - 若无当前媒体但有历史队列，则重播当前曲目
  /// - 若完全无媒体，则不做事
  @override
  Future<void> play() async {
    final mi=musPlaySlice.curMedia;
    print("url ${mi?.extras?["musUrl"]}");
    if (_audioPlayer.state == PlayerState.paused) {
      await _audioPlayer.resume();
    } else {
      await _audioPlayer.stop();
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.loading,
      ));
      mediaItem.add(mi);
      final url = Uri.encodeFull(mi?.extras?["musUrl"]);
      await _audioPlayer.play(UrlSource(url));
    }
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.ready,
      playing: true,
    ));
  }


  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.ready,
      playing: false,
    ));
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
        updatePosition: Duration.zero));
  }

  // 修改进度
  @override
  Future<void> seek(Duration position) async {
    currentPosition = position;
    playbackState.add(playbackState.value.copyWith(updatePosition: position));
    await _audioPlayer.seek(position);
  }

  // 仅更新通知栏/锁屏的演唱者标题（可选）
  Future<void> updateArtist(String lyric) async {
    final cur = musPlaySlice.curMedia;
    if (cur == null) return;
    String title=cur.title;
    if(cur.extras?["singers"]!=null){
      title='${cur.title} - ${getSingersName(cur.extras)}';
      // print("tit $title");
    }
    mediaItem.add(cur.copyWith(artist: lyric, title: title));
  }

  // ======== 速率/音量 ========

  @override
  Future<void> setSpeed(double s) async {
    speed.add(s);
    await _audioPlayer.setPlaybackRate(s);
  }

  @override
  Future<void> setVolume(double v) async {
    volume.add(v);
    await _audioPlayer.setVolume(v);
  }

  @override
  Future<void> skipToPrevious() async {
    onSkipTo?.call(false);
  }

  @override
  Future<void> skipToNext() async {
    onSkipTo?.call(true);
  }


  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    // final enabled = shuffleMode == AudioServiceShuffleMode.all;
    // if (enabled) {
    // await _audioPlayer.shuffle();
    // }
    // playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
    // await _audioPlayer.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
    onRepeatMode?.call(repeatMode);
  }

  // ======== 队列相关（全部由上层接管；这里 NO-OP，避免误用） ========
/*
  @override
  Future<void> addQueueItem(MediaItem item) async {}
  @override
  Future<void> addQueueItems(List<MediaItem> items) async {}
  @override
  Future<void> insertQueueItem(int index, MediaItem item) async {}
  @override
  Future<void> updateQueue(List<MediaItem> queue) async {}
  @override
  Future<void> removeQueueItemAt(int index) async {}
  @override
  Future<void> skipToNext() async {*//* 上层调用 slice.next() *//*}
  @override
  Future<void> skipToPrevious() async {*//* 上层调用 slice.previous() *//*}
  @override
  Future<void> skipToQueueItem(int index) async {*//* 上层调用 slice.playAt(index) *//*}
  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode mode) async {*//* 上层管理 *//*}
  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode mode) async {*//* 上层管理 *//*}*/
}
String getSingersName(Map<String, dynamic>? extra){
  final s=extra?["singers"];
  return s==null?'':s.map((e)=>e["name"]).join('、');
}