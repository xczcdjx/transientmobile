import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transientmobile/utils/AudioHandler.dart';
import 'package:transientmobile/store/index.dart';

class TestPlayer extends Fake implements AudioPlayer {
  final states = StreamController<PlayerState>.broadcast(sync: true);
  final positions = StreamController<Duration>.broadcast(sync: true);
  final durations = StreamController<Duration>.broadcast(sync: true);
  final urls = <String>[];
  int resumes = 0;
  bool released = false;
  Completer<void>? pendingPlay;
  @override
  Stream<PlayerState> get onPlayerStateChanged => states.stream;
  @override
  Stream<Duration> get onPositionChanged => positions.stream;
  @override
  Stream<Duration> get onDurationChanged => durations.stream;
  @override
  Future<void> setReleaseMode(ReleaseMode mode) async {}
  @override
  Future<void> play(Source source,
      {double? volume,
      double? balance,
      AudioContext? ctx,
      Duration? position,
      PlayerMode? mode}) async {
    urls.add((source as UrlSource).url);
    await pendingPlay?.future;
    states.add(PlayerState.playing);
  }

  @override
  Future<void> resume() async {
    resumes++;
    states.add(PlayerState.playing);
  }

  @override
  Future<void> pause() async {
    states.add(PlayerState.paused);
  }

  @override
  Future<void> stop() async {
    states.add(PlayerState.stopped);
  }

  @override
  Future<void> seek(Duration position) async {
    positions.add(position);
  }

  @override
  Future<void> dispose() async {
    released = true;
    await states.close();
    await positions.close();
    await durations.close();
  }
}

MediaItem track(String id) => MediaItem(
    id: id,
    title: 'Title $id',
    artist: 'Artist $id',
    duration: const Duration(seconds: 10),
    extras: {'musUrl': 'https://example.com/$id.mp3'});

