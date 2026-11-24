import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transientmobile/components/music/comSlider.dart';
import 'package:transientmobile/music/common.dart';
import 'package:transientmobile/styles/theme.dart';

void main() {
  testWidgets('buffer track displays reported range and loading animation',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: lightTheme,
        home: Scaffold(
            body: SeekBar(
                duration: const Duration(seconds: 100),
                position: const Duration(seconds: 10),
                bufferedPosition: const Duration(seconds: 40),
                isBuffering: true))));
    expect(tester.takeException(), isNull);
    final indicators = tester
        .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator))
        .toList();
    expect(indicators.map((item) => item.value), [0.4, null]);
    await tester.pumpWidget(MaterialApp(
        theme: lightTheme,
        home: Scaffold(
            body: SeekBar(
                duration: const Duration(seconds: 100),
                position: const Duration(seconds: 10),
                bufferedPosition: const Duration(seconds: 40)))));
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  for (final compact in [false, true]) {
    Widget bar(
        {required Duration duration,
        required Duration position,
        Duration buffered = Duration.zero,
        ValueChanged<Duration>? onEnd}) {
      final child = compact
          ? ComSeekBar(
              duration: duration,
              position: position,
              bufferedPosition: buffered,
              onChangeEnd: onEnd)
          : SeekBar(
              duration: duration,
              position: position,
              bufferedPosition: buffered,
              onChangeEnd: onEnd);
      return MaterialApp(
          theme: lightTheme, home: Scaffold(body: Center(child: child)));
    }

    void checkRanges(WidgetTester tester) {
      expect(tester.takeException(), isNull);
      for (final slider in tester.widgetList<Slider>(find.byType(Slider))) {
        expect(slider.value, inInclusiveRange(slider.min, slider.max));
      }
    }

    testWidgets(
        '${compact ? "compact" : "full"}: negative and oversized progress',
        (tester) async {
      for (final value in [-1, 0, 100, 263000]) {
        await tester.pumpWidget(bar(
            duration: const Duration(seconds: 262),
            position: Duration(milliseconds: value),
            buffered: Duration(milliseconds: value)));
        checkRanges(tester);
      }
    });
    testWidgets(
        '${compact ? "compact" : "full"}: unknown duration disables seeking',
        (tester) async {
      for (final duration in [
        Duration.zero,
        const Duration(milliseconds: -1)
      ]) {
        await tester.pumpWidget(bar(
            duration: duration,
            position: const Duration(seconds: 30),
            buffered: const Duration(milliseconds: -1)));
        checkRanges(tester);
        for (final slider in tester.widgetList<Slider>(find.byType(Slider))) {
          expect(slider.value, 0);
          expect(slider.onChanged, isNull);
        }
      }
    });
    testWidgets('${compact ? "compact" : "full"}: duration shrinks during drag',
        (tester) async {
      Duration? result;
      await tester.pumpWidget(bar(
          duration: const Duration(seconds: 262),
          position: const Duration(seconds: 10),
          onEnd: (value) => result = value));
      tester.widgetList<Slider>(find.byType(Slider)).last.onChanged!(250000);
      await tester.pump();
      await tester.pumpWidget(bar(
          duration: const Duration(seconds: 30),
          position: const Duration(seconds: 5),
          onEnd: (value) => result = value));
      checkRanges(tester);
      var slider = tester.widgetList<Slider>(find.byType(Slider)).last;
      expect(slider.value, 5000);
      slider.onChanged!(20000);
      await tester.pump();
      slider = tester.widgetList<Slider>(find.byType(Slider)).last;
      slider.onChangeEnd!(20000);
      await tester.pump();
      expect(result, const Duration(seconds: 20));
      checkRanges(tester);
    });
  }
}
