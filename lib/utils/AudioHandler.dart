import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'media_artwork.dart';
import '../service/just_audio_playback.dart';

/// Owns the player and system media state; queue decisions belong to MusPlaySlice.
class AudioPlayerHandlerImpl extends BaseAudioHandler with SeekHandler {
  AudioPlayerHandlerImpl({AudioPlayer? player, Stream<dynamic>? bufferEvents})
      : _audioPlayer = player ?? JustAudioPlayback() {
    _subscriptions.add(_audioPlayer.onPlayerStateChanged
        .listen(_onPlayerState, onError: _onError));
    _subscriptions.add(_audioPlayer.onPositionChanged.listen((position) {
      if (!_switching && !_disposed) _setPosition(position);
    }, onError: _onError));
    _subscriptions.add(_audioPlayer.onDurationChanged.listen((duration) {
      if (_disposed || duration <= Duration.zero) return;
      if (_switching) {
        _pendingDuration = duration;
      } else {
        _updateDuration(duration);
      }
    }, onError: _onError));
    final events = bufferEvents ??
        (_audioPlayer is JustAudioPlayback ? _audioPlayer.bufferEvents : null);
    if (events != null) {
      _subscriptions.add(events.listen(_onBufferEvent, onError: (Object error) {
        debugPrint('Audio buffer information unavailable: $error');
      }));
    }
    _ready = _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _publishState(AudioProcessingState.idle, playing: false);
  }

  final AudioPlayer _audioPlayer;
  late final Future<void> _ready;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final _position = BehaviorSubject<Duration>.seeded(Duration.zero);
  final _currentItem = BehaviorSubject<MediaItem?>.seeded(null);
  Future<void> _commands = Future.value();
  bool _disposed = false;
  bool _switching = false;
  String? _loadedId;
  Duration? _pendingDuration;
  String? _notificationLine;
  Duration? _lastSystemPosition;
  Duration _bufferedPosition = Duration.zero;
  bool _buffering = false;
  double _downloadFraction = 0;
  PlayerState state = PlayerState.stopped;

  MediaItem? Function()? resolveCurrentItem;
  Future<void> Function(PlayerState state)? onCompleted;
  Future<void> Function(bool isNext)? onSkipTo;
  Future<void> Function(AudioServiceRepeatMode mode)? onRepeatMode;
  Future<void> Function(AudioServiceShuffleMode mode)? onShuffleMode;

  final BehaviorSubject<double> volume = BehaviorSubject.seeded(1.0);
  final BehaviorSubject<double> speed = BehaviorSubject.seeded(1.0);

  Stream<MediaItem?> get currentItemStream => _currentItem.stream;
  Stream<Duration> get positionStream => _position;
  // Kept for existing consumers; every subscriber shares the same native stream.
  Stream<Duration> get durationStream => positionStream;
  Duration get currentPosition => _position.value;

  Future<void> _enqueue(Future<void> Function() operation) {
    final command = _commands.then((_) async {
      if (_disposed) return;
      await _ready;
      await operation();
    });
    _commands = command.catchError((Object error, StackTrace stack) {
      _onError(error);
    });
    return command;
  }