void main() {
  test(
      'resume paused track but load selected new track; preserve title and artist',
      () async {
    final player = TestPlayer();
    final handler = AudioPlayerHandlerImpl(player: player);
    var selected = track('a');
    handler.resolveCurrentItem = () => selected;
    await handler.play();
    await handler.pause();
    await handler.play();
    expect(player.resumes, 1);
    await handler.pause();
    selected = track('b');
    await handler.play();
    expect(player.urls,
        ['https://example.com/a.mp3', 'https://example.com/b.mp3']);
    handler.updateNotificationLyric('a', 'stale');
    expect(handler.mediaItem.value!.artist, 'Artist b');
    handler.updateNotificationLyric('b', 'line');
    expect(handler.mediaItem.value!.title, 'Title b');
    expect(handler.mediaItem.value!.artist, 'line');
    handler.updateNotificationLyric('b', null);
    expect(handler.mediaItem.value!.artist, 'Artist b');
    await handler.dispose();
    expect(player.released, isTrue);
  });

  test(
      'serialize rapid track changes and seek; expose a shared position stream',
      () async {
    final player = TestPlayer()..pendingPlay = Completer<void>();
    final handler = AudioPlayerHandlerImpl(player: player);
    final first = handler.playMediaItem(track('a'));
    await Future<void>.delayed(Duration.zero);
    final second = handler.playMediaItem(track('b'));
    expect(player.urls.length, 1);
    player.pendingPlay!.complete();
    await Future.wait([first, second]);
    expect(handler.mediaItem.value!.id, 'b');
    await handler.seek(const Duration(seconds: 99));
    expect(handler.currentPosition, const Duration(seconds: 10));
    await handler.seek(const Duration(seconds: -1));
    expect(handler.currentPosition, Duration.zero);
    expect(identical(handler.positionStream, handler.durationStream), isTrue);
    await handler.dispose();
  });

  test(
      'queue selection, repeat/shuffle callbacks and empty queue stay consistent',
      () async {
    final player = TestPlayer();
    final handler = AudioPlayerHandlerImpl(player: player);
    final slice = MusPlaySlice(handler);
    handler.resolveCurrentItem = () => slice.curMedia;
    await slice.setQueue([track('a'), track('b')], autoPlay: false);
    await slice.play();
    // Selecting an existing different song must switch tracks, not pause A.
    await slice.addMusOne(track('b'));
    expect(handler.mediaItem.value!.id, 'b');
    expect(handler.playbackState.value.playing, isTrue);
    await handler.setRepeatMode(AudioServiceRepeatMode.one);
    expect(slice.state.repeatMode, AudioServiceRepeatMode.one);
    await handler.setShuffleMode(AudioServiceShuffleMode.all);
    expect(slice.state.isShuffling, isTrue);
    slice.insertAt(0, track('c'));
    expect(slice.curMedia!.id, 'b');
    await slice.removeAt(2);
    await slice.removeAt(1);
    await slice.removeAt(0);
    expect(slice.curMedia, isNull);
    expect(handler.mediaItem.value, isNull);
    expect(handler.playbackState.value.playing, isFalse);
    slice.dispose();
    await handler.dispose();
  });

  test('system artwork retains CDN headers across lyric and duration updates',
      () async {
    final player = TestPlayer();
    final handler = AudioPlayerHandlerImpl(player: player);
    final item = track('cover').copyWith(
        artUri: Uri.parse('http://p1.music.126.net/example/cover.jpg'));
    await handler.playMediaItem(item);
    expect(handler.mediaItem.value!.artHeaders?['User-Agent'], 'Mozilla/5.0');
    handler.updateNotificationLyric('cover', 'first line');
    expect(handler.mediaItem.value!.artHeaders?['User-Agent'], 'Mozilla/5.0');
    player.durations.add(const Duration(seconds: 20));
    expect(handler.mediaItem.value!.duration, const Duration(seconds: 20));
    expect(handler.mediaItem.value!.artist, 'first line');
    expect(handler.mediaItem.value!.artHeaders?['User-Agent'], 'Mozilla/5.0');
    handler.updateNotificationLyric('cover', null);
    expect(handler.mediaItem.value!.artist, 'Artist cover');
    expect(handler.mediaItem.value!.artHeaders?['User-Agent'], 'Mozilla/5.0');
    await handler.dispose();
  });

  test(
      'lyric metadata uses current progress and retains remote play/pause action',
      () async {
    final player = TestPlayer();
    final handler = AudioPlayerHandlerImpl(player: player);
    await handler.playMediaItem(track('progress'));
    player.positions.add(const Duration(milliseconds: 2345));
    expect(handler.playbackState.value.updatePosition,
        const Duration(milliseconds: 2345));
    // Less than one second later: metadata publication must still send the
    // exact latest anchor rather than resetting native elapsed time backwards.
    player.positions.add(const Duration(milliseconds: 2600));
    handler.updateNotificationLyric('progress', 'line');
    expect(handler.playbackState.value.updatePosition,
        const Duration(milliseconds: 2600));
    expect(handler.playbackState.value.systemActions,
        contains(MediaAction.playPause));
    expect(handler.playbackState.value.controls, contains(MediaControl.pause));
    await handler.pause();
    expect(handler.playbackState.value.playing, isFalse);
    expect(handler.playbackState.value.controls, contains(MediaControl.play));
    handler.updateNotificationLyric('progress', 'paused line');
    expect(handler.playbackState.value.playing, isFalse);
    await handler.dispose();
  });

  test(
      'default queue is empty; only selected songs are added and clearing stops playback',
      () async {
    final player = TestPlayer();
    final handler = AudioPlayerHandlerImpl(player: player);
    final slice = MusPlaySlice(handler);
    handler.resolveCurrentItem = () => slice.curMedia;
    expect(slice.state.playList, isEmpty);
    expect(slice.curMedia, isNull);
    expect(handler.mediaItem.value, isNull);
    await slice.play();
    await slice.next();
    await slice.previous();
    slice.toggleShuffle();
    expect(player.urls, isEmpty);
    await slice.addMusOne(track('selected'));
    expect(slice.state.playList.map((item) => item.id), ['selected']);
    expect(handler.mediaItem.value!.id, 'selected');
    await slice.setQueue([]);
    expect(slice.state.playList, isEmpty);
    expect(handler.mediaItem.value, isNull);
    expect(handler.playbackState.value.playing, isFalse);
    await slice.play();
    expect(player.urls.length, 1);
    slice.dispose();
    await handler.dispose();
  });

  test('a bad track reports error and does not poison the next command',
      () async {
    final handler = AudioPlayerHandlerImpl(player: TestPlayer());
    await expectLater(
        handler.playMediaItem(const MediaItem(id: 'bad', title: 'bad')),
        throwsStateError);
    await Future<void>.delayed(Duration.zero);
    expect(handler.playbackState.value.processingState,
        AudioProcessingState.error);
    await handler.playMediaItem(track('good'));
    expect(handler.playbackState.value.processingState,
        AudioProcessingState.ready);
    expect(handler.playbackState.value.errorCode, isNull);
    await handler.dispose();
  });
}
