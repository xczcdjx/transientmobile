import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../styles/app_glass.dart';
import '../../widgets/frosted_surface.dart';

/// Selection belongs to the shell, so resizing never resets the active tab.
class BotNavBar extends StatelessWidget {
  const BotNavBar(
      {super.key,
      required this.onTabChange,
      this.selectedIndex = 0,
      this.isTablet = false});

  final ValueChanged<int>? onTabChange;
  final int selectedIndex;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (isTablet) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        child: FrostedSurface(
          radius: 28,
          child: NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onTabChange,
            backgroundColor: Colors.transparent,
            indicatorColor: colors.primary.withValues(alpha: 0.14),
            selectedIconTheme: IconThemeData(color: colors.primary),
            selectedLabelTextStyle: TextStyle(color: colors.primary),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Icon(Icons.graphic_eq, color: colors.primary, size: 30),
            ),
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('首页')),
              NavigationRailDestination(
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(Icons.search),
                  label: Text('搜索')),
              NavigationRailDestination(
                  icon: Icon(Icons.music_note_outlined),
                  selectedIcon: Icon(Icons.music_note),
                  label: Text('乐库')),
              NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('我的')),
            ],
          ),
        ),
      );
    }
    return GlassTabBar.bottom(
      selectedIndex: selectedIndex,
      onTabSelected: (index) => onTabChange?.call(index),
      quality: AppGlass.quality,
      backgroundQuality: AppGlass.quality,
      selectedIconColor: colors.primary,
      selectedLabelColor: colors.primary,
      unselectedIconColor: colors.onSurfaceVariant,
      unselectedLabelColor: colors.onSurfaceVariant,
      textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            decoration: TextDecoration.none,
          ),
      selectedLabelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colors.primary,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w600,
          ),
      unselectedLabelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colors.onSurfaceVariant,
            decoration: TextDecoration.none,
          ),
      horizontalPadding: 24,
      verticalPadding: 12,
      barHeight: 62,
      tabs: const [
        GlassTab(icon: Icon(Icons.home_outlined), label: '探索'),
        GlassTab(icon: Icon(Icons.search), label: '搜索'),
        GlassTab(icon: Icon(Icons.music_note), label: '乐库'),
        GlassTab(icon: Icon(Icons.person_outline), label: '我的'),
      ],
    );
  }
}
