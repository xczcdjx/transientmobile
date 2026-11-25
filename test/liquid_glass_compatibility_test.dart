import 'package:flutter/material.dart';
import 'package:transientmobile/styles/app_glass.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transientmobile/pages/test/liquid_glass_test_page.dart';

void main() {
  testWidgets('glass playground initializes and responds to playback preview',
      (tester) async {
    // Exercise the standard path; the package's premium shader keys assume
    // tests live inside the package itself rather than a consuming app.
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        builder: (context, child) => AppGlass.wrap(child!),
        home: const LiquidGlassTestPage()));
    // Shader loading performs real asynchronous asset I/O.
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 30));
      if (find.text('Transient · 光影之间').evaluate().isNotEmpty) break;
    }
    expect(find.text('Transient · 光影之间'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('收藏'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('正在预览：收藏'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('我的'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('正在预览：我的'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    debugDefaultTargetPlatformOverride = null;
  });
}
