import 'package:flutter/material.dart';
import '../../styles/app_glass.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Isolated visual playground: controls here do not change actual playback.
class LiquidGlassTestPage extends StatefulWidget {
  const LiquidGlassTestPage({super.key});

  @override
  State<LiquidGlassTestPage> createState() => _LiquidGlassTestPageState();
}

class _LiquidGlassTestPageState extends State<LiquidGlassTestPage> {
  late final Future<void> _ready = AppGlass.initialize();
  GlassQuality _quality = GlassQuality.standard;
  bool _playing = false;
  bool _enabled = true;
  bool _warm = false;
  double _progress = 0.35;
  final _selectedTab = ValueNotifier<int>(0);
  static const _tabNames = ['发现', '音乐', '收藏', '我的'];

  @override
  void dispose() {
    _selectedTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('液态玻璃测试')),
      body: FutureBuilder<void>(
        future: _ready,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(24),
              child: SelectableText('玻璃效果初始化失败\n${snapshot.error}'),
            ));
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(children: [
            Positioned.fill(
                child: DecoratedBox(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _warm
                    ? const [
                        Color(0xFF57294F),
                        Color(0xFFDD7852),
                        Color(0xFFEDC78C)
                      ]
                    : const [
                        Color(0xFF112747),
                        Color(0xFF5C56AD),
                        Color(0xFF47A6AC)
                      ],
              )),
            )),
            Positioned(
                top: 70, right: -35, child: _orb(const Color(0xFFFFB7D8), 220)),
            Positioned(
                bottom: 30,
                left: -70,
                child: _orb(const Color(0xFF83E8DA), 260)),
            Positioned.fill(
                child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  24, 24, 24, 140 + MediaQuery.paddingOf(context).bottom),
              child: Center(
                  child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('GLASS LAB',
                          style: TextStyle(
                              color: Colors.white70, letterSpacing: 4)),
                      const SizedBox(height: 12),
                      const Text('让光线穿过音乐',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('拖动滑块、点击按钮，观察玻璃的高光与交互变化。',
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<int>(
                        valueListenable: _selectedTab,
                        builder: (context, index, _) => Text(
                          '正在预览：${_tabNames[index]}',
                          key: const ValueKey('glass-tab-preview'),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassContainer(
                        quality: _quality,
                        padding: const EdgeInsets.all(24),
                        child: Column(children: [
                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(colors: [
                                Color(0xFFDB90BD),
                                Color(0xFF6169D0)
                              ]),
                            ),
                            child: const Icon(Icons.graphic_eq,
                                size: 58, color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          const Text('Transient · 光影之间',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          const Text('播放器外观预览 · 不播放音频'),
                          const SizedBox(height: 24),
                          GlassSlider(
                            quality: _quality,
                            value: _progress,
                            onChanged: (value) =>
                                setState(() => _progress = value),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_time((_progress * 240).round())),
                                const Text('4:00'),
                              ]),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GlassButton(
                                icon: const Icon(Icons.skip_previous),
                                quality: _quality,
                                onTap: () => setState(() => _progress = 0)),
                            const SizedBox(width: 24),
                            GlassButton(
                                icon: Icon(
                                    _playing ? Icons.pause : Icons.play_arrow),
                                label: _playing ? '暂停' : '播放',
                                quality: _quality,
                                width: 76,
                                height: 76,
                                iconSize: 36,
                                onTap: () =>
                                    setState(() => _playing = !_playing)),
                            const SizedBox(width: 24),
                            GlassButton(
                                icon: const Icon(Icons.skip_next),
                                quality: _quality,
                                onTap: () => setState(() => _progress = 1)),
                          ]),
                      const SizedBox(height: 28),
                      Card(
                          child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('效果对比',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              DropdownButton<GlassQuality>(
                                isExpanded: true,
                                value: _quality,
                                items: const [
                                  DropdownMenuItem(
                                      value: GlassQuality.minimal,
                                      child: Text('基础 · 无自定义着色器')),
                                  DropdownMenuItem(
                                      value: GlassQuality.standard,
                                      child: Text('标准 · 轻量玻璃')),
                                  DropdownMenuItem(
                                      value: GlassQuality.premium,
                                      child: Text('高质量 · 支持时使用折射')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _quality = value);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('玻璃开关'),
                                    GlassSwitch(
                                        value: _enabled,
                                        quality: _quality,
                                        onChanged: (value) =>
                                            setState(() => _enabled = value)),
                                  ]),
                              SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('暖色背景'),
                                  value: _warm,
                                  onChanged: (value) =>
                                      setState(() => _warm = value)),
                            ]),
                      )),
                    ]),
              )),
            )),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: ValueListenableBuilder<int>(
                    valueListenable: _selectedTab,
                    builder: (context, index, _) => GlassTabBar.bottom(
                      selectedIndex: index,
                      onTabSelected: (value) => _selectedTab.value = value,
                      quality: _quality,
                      backgroundQuality: _quality,
                      selectedIconColor: Colors.white,
                      selectedLabelColor: Colors.white,
                      unselectedIconColor: Colors.white70,
                      unselectedLabelColor: Colors.white70,
                      tabs: const [
                        GlassTab(
                            icon: Icon(Icons.explore_outlined), label: '发现'),
                        GlassTab(
                            icon: Icon(Icons.music_note_outlined), label: '音乐'),
                        GlassTab(
                            icon: Icon(Icons.favorite_border), label: '收藏'),
                        GlassTab(icon: Icon(Icons.person_outline), label: '我的'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  String _time(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  Widget _orb(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: color.withValues(alpha: 0.55)),
      );
}
