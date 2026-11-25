import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router/routes.dart';
import '../../widgets/langSwitch.dart';
import '../../widgets/themeSwitch.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Transient'),
          actions: [ThemeSwitch(), LangSwitch(), const SizedBox(width: 12)]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('你的音乐空间',
                        style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Text('让喜欢的旋律，\n陪你片刻。',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                                fontWeight: FontWeight.w700, height: 1.3)),
                    const SizedBox(height: 28),
                    Card(
                        child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => context.push(Routes.lastUpload),
                      child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                      color: colors.primary
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(18)),
                                  child: Icon(Icons.library_music_outlined,
                                      color: colors.primary, size: 30)),
                              const SizedBox(height: 28),
                              Text('最近上传',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text('浏览新加入的歌曲，找到下一首喜欢。',
                                  style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      height: 1.6)),
                              const SizedBox(height: 20),
                              Row(children: [
                                Text('探索音乐',
                                    style: TextStyle(
                                        color: colors.primary,
                                        fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Icon(Icons.arrow_forward_rounded,
                                    color: colors.primary)
                              ]),
                            ],
                          )),
                    )),
                    const SizedBox(height: 24),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.headphones_outlined,
                              color: colors.onSurfaceVariant, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text('选择歌曲后，可随时通过底部播放器继续收听。',
                                  style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      height: 1.6))),
                        ]),
                  ]),
            )),
      ),
    );
  }
}
