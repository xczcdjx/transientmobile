import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenUtil {
  /// 屏幕宽度
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// 屏幕高度
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// 状态栏高度
  static double statusBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  /// 底部安全区高度（比如全面屏的虚拟导航栏）
  static double bottomBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  /// 进入全屏（隐藏状态栏和底部导航栏）
  static void enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// 退出全屏（显示状态栏和底部导航栏）
  static void exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
