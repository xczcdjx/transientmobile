import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transientmobile/pages/theme_settings_page.dart';
import 'package:transientmobile/store/index.dart';
import 'package:transientmobile/styles/custom.dart';
import 'package:transientmobile/styles/theme.dart';
import 'package:transientmobile/styles/theme_palette.dart';
import 'package:transientmobile/utils/shareStorage.dart';

Widget harness(ProviderContainer container, {Key? previewKey}) =>
    UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) {
            final settings = ref.watch(settingProvider);
            return MaterialApp(
              theme: buildAppTheme(Brightness.light, settings.themeColor),
              darkTheme: buildAppTheme(Brightness.dark, settings.themeColor),
              themeMode: settings.themeMode,
              home: RepaintBoundary(
                  key: previewKey, child: const ThemeSettingsPage()),
            );
          },
        ));

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ShareStorage.init();
  });

  test('restore theme and custom color, preserve custom when selecting presets',
      () async {
    final settings = SettingSlice();
    await settings.toggleTheme(ThemeMode.dark.index);
    await settings.setThemeColor(const Color(0xFF123456), custom: true);
    await settings.setThemeColor(themePresets[2].color);
    final restored = SettingSlice();
    expect(restored.state.themeMode, ThemeMode.dark);
    expect(restored.state.themeColor, themePresets[2].color);
    expect(restored.state.customColor, const Color(0xFF123456));
    expect(restored.state.isCustomColor, isFalse);
    settings.dispose();
    restored.dispose();
  });

  test(
      'invalid saved settings fall back safely; accent reaches playback tokens',
      () async {
    await ShareStorage.set('theme_mode', 999);
    await ShareStorage.set('theme_color', -1);
    final settings = SettingSlice();
    expect(settings.state.themeMode, ThemeMode.system);
    expect(settings.state.themeColor, defaultThemeColor);
    await settings.toggleTheme(-1);
    expect(settings.state.themeMode, ThemeMode.system);
    for (final brightness in Brightness.values) {
      final theme = buildAppTheme(brightness, themePresets[3].color);
      expect(theme.brightness, brightness);
      expect(theme.extension<CustomColors>()!.pcr, themePresets[3].color);
      expect(theme.sliderTheme.thumbColor, themePresets[3].color);
    }
    settings.dispose();
  });

  testWidgets('select presets, dark mode and custom HEX with validation',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(harness(container));
    await tester.tap(find.text('暗黑模式'));
    await tester.pumpAndSettle();
    expect(container.read(settingProvider).themeMode, ThemeMode.dark);
    await tester.ensureVisible(find.text('湖光潋滟'));
    await tester.tap(find.text('湖光潋滟'));
    await tester.pumpAndSettle();
    expect(container.read(settingProvider).themeColor, themePresets[3].color);
    await tester.ensureVisible(find.text('自定义'));
    await tester.tap(find.text('自定义'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'bad');
    await tester.tap(find.text('应用'));
    await tester.pumpAndSettle();
    expect(find.text('请输入 6 位十六进制颜色值'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '#123456');
    await tester.tap(find.text('应用'));
    await tester.pumpAndSettle();
    expect(container.read(settingProvider).themeColor, const Color(0xFF123456));
    expect(container.read(settingProvider).isCustomColor, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'mobile layout preview and custom dialog cancel preserve settings',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container
        .read(settingProvider.notifier)
        .toggleTheme(ThemeMode.dark.index);
    await container
        .read(settingProvider.notifier)
        .setThemeColor(themePresets[3].color);
    final preview = GlobalKey();
    await tester.pumpWidget(harness(container, previewKey: preview));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('自定义'));
    await tester.tap(find.text('自定义'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'FF0000');
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(container.read(settingProvider).themeColor, themePresets[3].color);
    expect(container.read(settingProvider).isCustomColor, isFalse);
  });

  testWidgets(
      'narrow screen and enlarged text stay scrollable without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
            theme: buildAppTheme(Brightness.light, defaultThemeColor),
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.8)),
                child: child!),
            home: const ThemeSettingsPage())));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('自定义'));
    expect(tester.takeException(), isNull);
  });
}
