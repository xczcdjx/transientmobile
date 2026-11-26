import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:transientmobile/constants/index.dart';
import 'package:transientmobile/models/store/mus_play_state.dart';
import 'package:transientmobile/store/index.dart';
import 'package:transientmobile/utils/AudioHandler.dart';
import 'package:transientmobile/utils/HiveUtil.dart';
import 'package:transientmobile/utils/playback_storage.dart';
import 'audio_handler_test.dart' as fixtures;

class ResumePlayer extends fixtures.TestPlayer {
  Duration? startedAt;
  @override
  Future<void> play(Source source,
      {double? volume,
      double? balance,
      AudioContext? ctx,
      Duration? position,
      PlayerMode? mode}) async {
    startedAt = position;
    await super.play(source, position: position);
  }
}

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('playback-storage-');
    Hive.init(directory.path);
    await HiveUtil.openBox(HiveKeys.music);
  });
  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('reopen restores queue, cursor, shuffle order, repeat and position',
      () async {
    await PlaybackStorage.save(
        MusPlayState(
          playList: [fixtures.track('a'), fixtures.track('b')],
          curIndex: 1,
          isShuffling: true,
          randomIdList: ['b', 'a'],
          repeatMode: AudioServiceRepeatMode.all,
        ),
        const Duration(seconds: 4));
    await Hive.close();
    await HiveUtil.openBox(HiveKeys.music);
    final player = ResumePlayer();
    final handler = AudioPlayerHandlerImpl(player: player);
    final slice = MusPlaySlice(handler);
    handler.resolveCurrentItem = () => slice.curMedia;
    await slice.restorePlayback();
    expect(slice.state.curIndex, 1);
    expect(slice.state.playList.map((item) => item.id), ['a', 'b']);
    expect(slice.state.isShuffling, true);
    expect(slice.state.randomIdList, ['b', 'a']);
    expect(slice.state.repeatMode, AudioServiceRepeatMode.all);
    expect(handler.currentPosition, const Duration(seconds: 4));
    expect(player.urls, isEmpty);
    await slice.play();
    expect(player.startedAt, const Duration(seconds: 4));
    await slice.next();
    expect(PlaybackStorage.read().$1.curIndex, 0);
    expect(PlaybackStorage.read().$2, Duration.zero);
    slice.dispose();
    await handler.dispose();
  });

  test('seek while restored and paused is used by the next play', () async {
    final player = ResumePlayer();
    final handler = AudioPlayerHandlerImpl(player: player);
    await handler.setMediaItemOnly(fixtures.track('a'),
        position: const Duration(seconds: 3));
    await handler.seek(const Duration(seconds: 5));
    await handler.play();
    expect(player.startedAt, const Duration(seconds: 5));
    await handler.playMediaItem(fixtures.track('b'));
    expect(player.startedAt, Duration.zero);
    await handler.dispose();
  });

  test('invalid cursor and shuffle are repaired; malformed cache is safe',
      () async {
    await PlaybackStorage.save(
        MusPlayState(
          playList: [fixtures.track('a')],
          curIndex: 99,
          isShuffling: true,
          randomIdList: ['missing'],
        ),
        const Duration(seconds: 99));
    final (state, position) = PlaybackStorage.read();
    expect(state.curIndex, 0);
    expect(state.isShuffling, false);
    expect(position, const Duration(seconds: 10));
    await HiveUtil.set(
        'playbackSnapshot',
        {
          'items': [123]
        },
        boxName: HiveKeys.music);
    expect(PlaybackStorage.read().$1.playList, isEmpty);
  });
}
