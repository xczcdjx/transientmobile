import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transientmobile/service/play_list_controller.dart';
import 'package:transientmobile/service/mus_player_controller.dart';
import 'package:transientmobile/store/index.dart';
import 'package:transientmobile/utils/AudioHandler.dart';
import 'audio_handler_test.dart' show TestPlayer, track;

void main() {
  testWidgets('back closes queue before underlying player overlay',
      (tester) async {
    late BuildContext pageContext;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      pageContext = context;
      return const Scaffold(body: Text('underlying page'));
    })));
    final player = PlayerModalRoute(
        child: Builder(
            builder: (context) => Material(
                child: Center(
                    child: TextButton(
                        child: const Text('open queue'),
                        onPressed: () => GlobalBottomSheet.show(
                            context: context,
                            child: Builder(
                                builder: (context) => Center(
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                          const Text('queue contents'),
                                          TextButton(
                                              onPressed: () => GlobalBottomSheet
                                                  .confirmClear(context),
                                              child: const Text('ask clear')),
                                        ])))))))));
    Navigator.of(pageContext).push(player);
    await tester.pumpAndSettle();
    await tester.tap(find.text('open queue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // The sheet must already paint above the player during entry, not jump
    // above it only after the transition completes.
    expect(find.text('queue contents').hitTestable(), findsOneWidget);
    await tester.pumpAndSettle();
    expect(GlobalBottomSheet.isShowing, isTrue);
    expect(find.text('queue contents').hitTestable(), findsOneWidget);
    await tester.tap(find.text('ask clear'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('清空播放列表？').hitTestable(), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(GlobalBottomSheet.isShowing, isTrue);
    expect(find.text('queue contents').hitTestable(), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(GlobalBottomSheet.isShowing, isFalse);
    expect(player.isCurrent, isTrue);
    expect(find.text('open queue').hitTestable(), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(player.isActive, isFalse);
  });

  testWidgets('queue supports removal, empty state and close action',
      (tester) async {
    final handler = AudioPlayerHandlerImpl(player: TestPlayer());
    final slice = MusPlaySlice(handler);
    await tester.runAsync(() => slice.setQueue([track('a')], autoPlay: false));
    await tester.pumpWidget(ProviderScope(
        overrides: [musPlayProvider.overrideWith((ref) => slice)],
        child: MaterialApp(
            home: Builder(
                builder: (context) => Scaffold(
                    body: TextButton(
                        onPressed: () =>
                            GlobalBottomSheet.show(context: context),
                        child: const Text('open queue')))))));
    await tester.tap(find.text('open queue'));
    await tester.pumpAndSettle();
    expect(find.text('1 首歌曲'), findsOneWidget);
    await tester.tap(find.text('全部清除'));
    await tester.pumpAndSettle();
    expect(find.text('清空播放列表？'), findsOneWidget);
    expect(slice.state.playList.length, 1);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(GlobalBottomSheet.isShowing, isTrue);
    expect(slice.state.playList.length, 1);
    await tester.tap(find.text('全部清除'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(slice.state.playList.length, 1);
    await tester.tap(find.byTooltip('移除 Title a'));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
    expect(find.text('播放列表为空'), findsOneWidget);
    expect(find.text('0 首歌曲'), findsOneWidget);
    await tester.runAsync(() => slice.setQueue([track('a'), track('b')]));
    await tester.pumpAndSettle();
    await tester.tap(find.text('全部清除'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认清空'));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
    expect(slice.state.playList, isEmpty);
    expect(handler.playbackState.value.playing, isFalse);
    expect(find.text('播放列表为空'), findsOneWidget);
    await tester.tap(find.byTooltip('关闭播放列表'));
    await tester.pumpAndSettle();
    expect(GlobalBottomSheet.isShowing, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(handler.dispose);
  });
}
