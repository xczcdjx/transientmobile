import 'package:go_router/go_router.dart';

import '../pages/detailPage.dart';
import '../pages/homePage.dart';
import '../pages/testPage.dart';

import 'routes.dart';

final GoRouter router= GoRouter(
  // refreshListenable: ValueNotifier(context),
  initialLocation: '/',
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: Routes.test,
      builder: (context, state) => TestPage(),
    ),
    GoRoute(
      path: '${Routes.detail}/:id',
      builder: (context, state){
        final id = state.pathParameters['id']; // 获取动态参数
        final name = state.uri.queryParameters; // 获取查询参数
        return DetailPage();
      },
    ),
  ],
);
