import 'styles/app_glass.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:transientmobile/router/index.dart';
import 'package:transientmobile/service/audioHandlerService.dart';
import 'package:transientmobile/store/index.dart';
import 'package:transientmobile/styles/theme.dart';
import 'package:transientmobile/utils/shareStorage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// late AudioPlayerHandler _audioHandler;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await AppGlass.initialize();
  await ShareStorage.init(); // 初始化存储
  final container = ProviderContainer();
  await AudioHandlerService.instance.init(container); // 初始化音频服务
  // 尝试读取用户上次选择的语言
  // final savedLocale=ShareStorage.get<String>('locale');

  runApp(UncontrolledProviderScope(
    container: container,
    child: EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('zh')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      // startLocale: savedLocale != null ? Locale(savedLocale) : null,
      saveLocale: true,
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
