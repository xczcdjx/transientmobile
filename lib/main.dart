import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:transientmobile/hooks/useStore.dart';
import 'package:transientmobile/router/index.dart';
import 'package:transientmobile/store/index.dart';
import 'package:transientmobile/styles/theme.dart';
import 'package:transientmobile/utils/shareStorage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ShareStorage.init(); // 初始化存储
  // 尝试读取用户上次选择的语言
  // final savedLocale=ShareStorage.get<String>('locale');

  runApp(ProviderScope(
    child: EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('zh')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      // startLocale: savedLocale != null ? Locale(savedLocale) : null,
      saveLocale: true,
      child: MyApp(),
    ),
  ));
}

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    // print("lang ${Localizations.localeOf(context)}");
    final themeMode=useSelector(ref, settingProvider, (s)=>s.themeMode);
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
