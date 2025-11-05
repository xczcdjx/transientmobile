import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:transientmobile/components/common/botNavBar.dart';
import 'package:transientmobile/hooks/useStore.dart';
import 'package:transientmobile/music/musBotScreen.dart';
import 'package:transientmobile/music/musMainPlay.dart';
import 'package:transientmobile/pages/home/homePage.dart';
import 'package:transientmobile/pages/home/minePage.dart';
import 'package:transientmobile/store/index.dart';
import 'package:transientmobile/widgets/langSwitch.dart';
import 'package:transientmobile/widgets/themeSwitch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/routes.dart';
import '../extensions/customColors.dart';
import '../utils/getDevice.dart';

class IndexPage extends ConsumerStatefulWidget {
  const IndexPage({super.key});

  @override
  ConsumerState<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends ConsumerState<IndexPage> {
  final List<Widget> pages = [HomePage(), MinePage()];
  int _pageIndex = 0;

  void _upPageIndex(int i) {
    setState(() {
      _pageIndex = i;
    });
  }

  Widget _renderIndexBody(bool isTab) {
    if (isTab) {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                  BotNavBar(
                    onTabChange: _upPageIndex,
                    isTablet: true,
                  ),
                Expanded(
                    child: IndexedStack(
                      index: _pageIndex,
                      children: pages,
                    )),
              ],
            ),
          ),
          // 后续会使用宽屏组件
          MusBotScreen()
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(
              child: IndexedStack(
            index: _pageIndex,
            children: pages,
          )),
          MusBotScreen()
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTab = isTabletAll(context);
    final dispatch = useDispatch(ref, settingProvider);
    return Scaffold(
      body: _renderIndexBody(isTab),
      bottomNavigationBar: isTab
          ? null
          : BotNavBar(
              onTabChange: _upPageIndex,
            ),
    );
  }
}
