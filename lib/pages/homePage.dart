import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transientmobile/hooks/useStore.dart';
import 'package:transientmobile/store/index.dart';
import 'package:transientmobile/widgets/langSwitch.dart';
import 'package:transientmobile/widgets/themeSwitch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/common/bannerCom.dart';
import '../router/routes.dart';
import '../extensions/customColors.dart';
import '../utils/getDevice.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  ({String device, String poem}) dInfo = getDevice();

  @override
  Widget build(BuildContext context) {
    final dispatch = useDispatch(ref, settingProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transient ${dInfo.device}',
          style: TextStyle(color: context.primary),
        ),
        actions: [
          ThemeSwitch(),
          SizedBox(
            width: 10,
          ),
          LangSwitch()
        ],
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BannerWidget(),
          Container(
            height: 300,
            child: Center(
              child: Text(
                dInfo.poem,
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            ),
          )
          /*Text("Home"),
          TextButton(
              onPressed: () {
                context.push(Routes.test);
              },
              child: Text('Go test')),
          TextButton(
              onPressed: () {
                context.push(Uri(
                    path: Routes.detail + "/111",
                    queryParameters: {'name': '张三', 'gender': '男'}).toString());
              },
              child: Text('Go detail')),*/
        ],
      ),
    );
  }
}

