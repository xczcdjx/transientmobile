import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/routes.dart';

/// Opens the same theme settings from the home toolbar and personal page.
class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});
  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: '主题设置',
        icon: const Icon(Icons.palette_outlined),
        onPressed: () => context.push(Routes.themeSettings),
      );
}
