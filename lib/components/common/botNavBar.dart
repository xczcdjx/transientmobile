import 'package:flutter/material.dart';
import 'package:transientmobile/extensions/customColors.dart';
import 'package:transientmobile/utils/screenUtil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BotNavBar extends StatefulWidget {
  void Function(int)? onTabChange;

  BotNavBar({super.key, required this.onTabChange});

  @override
  State<BotNavBar> createState() => _BotNavBarState();
}

class _BotNavBarState extends State<BotNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: ScreenUtil.bottomBarHeight(context) + 10),
      child: GNav(
          color: Colors.grey[400],
          gap: 8,
          activeColor: context.pcr,
          // tabActiveBorder: Border.all(color: Colors.white),
          // tabBackgroundColor: Colors.grey.shade100,
          mainAxisAlignment: MainAxisAlignment.center,
          tabBorderRadius: 16,
          onTabChange: widget.onTabChange,
          tabs: [
            GButton(
              icon: Icons.home,
              text: 'Home',
            ),
            GButton(
              icon: Icons.shop,
              text: 'Shop',
            ),
          ]),
    );
  }
}
