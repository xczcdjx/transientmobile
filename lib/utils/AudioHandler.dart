import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// Owns the player and system media state; queue decisions belong to MusPlaySlice.
class AudioPlayerHandlerImpl extends BaseAudioHandler with SeekHandler {
  AudioPlayerHandlerImpl({AudioPlayer? player})
      : _audioPlayer = player ?? AudioPlayer() {
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

  void _setPosition(Duration position) {
    final value = position < Duration.zero ? Duration.zero : position;
    if (value != _position.value) _position.add(value);
  }

  void _updateDuration(Duration duration) {
    final item = _currentItem.value;
    if (item == null || item.duration == duration) return;
    _currentItem.add(item.copyWith(duration: duration));
    final display = mediaItem.value;
    if (display?.id == item.id) {
      mediaItem.add(display!.copyWith(duration: duration));
    }
  }

  void _publishState(AudioProcessingState processing, {required bool playing}) {
    if (_disposed) return;
    playbackState.add(playbackState.value.copyWith(
      processingState: processing,
      errorCode: null,
      errorMessage: null,
      playing: playing,
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 2],
      updatePosition: currentPosition,
      speed: speed.value,
      // audioplayers does not report buffered ranges; do not claim the entire
      // track has been downloaded by publishing its duration as bufferedPosition.
      bufferedPosition: Duration.zero,
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
    if (_currentItem.value?.id != item?.id) _notificationLine = null;
    _setPosition(Duration.zero);
    _currentItem.add(item);
    mediaItem.add(item == null || _notificationLine == null
        ? item
        : item.copyWith(artist: _notificationLine));
  }

  Future<void> setMediaItemOnly(MediaItem? item) => _enqueue(() async {
        await _audioPlayer.stop();
        _loadedId = null;
        _selectItem(item);
        _publishState(AudioProcessingState.idle, playing: false);
      });

  @override
  Future<void> playMediaItem(MediaItem mediaItem) =>
      _enqueue(() => _loadAndPlay(mediaItem));

  Future<void> switchMediaItem() {
    final item = resolveCurrentItem?.call();
    return item == null ? stop() : playMediaItem(item);
  }

  Future<void> _loadAndPlay(MediaItem item) async {
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
      await _audioPlayer.play(UrlSource(uri.toString()));
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
        await _loadAndPlay(item);
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
        await _audioPlayer.seek(target);
        _setPosition(target);
        _publishState(playbackState.value.processingState,
            playing: playbackState.value.playing);
      });

  /// Keep canonical metadata intact; only the system subtitle displays lyrics.
  void updateNotificationLyric(String id, String? line) {
    final item = _currentItem.value;
    if (_disposed || item == null || item.id != id) return;
    final text = line?.trim();
    final normalized = text == null || text.isEmpty ? null : text;
    if (_notificationLine == normalized) return;
    _notificationLine = normalized;
    mediaItem
        .add(normalized == null ? item : item.copyWith(artist: normalized));
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
