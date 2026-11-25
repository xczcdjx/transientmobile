import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:transientmobile/components/common/botNavBar.dart';
import 'package:transientmobile/styles/app_glass.dart';

void main() {
  testWidgets('global glass navigation retains selection when layout changes',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    await tester.runAsync(AppGlass.initialize);
    var selected = 0;
    var wide = false;
    late StateSetter update;
    await tester.pumpWidget(
        MaterialApp(home: StatefulBuilder(builder: (context, setState) {
      update = setState;
      return AppGlass.wrap(Scaffold(
          body: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                  height: wide ? 450 : 100,
                  child: BotNavBar(
                      isTablet: wide,
                      selectedIndex: selected,
                      onTabChange: (value) =>
                          setState(() => selected = value))))));
    })));
    await tester.pump();
    await tester.tap(find.text('我的').hitTestable().first);
    await tester.pump(const Duration(milliseconds: 500));
    expect(selected, 3);
    expect(
        tester.widget<GlassTabBar>(find.byType(GlassTabBar)).selectedIndex, 3);
    update(() => wide = true);
    await tester.pump(const Duration(milliseconds: 500));
    expect(
        tester
            .widget<NavigationRail>(find.byType(NavigationRail))
            .selectedIndex,
        3);
    await tester.tap(find.text('首页').hitTestable().first);
    await tester.pump(const Duration(milliseconds: 500));
    expect(selected, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    debugDefaultTargetPlatformOverride = null;
  });
}
