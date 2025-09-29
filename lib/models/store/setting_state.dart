import 'package:flutter/material.dart';

class SettingState {
  final ThemeMode themeMode;

  SettingState({this.themeMode = ThemeMode.system});
  SettingState copyWith({ThemeMode? themeMode}) {
    return SettingState(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
