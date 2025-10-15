import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:transientmobile/extensions/customColors.dart';
import 'package:transientmobile/utils/screenUtil.dart';

class BotNavBar extends StatefulWidget {
  final void Function(int)? onTabChange;
  bool isTablet;
  BotNavBar({super.key, required this.onTabChange,this.isTablet=false});

  @override
  State<BotNavBar> createState() => _BotNavBarState();
}

class _BotNavBarState extends State<BotNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final items = const [
      {'icon': Icons.home, 'text': 'Home'},
      {'icon': Icons.person, 'text': 'Me'},
    ];

    if (widget.isTablet) {
      // ✅ 平板模式：左侧垂直导航栏
      return Center(
        child: Container(
          width: 90,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(1, 0),
              ),
            ],
          ),
          child:
          NavigationRail(
            selectedIndex: _selectedIndex,
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.transparent,
            groupAlignment: 0.0,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
              widget.onTabChange?.call(index);
            },
           /* leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Icon(Icons.menu, color: context.fc),
            ),*/
            destinations: [
              for (final item in items)
                NavigationRailDestination(
                  icon: Icon(item['icon'] as IconData, color: Colors.grey[400]),
                  selectedIcon:
                  Icon(item['icon'] as IconData, color: context.pcr),
                  label: Text(
                    item['text'] as String,
                    style: TextStyle(
                      color: _selectedIndex == items.indexOf(item)
                          ? context.pcr
                          : Colors.grey[400],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // ✅ 手机模式：底部导航栏（原逻辑保留）
    return Container(
      padding: EdgeInsets.only(bottom: ScreenUtil.bottomBarHeight(context) + 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: GNav(
        color: Colors.grey[400],
        gap: 8,
        activeColor: context.pcr,
        mainAxisAlignment: MainAxisAlignment.center,
        tabBorderRadius: 16,
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          setState(() => _selectedIndex = index);
          widget.onTabChange?.call(index);
        },
        tabs: [
          for (final item in items)
            GButton(icon: item['icon'] as IconData, text: item['text'] as String),
        ],
      ),
    );
  }
}
