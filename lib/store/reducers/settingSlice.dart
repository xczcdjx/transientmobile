part of '../index.dart';

class SettingSlice extends StateNotifier<SettingState> {
  static const String key = 'theme_mode';
  static const String colorKey = 'theme_color';
  static const String customColorKey = 'theme_custom_color';
  static const String isCustomKey = 'theme_is_custom';

  SettingSlice() : super(_restore());

  static SettingState _restore() {
    final index = SettingsStorage.get<int>(key) ?? 0;
    Color restoreColor(String storageKey) {
      final value = SettingsStorage.get<int>(storageKey);
      return value != null && value >= 0 && value <= 0xFFFFFFFF
          ? Color(value).withAlpha(255)
          : const Color(0xFF4C8DF6);
    }

    return SettingState(
      themeMode: index >= 0 && index < ThemeMode.values.length
          ? ThemeMode.values[index]
          : ThemeMode.system,
      themeColor: restoreColor(colorKey),
      customColor: restoreColor(customColorKey),
      isCustomColor: SettingsStorage.get<bool>(isCustomKey) ?? false,
    );
  }

  Future<void> toggleTheme(int index) async {
    if (index < 0 || index >= ThemeMode.values.length) return;
    state = state.copyWith(themeMode: ThemeMode.values[index]);
    await SettingsStorage.set(key, index);
  }

  Future<void> setThemeColor(Color color, {bool custom = false}) async {
    final opaque = color.withAlpha(255);
    state = state.copyWith(
        themeColor: opaque,
        isCustomColor: custom,
        customColor: custom ? opaque : null);
    await SettingsStorage.setAll({
      colorKey: opaque.toARGB32(),
      isCustomKey: custom,
      if (custom) customColorKey: opaque.toARGB32(),
    });
  }
}
