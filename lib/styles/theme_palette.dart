import 'package:flutter/material.dart';

class ThemePreset {
  const ThemePreset(this.name, this.color);
  final String name;
  final Color color;
}

const themePresets = [
  ThemePreset('碧空如洗', Color(0xFF4C8DF6)),
  ThemePreset('暖阳和煦', Color(0xFFFFA800)),
  ThemePreset('青草微风', Color(0xFF60B348)),
  ThemePreset('湖光潋滟', Color(0xFF25B9C7)),
  ThemePreset('丹枫似火', Color(0xFFF25A3C)),
  ThemePreset('蔷薇之梦', Color(0xFFE74491)),
  ThemePreset('鸢尾之吻', Color(0xFFA77BE8)),
  ThemePreset('孔雀翎羽', Color(0xFF087F8C)),
  ThemePreset('墨色山水', Color(0xFF595B7C)),
  ThemePreset('醇香可可', Color(0xFFA85315)),
  ThemePreset('葡萄美酒', Color(0xFF704575)),
];
const defaultThemeColor = Color(0xFF4C8DF6);
