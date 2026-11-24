import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import '../models/store/music_state.dart';
import '../utils/musFun.dart';

/// Owns lyric loading independently of whether the player UI is mounted.
class AudioLyricsController {
  AudioLyricsController({
    required Stream<MediaItem?> mediaItems,
    required Stream<Duration> positions,
    required this.loadLyrics,
    required this.publishLine,
  }) {
    _subscriptions.add(
        mediaItems.distinct((a, b) => a?.id == b?.id).listen(_onMediaItem));
    _subscriptions.add(positions.distinct().listen(_onPosition));
  }

  final Future<String> Function(String id) loadLyrics;
  final void Function(String id, String? line) publishLine;
  final state = BehaviorSubject<MusicState>.seeded(MusicState());
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  LrcParser? parser;
  String? _trackId;
  String? _lastLine;
  int _request = 0;
  bool _disposed = false;

  void _onMediaItem(MediaItem? item) {
    _trackId = item?.id;
    final request = ++_request;
    parser = null;
    _lastLine = null;
    state.add(MusicState());
    if (item == null) return;
    publishLine(item.id, null);
    unawaited(_load(item.id, request));
  }

  Future<void> _load(String id, int request) async {
    try {
      final text = await loadLyrics(id);
      if (_disposed || request != _request) return;
      parser = LrcParser.from(text);
      state.add(state.value.copyWith(lyric: text));
      _publishAt(state.value.position);
    } catch (error) {
      if (!_disposed && request == _request) {
        debugPrint('Failed to load lyrics for track $id: $error');
      }
    }
  }

  void _onPosition(Duration position) {
    if (_disposed) return;
    state.add(state.value.copyWith(position: position));
    _publishAt(position);
  }

  void _publishAt(Duration position) {
    final id = _trackId;
    if (id == null) return;
    final line = parser?.getByTime(position.inMilliseconds / 1000);
    // Compare content, not elapsed time: backwards seeks must update immediately.
    if (line == _lastLine) return;
    _lastLine = line;
    publishLine(id, line);
  }

  Future<void> dispose() async {
    _disposed = true;
    _request++;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await state.close();
  }
}
