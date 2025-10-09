import 'package:audio_service/audio_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:transientmobile/hooks/useStore.dart';
import 'package:transientmobile/router/index.dart';
import 'package:transientmobile/service/audioHandlerService.dart';
import 'package:transientmobile/store/index.dart';
import 'package:transientmobile/styles/theme.dart';
import 'package:transientmobile/utils/AudioHandler.dart';
import 'package:transientmobile/utils/shareStorage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// late AudioPlayerHandler _audioHandler;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ShareStorage.init(); // 初始化存储
  await AudioHandlerService.instance.init(); // 初始化音频服务
  // 尝试读取用户上次选择的语言
  // final savedLocale=ShareStorage.get<String>('locale');

/*  _audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );*/

  runApp(ProviderScope(
    child: EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('zh')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      // startLocale: savedLocale != null ? Locale(savedLocale) : null,
      saveLocale: true,
      child: OKToast(
        child: MyApp(),
      ),
    ),
  ));
}

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // print("lang ${Localizations.localeOf(context)}");
    final themeMode = useSelector(ref, settingProvider, (s) => s.themeMode);
    return MaterialApp.router(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: router,
      title: 'Transient',
    );
  }
}
