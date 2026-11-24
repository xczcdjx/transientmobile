import 'package:flutter/material.dart';
import '../../styles/theme_palette.dart';

class SettingState {
  const SettingState({
    this.themeMode = ThemeMode.system,
    this.themeColor = defaultThemeColor,
    this.customColor = defaultThemeColor,
    this.isCustomColor = false,
  });
  final ThemeMode themeMode;
  final Color themeColor;
  final Color customColor;
  final bool isCustomColor;

  SettingState copyWith(
          {ThemeMode? themeMode,
          Color? themeColor,
          Color? customColor,
          bool? isCustomColor}) =>
      SettingState(
        themeMode: themeMode ?? this.themeMode,
        themeColor: themeColor ?? this.themeColor,
        customColor: customColor ?? this.customColor,
        isCustomColor: isCustomColor ?? this.isCustomColor,
      );
}
