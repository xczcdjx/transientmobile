import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveUtil {
  HiveUtil._();

  /// 默认 Box 名称
  static const String defaultBoxName = 'app_storage';

  /// 获取 Box
  static Box<dynamic> getBox([
    String boxName = defaultBoxName,
  ]) {
    return Hive.box<dynamic>(boxName);
  }

  /// 初始化 Hive
  static Future<void> init({
    String boxName = defaultBoxName,
  }) async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();

      Hive.init('${directory.path}/hive');
    }

    await openBox(boxName);
  }

  /// 打开 Box
  static Future<Box<dynamic>> openBox([
    String boxName = defaultBoxName,
  ]) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName);
    }

    return Hive.openBox<dynamic>(boxName);
  }

  /// 判断 Box 是否打开
  static bool isBoxOpen([
    String boxName = defaultBoxName,
  ]) {
    return Hive.isBoxOpen(boxName);
  }

  // ==================== 泛型存储 ====================

  /// 存储任意 Hive 支持的类型
  static Future<void> set<T>(
    String key,
    T value, {
    String boxName = defaultBoxName,
  }) {
    return getBox(boxName).put(key, value);
  }

  /// 读取指定类型
  static T? get<T>(
    String key, {
    T? defaultValue,
    String boxName = defaultBoxName,
  }) {
    if (!isBoxOpen(boxName)) return defaultValue;
    final value = getBox(boxName).get(key);
    return value is T ? value : defaultValue;
  }

  // ==================== 基础类型 ====================

  static Future<void> setInt(String key, int value) {
    return set(key, value);
  }

  static int getInt(String key, {int defaultValue = 0}) {
    return get<int>(key) ?? defaultValue;
  }

  static Future<void> setDouble(String key, double value) {
    return set(key, value);
  }

  static double getDouble(
    String key, {
    double defaultValue = 0.0,
  }) {
    return get<num>(key)?.toDouble() ?? defaultValue;
  }

  static Future<void> setString(String key, String value) {
    return set(key, value);
  }

  static String getString(
    String key, {
    String defaultValue = '',
  }) {
    return get<String>(key) ?? defaultValue;
  }

  static Future<void> setBool(String key, bool value) {
    return set(key, value);
  }

  static bool getBool(
    String key, {
    bool defaultValue = false,
  }) {
    return get<bool>(key) ?? defaultValue;
  }

  // ==================== 字符串列表 ====================

  static Future<void> setStringList(
    String key,
    List<String> value,
  ) {
    return set(key, value);
  }

  static List<String> getStringList(
    String key, {
    List<String> defaultValue = const [],
  }) {
    final value = get<List>(key);

    return value == null
        ? List<String>.of(defaultValue)
        : List<String>.from(value);
  }

  // ==================== Map ====================

  static Future<void> setMap(
    String key,
    Map<String, dynamic> value,
  ) {
    return set(key, value);
  }

  static Map<String, dynamic> getMap(String key) {
    final value = get<dynamic>(key);

    if (value == null || value == '') {
      return {};
    }

    // 兼容旧版本 JSON 字符串
    if (value is String) {
      return Map<String, dynamic>.from(jsonDecode(value));
    }

    return Map<String, dynamic>.from(value as Map);
  }

  // ==================== Model List ====================

  /// 不需要注册 TypeAdapter
  static Future<void> setList<T>(
    String key,
    List<T> items,
    Map<String, dynamic> Function(T) toMap,
  ) {
    final list = items.map(toMap).toList();

    return set(key, list);
  }

  static List<T> getList<T>(
    String key,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    final value = get<dynamic>(key);

    if (value == null) {
      return [];
    }

    // 兼容旧版本 JSON 数据
    final list = value is String ? jsonDecode(value) as List : value as List;

    return list.map((item) {
      return fromMap(Map<String, dynamic>.from(item as Map));
    }).toList();
  }

  // ==================== TypeAdapter ====================

  static Future<void> setObject<T>(
    String key,
    T value,
  ) {
    return set(key, value);
  }

  static T? getObject<T>(String key) {
    return get<T>(key);
  }

  static Future<void> setObjectList<T>(
    String key,
    List<T> list,
  ) {
    return set(key, list);
  }

  static List<T> getObjectList<T>(String key) {
    final list = get<List>(key);

    return list == null ? <T>[] : List<T>.from(list);
  }

  // ==================== 批量操作 ====================

  static Future<void> setAll(
    Map<String, dynamic> entries, {
    String boxName = defaultBoxName,
  }) {
    return getBox(boxName).putAll(entries);
  }

  static Future<void> deleteAll(
    Iterable<String> keys, {
    String boxName = defaultBoxName,
  }) {
    return getBox(boxName).deleteAll(keys);
  }

  static Map<dynamic, dynamic> getAll({
    String boxName = defaultBoxName,
  }) {
    return getBox(boxName).toMap();
  }

  // ==================== 数据管理 ====================

  static bool containsKey(
    String key, {
    String boxName = defaultBoxName,
  }) {
    return getBox(boxName).containsKey(key);
  }

  static Future<bool> deleteKey(
    String key, {
    String boxName = defaultBoxName,
  }) async {
    final box = getBox(boxName);

    await box.delete(key);

    return !box.containsKey(key);
  }

  static Future<void> deleteBox(String boxName) {
    return Hive.deleteBoxFromDisk(boxName);
  }

  static Future<int> clear({
    String boxName = defaultBoxName,
  }) {
    return getBox(boxName).clear();
  }

  static int length({
    String boxName = defaultBoxName,
  }) {
    return getBox(boxName).length;
  }

  static List<dynamic> keys({
    String boxName = defaultBoxName,
  }) {
    return getBox(boxName).keys.toList();
  }

  // ==================== 数据监听 ====================

  static Stream<BoxEvent> watch({
    String? key,
    String boxName = defaultBoxName,
  }) {
    return getBox(boxName).watch(key: key);
  }

  // ==================== 生命周期 ====================

  static Future<void> flush({
    String boxName = defaultBoxName,
  }) {
    return getBox(boxName).flush();
  }

  static Future<void> compact({
    String boxName = defaultBoxName,
  }) {
    return getBox(boxName).compact();
  }

  static Future<void> close({
    String boxName = defaultBoxName,
  }) {
    return getBox(boxName).close();
  }

  static Future<void> closeAll() {
    return Hive.close();
  }
}
