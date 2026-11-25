import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transientmobile/components/music/empty_mini_player.dart';

void main() {
  for (final wide in [false, true]) {
    testWidgets('empty player only enables play (wide=$wide)', (tester) async {
      var played = false;
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SizedBox(
                  width: wide ? 800 : 320,
                  child: EmptyMiniPlayer(
                      wide: wide, onPlay: () => played = true)))));
      expect(find.text('Music'), findsOneWidget);
      final buttons =
          tester.widgetList<IconButton>(find.byType(IconButton)).toList();
      expect(buttons.where((b) => b.onPressed != null).length, 1);
      expect(buttons.singleWhere((button) => button.tooltip == '下一首').onPressed,
          isNull);
      expect(
          buttons.singleWhere((button) => button.tooltip == '播放列表').onPressed,
          isNull);
      await tester.tap(find.byTooltip('播放'));
      expect(played, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
