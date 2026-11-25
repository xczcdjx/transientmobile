import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router/routes.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.blur_on),
            title: const Text('液态玻璃测试'),
            subtitle: const Text('按钮、滑块与玻璃面板效果'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.liquidGlassTest),
          ),
          ListTile(
            leading: Icon(Icons.account_circle_rounded),
            title: Text("My test"),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('主题设置'),
            subtitle: const Text('外观模式与主题色'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.themeSettings),
          ),
        ],
      ),
    );
  }
}
