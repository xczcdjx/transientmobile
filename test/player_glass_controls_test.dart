import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transientmobile/components/music/comControl.dart';
import 'package:transientmobile/styles/app_glass.dart';
import 'package:transientmobile/store/index.dart';
import 'package:transientmobile/utils/AudioHandler.dart';
import 'audio_handler_test.dart' show TestPlayer, track;

void main() {
  testWidgets(
      'glass transport controls fit narrow screens and control real queue actions',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(AppGlass.initialize);
    final handler = AudioPlayerHandlerImpl(player: TestPlayer());
    final slice = MusPlaySlice(handler);
    await tester.runAsync(
        () => slice.setQueue([track('a'), track('b')], startIndex: 1));
    var playlistOpened = false;
    await tester.pumpWidget(ProviderScope(
      overrides: [musPlayProvider.overrideWith((ref) => slice)],
      child: MaterialApp(
          builder: (context, child) => AppGlass.wrap(child!),
          home: Scaffold(
              body: Center(
                  child: ComControlBtn(handler,
                      openPlayList: () => playlistOpened = true)))),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 600));
    expect(handler.playbackState.value.playing, isFalse);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.skip_previous_rounded));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 600));
    expect(slice.curMedia?.id, 'a');
    await tester.tap(find.byIcon(Icons.skip_next_rounded));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 600));
    expect(slice.curMedia?.id, 'b');
    await tester.tap(find.byIcon(Icons.queue_music_rounded));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 600));
    expect(playlistOpened, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(handler.dispose);
    await tester.pump(const Duration(seconds: 1));
    debugDefaultTargetPlatformOverride = null;
  });
}
