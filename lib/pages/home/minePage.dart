import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router/routes.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar:
          AppBar(title: const Text('我的'), backgroundColor: Colors.transparent),
      body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          children: [
            Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [
                          CircleAvatar(
                              radius: 30,
                              backgroundColor:
                                  colors.primary.withValues(alpha: 0.12),
                              child: Icon(Icons.headphones_rounded,
                                  color: colors.primary, size: 30)),
                          const SizedBox(width: 18),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('随心听，慢慢发现',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text('把音乐调成你喜欢的样子',
                                    style: TextStyle(
                                        color: colors.onSurfaceVariant)),
                              ])),
                        ]),
                        const SizedBox(height: 32),
                        Text('个性化',
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 12),
                        Card(
                            child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          leading: Icon(Icons.palette_outlined,
                              color: colors.primary),
                          title: const Text('主题设置'),
                          subtitle: const Text('外观模式与主题色'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(Routes.themeSettings),
                        )),
                        const SizedBox(height: 28),
                        Text('实验室',
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 12),
                        Card(
                            child: Column(children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            leading: Icon(Icons.blur_on, color: colors.primary),
                            title: const Text('液态玻璃测试'),
                            subtitle: const Text('对比画质与交互效果'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push(Routes.liquidGlassTest),
                          ),
                          const Divider(height: 1, indent: 20, endIndent: 20),
                          ListTile(
                              leading: const Icon(Icons.science_outlined),
                              title: const Text('其他演示'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push(Routes.test2)),
                        ])),
                      ]),
                )),
          ]),
    );
  }
}
