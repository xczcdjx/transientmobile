import '../pages/test/liquid_glass_test_page.dart';
import '../pages/settings/theme_settings_page.dart';
import 'package:go_router/go_router.dart';
import 'package:transientmobile/pages/other/lastUploadPage.dart';

import '../pages/other/detailPage.dart';
import '../pages/indexPage.dart';
import '../pages/test/testPage.dart';
import '../pages/test/testPage2.dart';
import 'routes.dart';

final GoRouter router = GoRouter(
  // refreshListenable: ValueNotifier(context),
  initialLocation: '/',
  routes: [
    GoRoute(
      path: Routes.liquidGlassTest,
      builder: (context, state) => const LiquidGlassTestPage(),
    ),
    GoRoute(
        path: Routes.themeSettings,
        builder: (context, state) => const ThemeSettingsPage()),
    GoRoute(
      path: Routes.home,
      builder: (context, state) => IndexPage(),
    ),
    GoRoute(
      path: Routes.test,
      builder: (context, state) => TestPage(),
    ),
    GoRoute(
      path: Routes.test2,
      builder: (context, state) => TestPage2(),
    ),
    GoRoute(
      path: '${Routes.detail}/:id',
      builder: (context, state) {
        return DetailPage();
      },
    ),
    GoRoute(
      path: Routes.lastUpload,
      builder: (context, state) => LastUploadPage(),
    ),
  ],
);
