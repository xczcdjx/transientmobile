import '../constants/HiveKeys.dart';
import 'HiveUtil.dart';

/// Application preferences, backed by the already-open settings box.
class SettingsStorage {
  SettingsStorage._();
  static T? get<T>(String key, {T? defaultValue}) => HiveUtil.get<T>(key,
      defaultValue: defaultValue, boxName: HiveKeys.settings);
  static Future<void> set<T>(String key, T value) =>
      HiveUtil.set(key, value, boxName: HiveKeys.settings);

  static Future<void> setAll(Map<String, dynamic> values) =>
      HiveUtil.setAll(values, boxName: HiveKeys.settings);

  static String? get languageCode {
    final value = get<String>('locale')?.split(RegExp('[_-]')).first;
    return value == 'en' || value == 'zh' ? value : null;
  }
}
