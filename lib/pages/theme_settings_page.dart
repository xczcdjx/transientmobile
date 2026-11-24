import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../store/index.dart';
import '../styles/theme_palette.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingProvider);
    final actions = ref.read(settingProvider.notifier);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = settings.themeColor;
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      appBar: AppBar(title: const Text('主题设置')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              const Text('为你的音乐空间，添一点喜欢的色彩',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 30),
              const _SectionTitle('外观'),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                    color: surface, borderRadius: BorderRadius.circular(22)),
                child: Column(children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    secondary: Icon(dark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined),
                    title: const Text('暗黑模式'),
                    subtitle: Text('当前为${dark ? '深色' : '浅色'}主题'),
                    value: dark,
                    onChanged: (value) => actions.toggleTheme(
                        (value ? ThemeMode.dark : ThemeMode.light).index),
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  CheckboxListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: const Text('跟随系统', style: TextStyle(fontSize: 14)),
                    value: settings.themeMode == ThemeMode.system,
                    onChanged: (value) => actions.toggleTheme((value == true
                            ? ThemeMode.system
                            : dark
                                ? ThemeMode.dark
                                : ThemeMode.light)
                        .index),
                  ),
                ]),
              ),
              const SizedBox(height: 30),
              const _SectionTitle('主题色'),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: surface, borderRadius: BorderRadius.circular(22)),
                child: Column(children: [
                  LayoutBuilder(builder: (context, constraints) {
                    final oneColumn = constraints.maxWidth < 280 ||
                        MediaQuery.textScalerOf(context).scale(1) > 1.4;
                    final width = oneColumn
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 12) / 2;
                    return Wrap(spacing: 12, runSpacing: 12, children: [
                      for (final preset in themePresets)
                        SizedBox(
                            width: width,
                            child: _ColorTile(
                              name: preset.name,
                              color: preset.color,
                              accent: accent,
                              selected: !settings.isCustomColor &&
                                  settings.themeColor == preset.color,
                              onTap: () => actions.setThemeColor(preset.color),
                            )),
                      SizedBox(
                          width: width,
                          child: _ColorTile(
                            name: '自定义',
                            color: settings.customColor,
                            accent: accent,
                            custom: true,
                            selected: settings.isCustomColor,
                            onTap: () async {
                              final color = await showDialog<Color>(
                                  context: context,
                                  builder: (_) => _CustomColorDialog(
                                      initial: settings.customColor));
                              if (color != null) {
                                await actions.setThemeColor(color,
                                    custom: true);
                              }
                            },
                          )),
                    ]);
                  }),
                  const Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 14),
                      child: Divider(height: 1)),
                  const Text('更改主题色后，应用中的强调色将随之变化，设置自动保存',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey, height: 1.6)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w600));
}

class _ColorTile extends StatelessWidget {
  const _ColorTile(
      {required this.name,
      required this.color,
      required this.accent,
      required this.selected,
      required this.onTap,
      this.custom = false});
  final String name;
  final Color color;
  final Color accent;
  final bool selected;
  final bool custom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      child: Material(
        color: selected ? accent.withOpacity(0.14) : background,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: selected ? accent : Colors.transparent, width: 1.5)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
            child: Row(children: [
              Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: custom && !selected ? null : color,
                    gradient: custom && !selected
                        ? const SweepGradient(colors: [
                            Colors.red,
                            Colors.yellow,
                            Colors.green,
                            Colors.cyan,
                            Colors.blue,
                            Colors.purple,
                            Colors.red
                          ])
                        : null,
                    border: Border.all(color: Colors.white.withOpacity(0.35))),
                child: selected
                    ? Icon(Icons.check,
                        size: 17,
                        color: ThemeData.estimateBrightnessForColor(color) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black87)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(name, style: const TextStyle(fontSize: 14))),
            ]),
          ),
        ),
      ),
    );
  }
}

class _CustomColorDialog extends StatefulWidget {
  const _CustomColorDialog({required this.initial});
  final Color initial;
  @override
  State<_CustomColorDialog> createState() => _CustomColorDialogState();
}

class _CustomColorDialogState extends State<_CustomColorDialog> {
  late HSVColor _color;
  late TextEditingController _hex;
  String? _error;
  String _format(Color color) =>
      color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
  @override
  void initState() {
    super.initState();
    _color = HSVColor.fromColor(widget.initial);
    _hex = TextEditingController(text: _format(widget.initial));
  }

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  void _adjust(HSVColor color) {
    setState(() {
      _color = color;
      _hex.text = _format(color.toColor());
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('自定义主题色'),
        content: SizedBox(
            width: 320,
            child: SingleChildScrollView(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    height: 64,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: _color.toColor(),
                        borderRadius: BorderRadius.circular(14))),
                const SizedBox(height: 20),
                TextField(
                  controller: _hex,
                  maxLength: 7,
                  decoration: InputDecoration(
                      labelText: '颜色值',
                      prefixText: '#',
                      hintText: '例如 25B9C7',
                      errorText: _error,
                      counterText: ''),
                  onChanged: (text) {
                    final value = text.trim().replaceFirst(RegExp(r'^#'), '');
                    if (RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(value)) {
                      setState(() {
                        _color = HSVColor.fromColor(
                            Color(0xFF000000 | int.parse(value, radix: 16)));
                        _error = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                _slider('色相', _color.hue / 360,
                    (v) => _adjust(_color.withHue(v * 360))),
                _slider('饱和度', _color.saturation,
                    (v) => _adjust(_color.withSaturation(v))),
                _slider(
                    '明度', _color.value, (v) => _adjust(_color.withValue(v))),
              ],
            ))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
              onPressed: () {
                final value = _hex.text.trim().replaceFirst(RegExp(r'^#'), '');
                if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(value)) {
                  setState(() => _error = '请输入 6 位十六进制颜色值');
                  return;
                }
                Navigator.pop(
                    context, Color(0xFF000000 | int.parse(value, radix: 16)));
              },
              child: const Text('应用')),
        ],
      );

  Widget _slider(String label, double value, ValueChanged<double> onChanged) =>
      Row(children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Expanded(
            child: Slider(
                value: value,
                onChanged: onChanged,
                semanticFormatterCallback: (v) =>
                    '$label ${(v * 100).round()}%'))
      ]);
}
