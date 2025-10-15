import 'package:go_router/go_router.dart';

import '../pages/detailPage.dart';
import '../pages/indexPage.dart';
import '../pages/testPage.dart';

import '../pages/testPage2.dart';
import 'routes.dart';

final GoRouter router= GoRouter(
  // refreshListenable: ValueNotifier(context),
  initialLocation: '/',
  routes: [
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
      builder: (context, state){
        final id = state.pathParameters['id']; // 获取动态参数
        final name = state.uri.queryParameters; // 获取查询参数
        return DetailPage();
      },
    ),
  ],
);