  void _onError(Object error) {
    if (_disposed) return;
    debugPrint('Audio playback failed: $error');
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.error,
      playing: false,
      errorCode: 1,
      errorMessage: '音频播放失败，请重试',
    ));
  }

  void _onBufferEvent(dynamic event) {
    if (_disposed ||
        event is! Map ||
        event['playerId'] != _audioPlayer.playerId) return;
    final item = _currentItem.value;
    if (item == null || (_loadedId == null && !_switching)) return;
    final url = event['url'];
    if (url is String &&
        url != Uri.tryParse(item.extras?['musUrl'] ?? '')?.toString()) return;
    final type = event['type'];
    if (type == 1) _buffering = true;
    if (type == 2) _buffering = false;
    final fraction = event['downloadFraction'];
    if (fraction is num && fraction.isFinite) {
      _downloadFraction = fraction.clamp(0.0, 1.0).toDouble();
      final duration = item.duration ?? Duration.zero;
      _bufferedPosition = Duration(
          microseconds: (duration.inMicroseconds * _downloadFraction).round());
    }
    final end = event['bufferedPosition'];
    if (type == 4 && end is num && end.isFinite && end >= 0) {
      var milliseconds = end.round();
      final duration = item.duration?.inMilliseconds;
      if (duration != null && duration > 0) {
        milliseconds = milliseconds.clamp(0, duration);
      }
      _bufferedPosition = Duration(milliseconds: milliseconds);
    }
    final processing = playbackState.value.processingState;
    if (processing == AudioProcessingState.error ||
        processing == AudioProcessingState.idle) return;
    _publishState(
        _loadedId == null
            ? AudioProcessingState.loading
            : AudioProcessingState.ready,
        playing: playbackState.value.playing);
  }

  void _setPosition(Duration position) {
    final value = position < Duration.zero ? Duration.zero : position;
    if (value != _position.value) _position.add(value);
    // Keep native Now Playing anchored to the actual player position. Its
    // metadata refresh otherwise reuses the last play/seek snapshot.
    final previous = _lastSystemPosition;
    if (playbackState.value.playing &&
        !_switching &&
        (previous == null ||
            (value - previous).abs() >= const Duration(seconds: 1))) {
      _publishState(playbackState.value.processingState, playing: true);
    }
  }

  void _updateDuration(Duration duration) {
    final item = _currentItem.value;
    if (item == null || item.duration == duration) return;
    if (_audioPlayer is JustAudioPlayback) {
      _bufferedPosition = Duration(
          microseconds: (duration.inMicroseconds * _downloadFraction).round());
    }
    _currentItem.add(item.copyWith(duration: duration));
    final display = mediaItem.value;
    if (display?.id == item.id) {
      _publishMediaItem(display!.copyWith(duration: duration));
    }
  }

  void _publishState(AudioProcessingState processing, {required bool playing}) {
    if (_disposed) return;
    _lastSystemPosition = currentPosition;
    playbackState.add(playbackState.value.copyWith(
      // Seeking within a fully downloaded track can briefly report buffering
      // while the decoder repositions. Keep playback controls available.
      processingState: _buffering &&
              _downloadFraction < 1 &&
              processing == AudioProcessingState.ready
          ? AudioProcessingState.buffering
          : processing,
      errorCode: null,
      errorMessage: null,
      playing: playing,
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        // MediaControl.stop
      ],
      systemActions: const {MediaAction.seek, MediaAction.playPause},
      androidCompactActionIndices: const [0, 1, 2],
      updatePosition: currentPosition,
      speed: speed.value,
      bufferedPosition: _bufferedPosition,
    ));
  }

  void _onPlayerState(PlayerState value) {
    if (_disposed) return;
    if (value == PlayerState.completed && state == value) return;
    state = value;
    if (_switching) return;
    switch (value) {
      case PlayerState.playing:
        _publishState(AudioProcessingState.ready, playing: true);
        break;
      case PlayerState.paused:
        _publishState(AudioProcessingState.ready, playing: false);
        break;
      case PlayerState.completed:
        _publishState(AudioProcessingState.completed, playing: false);
        final callback = onCompleted;
        if (callback != null) {
          unawaited(callback(value).catchError((Object error) {
            _onError(error);
          }));
        }
        break;
      case PlayerState.stopped:
      case PlayerState.disposed:
        _publishState(AudioProcessingState.idle, playing: false);
        break;
    }
  }

  void _selectItem(MediaItem? item) {
    _downloadFraction = 0;
    _bufferedPosition = Duration.zero;
    _buffering = false;
    if (_currentItem.value?.id != item?.id) _notificationLine = null;
    _setPosition(Duration.zero);
    _currentItem.add(item);
    _publishMediaItem(item == null || _notificationLine == null
        ? item
        : item.copyWith(artist: _notificationLine));
  }

  Future<void> setMediaItemOnly(MediaItem? item,
          {Duration position = Duration.zero}) =>
      _enqueue(() async {
        await _audioPlayer.stop();
        _loadedId = null;
        _selectItem(item);
        _setPosition(item == null ? Duration.zero : position);
        _publishState(AudioProcessingState.idle, playing: false);
      });

  @override
  Future<void> playMediaItem(MediaItem mediaItem) =>
      _enqueue(() => _loadAndPlay(mediaItem));

  Future<void> switchMediaItem() {
    final item = resolveCurrentItem?.call();
    return item == null ? stop() : playMediaItem(item);
  }

  Future<void> _loadAndPlay(MediaItem item,
      {Duration initialPosition = Duration.zero}) async {
    final rawUrl = item.extras?['musUrl'];
    if (rawUrl is! String || rawUrl.trim().isEmpty) {
      throw StateError('Track ${item.id} has no audio URL');
    }
    final uri = Uri.tryParse(rawUrl);
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw StateError('Track ${item.id} has an invalid audio URL');
    }
    _switching = true;
    _pendingDuration = null;
    try {
      _selectItem(item);
      _publishState(AudioProcessingState.loading, playing: true);
      await _audioPlayer.stop();
      _loadedId = null;
      await _audioPlayer.play(UrlSource(uri.toString()),
          position: initialPosition);
      _setPosition(initialPosition);
      _loadedId = item.id;
      final duration = _pendingDuration;
      if (duration != null) _updateDuration(duration);
    } finally {
      _switching = false;
    }
    _publishState(AudioProcessingState.ready, playing: true);
  }

  @override
  Future<void> play() {
    final item = resolveCurrentItem?.call() ?? _currentItem.value;
    return _enqueue(() async {
      if (item == null) return;
      if (_loadedId == item.id && state == PlayerState.playing) return;
      if (_loadedId == item.id && state == PlayerState.paused) {
        await _audioPlayer.resume();
        _publishState(AudioProcessingState.ready, playing: true);
      } else {
        final position =
            _currentItem.value?.id == item.id ? currentPosition : Duration.zero;
        await _loadAndPlay(item, initialPosition: position);
      }
    });
  }

  @override
  Future<void> pause() => _enqueue(() async {
        await _audioPlayer.pause();
        _publishState(AudioProcessingState.ready, playing: false);
      });

  @override
  Future<void> stop() => _enqueue(() async {
        await _audioPlayer.stop();
        _loadedId = null;
        _bufferedPosition = Duration.zero;
        _buffering = false;
        _setPosition(Duration.zero);
        updateNotificationLyric(_currentItem.value?.id ?? '', null);
        _publishState(AudioProcessingState.idle, playing: false);
      });

  @override
  Future<void> seek(Duration position) => _enqueue(() async {
        final duration = _currentItem.value?.duration;
        var target = position < Duration.zero ? Duration.zero : position;
        if (duration != null && duration > Duration.zero && target > duration) {
          target = duration;
        }
        if (_loadedId != null) await _audioPlayer.seek(target);
        _setPosition(target);
        _publishState(playbackState.value.processingState,
            playing: playbackState.value.playing);
      });

  /// 同步主标题，音乐名，歌手
  void _publishMediaItem(MediaItem? item) {
    // Native metadata updates reset elapsed time to their last state snapshot.
    // Send the current anchor before changing lyrics, artwork or duration.
    _publishState(playbackState.value.processingState,
        playing: playbackState.value.playing);
    if (item == null) {
      mediaItem.add(null);
      return;
    }

    // 从原始歌曲取歌手，因为传进来的 item.artist 可能已被替换成歌词
    final original = _currentItem.value;
    final source = original?.id == item.id ? original! : item;
    final artist = source.artist?.trim() ?? '';

    final title = artist.isEmpty
        ? source.title
        : '${source.title} · $artist';
    // 新增歌手拼接
    mediaItem.add(
      withArtworkHeaders(item.copyWith(title: title)),
    );
  }

  /// Keep canonical metadata intact; only the system subtitle displays lyrics.
  /// 同步副标题，歌词
  void updateNotificationLyric(String id, String? line) {
    final item = _currentItem.value;
    if (_disposed || item == null || item.id != id) return;
    final text = line?.trim();
    final normalized = text == null || text.isEmpty ? null : text;
    if (_notificationLine == normalized) return;
    _notificationLine = normalized;
    _publishMediaItem(
        normalized == null ? item : item.copyWith(artist: normalized));
  }

  @override
  Future<void> setSpeed(double speed) => _enqueue(() async {
        if (!speed.isFinite || speed <= 0) return;
        await _audioPlayer.setPlaybackRate(speed);
        this.speed.add(speed);
        _publishState(playbackState.value.processingState,
            playing: playbackState.value.playing);
      });

  Future<void> setVolume(double value) => _enqueue(() async {
        if (!value.isFinite) return;
        final clamped = value.clamp(0.0, 1.0).toDouble();
        await _audioPlayer.setVolume(clamped);
        volume.add(clamped);
      });

  @override
  Future<void> skipToPrevious() async {
    await onSkipTo?.call(false);
  }

  @override
  Future<void> skipToNext() async {
    await onSkipTo?.call(true);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    await onRepeatMode?.call(repeatMode);
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    await onShuffleMode?.call(shuffleMode);
    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
  }

  Future<void> dispose() async {
    if (_disposed) return;
    await _commands;
    await _audioPlayer.stop();
    _publishState(AudioProcessingState.idle, playing: false);
    _disposed = true;
    onCompleted = null;
    onSkipTo = null;
    onRepeatMode = null;
    onShuffleMode = null;
    resolveCurrentItem = null;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _audioPlayer.dispose();
    await _position.close();
    await _currentItem.close();
    await volume.close();
    await speed.close();
  }
}
