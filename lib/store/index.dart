library store;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:transientmobile/models/store/setting_state.dart';
import 'package:transientmobile/utils/shareStorage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 实体类导入
import 'package:transientmobile/models/store/count_state.dart';
import 'package:transientmobile/models/store/num_state.dart';
// reducers
part  'reducers/countSlice.dart';
part  'reducers/numSlice.dart';
part  'reducers/settingSlice.dart';

// 基数据类型
final counterProvider = StateNotifierProvider<CounterSlice, CountState>((ref) => CounterSlice());
final numProvider = StateNotifierProvider<NumSlice, NumState>((ref) => NumSlice());
final settingProvider = StateNotifierProvider<SettingSlice, SettingState>((ref) => SettingSlice());
/*final localeProvider = StateProvider<Locale>((ref) {
  // 默认用英文，可以从本地存储恢复
  return const Locale('en');
});*/

