import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transientmobile/service/audio_lyrics_controller.dart';
import 'package:transientmobile/utils/musFun.dart';

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  test('LRC centiseconds, milliseconds, whole seconds and repeated tags', () {
    final parser =
        LrcParser.from('[00:02.50]two\n[00:01.005]one\n[00:03][00:05]repeat');
    expect(parser.getByTime(1.004), isNull);
    expect(parser.getByTime(1.005), 'one');
    expect(parser.getByTime(2.49), 'one');
    expect(parser.getByTime(2.5), 'two');
    expect(parser.getByTime(3), 'repeat');
    expect(parser.lines.map((line) => line['time']), [1.005, 2.5, 3.0, 5.0]);
  });

  test(
      'load once per track, publish only changed lines and support backwards seek',
      () async {
    final media = BehaviorSubject<MediaItem?>.seeded(null);
    final positions = BehaviorSubject<Duration>.seeded(Duration.zero);
    var loads = 0;
    final lines = <String?>[];
    final controller = AudioLyricsController(
      mediaItems: media,
      positions: positions,
      loadLyrics: (_) async {
        loads++;
        return '[00:01.00]first\n[00:02.00]second';
      },
      publishLine: (_, line) => lines.add(line),
    );
    media.add(const MediaItem(id: 'a', title: 'song'));
    await flush();
    media.add(
        const MediaItem(id: 'a', title: 'song', artist: 'metadata update'));
    positions.add(const Duration(milliseconds: 1100));
    await flush();
    positions.add(const Duration(milliseconds: 1500));
    await flush();
    positions.add(const Duration(seconds: 3));
    await flush();
    positions.add(const Duration(milliseconds: 1200));
    await flush();
    positions.add(Duration.zero);
    await flush();
    expect(loads, 1);
    expect(lines, [null, 'first', 'second', 'first', null]);
    await controller.dispose();
    await media.close();
    await positions.close();
  });

  test('late response cannot overwrite next track or publish after disposal',
      () async {
    final media = StreamController<MediaItem?>();
    final positions = StreamController<Duration>();
    final requests = <String, Completer<String>>{};
    final lines = <String>[];
    final controller = AudioLyricsController(
      mediaItems: media.stream,
      positions: positions.stream,
      loadLyrics: (id) => (requests[id] = Completer<String>()).future,
      publishLine: (id, line) => lines.add('$id:$line'),
    );
    media.add(const MediaItem(id: 'a', title: 'A'));
    await flush();
    media.add(const MediaItem(id: 'b', title: 'B'));
    await flush();
    requests['b']!.complete('[00:00]B');
    await flush();
    requests['a']!.complete('[00:00]A');
    await flush();
    expect(controller.state.value.lyric, '[00:00]B');
    expect(lines, ['a:null', 'b:null', 'b:B']);
    media.add(const MediaItem(id: 'c', title: 'C'));
    await flush();
    await controller.dispose();
    requests['c']!.complete('[00:00]C');
    await flush();
    expect(lines.last, 'c:null');
    await media.close();
    await positions.close();
  });

  test('empty or failed lyrics clear old lyrics without interrupting positions',
      () async {
    final media = StreamController<MediaItem?>();
    final positions = StreamController<Duration>();
    final controller = AudioLyricsController(
      mediaItems: media.stream,
      positions: positions.stream,
      loadLyrics: (id) async {
        if (id == 'b') throw StateError('offline');
        return '[00:00]A';
      },
      publishLine: (_, __) {},
    );
    media.add(const MediaItem(id: 'a', title: 'A'));
    await flush();
    media.add(const MediaItem(id: 'b', title: 'B'));
    await flush();
    positions.add(const Duration(seconds: 2));
    await flush();
    expect(controller.state.value.lyric, '');
    expect(controller.state.value.position, const Duration(seconds: 2));
    await controller.dispose();
    await media.close();
    await positions.close();
  });
}
