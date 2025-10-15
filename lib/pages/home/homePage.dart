import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../../utils/getDevice.dart';
import '../../widgets/langSwitch.dart';
import '../../widgets/themeSwitch.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ({String device, String poem}) dInfo = getDevice();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /* title: Text(
          // 'Transient ${dInfo.device}',
          'Test',
          style: TextStyle(color: context.fc),
        ),*/
        actions: [
          ThemeSwitch(),
          SizedBox(
            width: 10,
          ),
          LangSwitch()
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child:
          Column(
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
                    style:
                    TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              TextButton(
                  onPressed: () {
                    context.push(Routes.test);
                  },
                  child: Text('TestPage')),
              TextButton(
                  onPressed: () {
                    context.push(Routes.test2);
                  },
                  child: Text('TestPage2')),
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
             /* TextButton(
                  onPressed: () {
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: '',
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (_, __, ___) {
                        return MusMainPlay();
                      },
                      transitionBuilder: (_, anim, __, child) {
                        return SlideTransition(
                          position: Tween(
                              begin: const Offset(0, 1), end: Offset.zero)
                              .animate(anim),
                          child: child,
                        );
                      },
                    );
                  },
                  child: Text('botPopup')),*/
              Container(
                height: 1000,
                child: Center(
                  child: Text(
                    dInfo.poem,
                    style:
                    TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
