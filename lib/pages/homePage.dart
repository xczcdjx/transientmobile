import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:transientmobile/components/common/botNavBar.dart';
import 'package:transientmobile/hooks/useStore.dart';
import 'package:transientmobile/music/showScreen.dart';
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
          // 'Transient ${dInfo.device}',
          'Test',
          style: TextStyle(color: context.fc),
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
          // BannerWidget(),
          Text("hello".tr()),
          Text("2212112"),
          Container(
            height: 300,
            child: Center(
              child: Text(
                dInfo.poem,
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            ),
          ),
          TextButton(onPressed: (){
            context.push(Routes.test);
          }, child: Text('TestPage'))
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
              child: Text('Go detail')),*/,
          TextButton(onPressed: (){
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: '',
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (_, __, ___) {
                return ShowScreen();
              },
              transitionBuilder: (_, anim, __, child) {
                return SlideTransition(
                  position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(anim),
                  child: child,
                );
              },
            );
          }, child: Text('botPopup')),
        ],
      ),
      bottomNavigationBar: BotNavBar(onTabChange: (i){
        showToast("1111");
      },),
    );
  }
}

