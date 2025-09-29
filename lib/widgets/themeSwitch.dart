import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../hooks/useStore.dart';
import '../store/index.dart';

class ThemeCls {
  int index;
  String label;
  IconData icon;

  ThemeCls(this.index, this.label, this.icon);
}

class ThemeSwitch extends ConsumerStatefulWidget {
  const ThemeSwitch({super.key});

  @override
  ConsumerState<ThemeSwitch> createState() => _ThemeSwitch();
}

class _ThemeSwitch extends ConsumerState<ThemeSwitch> {
  final List<ThemeCls> tModes = [
    ThemeCls(0, "跟随系统", Icons.settings),
    ThemeCls(1, "明亮", Icons.light_mode),
    ThemeCls(2, "暗黑", Icons.dark_mode),
  ];

// 切换语言并保存到本地
  // 切换主题并保存到本地
  Future<void> changeTheme(int? i) async {
    if (i == null) return;
    final dispatch = useDispatch(ref, settingProvider);
    dispatch.toggleTheme(i);
  }

  @override
  Widget build(BuildContext context) {
    final curThemeMode = useSelector(ref, settingProvider, (s) => s.themeMode);
    final curThemeModeIndex = themeModeToIndex(curThemeMode);
    // 当前主题对象
    final currentTheme = tModes.firstWhere(
      (t) => t.index == curThemeModeIndex,
      orElse: () => tModes[0],
    );
    return GestureDetector(
      onTapDown: (details) async {
        final selected = await showMenu<int>(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          // color: const Color(0xFF001F3F),
          items: tModes.map((entry) {
            return PopupMenuItem<int>(
                value: entry.index,
                child: Row(children: [
                  Icon(
                    entry.icon,
                    color:
                        entry.index == currentTheme.index ? Colors.red : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.label,
                    style: TextStyle(
                      color: entry.index == currentTheme.index
                          ? Colors.red
                          : null,
                    ),
                  ),
                ]));
          }).toList(),
        );
        await changeTheme(selected);
      },
      child: Icon(
        currentTheme.icon,
      ),
    );
  }
}
int themeModeToIndex(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.system:
      return 0;
    case ThemeMode.light:
      return 1;
    case ThemeMode.dark:
      return 2;
  }
}
