import 'package:transientmobile/utils/HiveUtil.dart';

import 'constants/index.dart';
import 'styles/app_glass.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:transientmobile/router/index.dart';
import 'package:transientmobile/service/audioHandlerService.dart';
import 'package:transientmobile/store/index.dart';
import 'package:transientmobile/styles/theme.dart';
import 'utils/settings_storage.dart';
import 'utils/preferences_migration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// late AudioPlayerHandler _audioHandler;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await AppGlass.initialize();
  // 初始化Hive
  await HiveUtil.init();
  // 初始化openBox Keys
  await Future.wait(
    HiveKeys.all.map((name) => HiveUtil.openBox(name)),
  );
  // await PreferencesMigration.migrate();
  final savedLanguage = SettingsStorage.languageCode;
  final container = ProviderContainer();
  await AudioHandlerService.instance.init(container); // 初始化音频服务

  runApp(UncontrolledProviderScope(
    container: container,
    child: EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('zh')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: savedLanguage == null ? null : Locale(savedLanguage),
      saveLocale: false,
      child: const OKToast(
        child: MyApp(),
      ),
    ),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // print("lang ${Localizations.localeOf(context)}");
    final settings = ref.watch(settingProvider);
    return MaterialApp.router(
      theme: buildAppTheme(Brightness.light, settings.themeColor),
      darkTheme: buildAppTheme(Brightness.dark, settings.themeColor),
      themeMode: settings.themeMode,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: router,
      title: 'Transient',
      builder: (context, child) =>
          AppGlass.wrap(child ?? const SizedBox.shrink()),
    );
  }
}
