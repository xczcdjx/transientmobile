import 'dart:async';
import 'package:audioplayers/audioplayers.dart' as legacy;
import 'package:just_audio/just_audio.dart' as ja;
import 'package:flutter/foundation.dart';

/// Compatibility boundary for existing UI/handler callers. Production playback
/// uses just_audio only; constructing this object never creates an audioplayers player.
class JustAudioPlayback implements legacy.AudioPlayer {
  JustAudioPlayback({ja.AudioPlayer? player})
      : _player = player ?? ja.AudioPlayer() {
    _subscriptions.add(_player.playerStateStream.listen((value) {
      final next = value.processingState == ja.ProcessingState.completed
          ? legacy.PlayerState.completed
          : value.processingState == ja.ProcessingState.idle
              ? legacy.PlayerState.stopped
              : value.playing
                  ? legacy.PlayerState.playing
                  : legacy.PlayerState.paused;
      if (next != _state) {
        _state = next;
        _states.add(next);
      }
      _buffer.add({
        'playerId': playerId,
        'url': _url,
        'type': value.processingState == ja.ProcessingState.buffering ? 1 : 2
      });
    }));
    _subscriptions.add(_player.errorStream.listen((error) {
      _states.addError(error);
    }));
  }
  final ja.AudioPlayer _player;
  final _states = StreamController<legacy.PlayerState>.broadcast();
  final _buffer = StreamController<Map<String, dynamic>>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  StreamSubscription<double>? _download;
  String _url = '';
  int _revision = 0;
  double _fraction = 0;
  legacy.PlayerState _state = legacy.PlayerState.stopped;
  @override
  String get playerId => 'main-just-audio';
  Stream<Map<String, dynamic>> get bufferEvents => _buffer.stream;
  @override
  legacy.PlayerState get state => _state;
  @override
  Stream<legacy.PlayerState> get onPlayerStateChanged => _states.stream;
  @override
  Stream<Duration> get onPositionChanged => _player.positionStream;
  @override
  Stream<Duration> get onDurationChanged =>
      _player.durationStream.where((value) => value != null).cast<Duration>();
  @override
  Future<void> setReleaseMode(legacy.ReleaseMode mode) async {}

  @override
  Future<void> play(legacy.Source source,
      {double? volume,
      double? balance,
      legacy.AudioContext? ctx,
      Duration? position,
      legacy.PlayerMode? mode}) async {
    final revision = ++_revision;
    _url = (source as legacy.UrlSource).url;
    await _download?.cancel();
    _fraction = 0;
    final uri = Uri.parse(_url);
    final ja.AudioSource audioSource;
    if (!kIsWeb && (uri.scheme == 'https' || uri.scheme == 'http')) {
      final caching = ja.LockCachingAudioSource(uri);
      _download = caching.downloadProgressStream.listen((fraction) {
        if (revision != _revision || !fraction.isFinite) return;
        _fraction = fraction.clamp(0.0, 1.0);
        _reportDownload();
      }, onError: (Object error) {
        debugPrint('Audio cache download failed: $error');
      });
      audioSource = caching;
    } else {
      audioSource = ja.AudioSource.uri(uri);
    }
    await _player.setAudioSource(audioSource,
        initialPosition: position ?? Duration.zero);
    if (revision != _revision) return;
    _reportDownload();
    // just_audio.play completes on pause/stop/end, so it must not block the
    // handler command queue while the track is playing.
    unawaited(_player.play().catchError((Object error) {
      _states.addError(error);
    }));
  }

  void _reportDownload() => _buffer.add({
        'playerId': playerId,
        'url': _url,
        'type': 4,
        'downloadFraction': _fraction
      });
  @override
  Future<void> resume() async {
    unawaited(_player.play().catchError((Object error) {
      _states.addError(error);
    }));
  }

  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() async {
    ++_revision;
    await _download?.cancel();
    _download = null;
    await _player.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  Future<void> setPlaybackRate(double rate) => _player.setSpeed(rate);
  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);
  @override
  Future<Duration?> getDuration() async => _player.duration;
  @override
  Future<void> dispose() async {
    ++_revision;
    await _download?.cancel();
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    await _player.dispose();
    await _states.close();
    await _buffer.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
