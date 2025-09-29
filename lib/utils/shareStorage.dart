import 'package:shared_preferences/shared_preferences.dart';

class ShareStorage {
  static SharedPreferences? _prefs;

  /// 初始化，在 main() 里调用一次
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 存储数据，支持常见类型
  static Future<bool> set<T>(String key, T value) async {
    if (_prefs == null) return false;

    if (value is String) {
      return await _prefs!.setString(key, value);
    } else if (value is int) {
      return await _prefs!.setInt(key, value);
    } else if (value is bool) {
      return await _prefs!.setBool(key, value);
    } else if (value is double) {
      return await _prefs!.setDouble(key, value);
    } else if (value is List<String>) {
      return await _prefs!.setStringList(key, value);
    } else {
      throw Exception("不支持的类型: ${value.runtimeType}");
    }
  }

  /// 读取数据，带默认值
  static T? get<T>(String key, {T? defaultValue}) {
    if (_prefs == null) return defaultValue;

    final value = _prefs!.get(key);
    if (value is T) {
      return value;
    }
    return defaultValue;
  }

  /// 删除
  static Future<bool> remove(String key) async {
    if (_prefs == null) return false;
    return await _prefs!.remove(key);
  }

  /// 清空
  static Future<bool> clear() async {
    if (_prefs == null) return false;
    return await _prefs!.clear();
  }
}
