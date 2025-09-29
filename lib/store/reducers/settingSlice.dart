part of '../index.dart';

class SettingSlice extends StateNotifier<SettingState> {
  static const String key = 'theme_mode';
  SettingSlice() : super(SettingState()){
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeIndex = ShareStorage.get(key)??0;
    state = state.copyWith(themeMode: ThemeMode.values[themeIndex]);
  }

  Future<void> toggleTheme(int i) async {
    state = state.copyWith(themeMode: ThemeMode.values[i]);
    await ShareStorage.set(key, i);
  }
}
