library store;
import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:transientmobile/constants/musTest.dart';
import 'package:transientmobile/models/store/music_state.dart';
import 'package:transientmobile/models/store/setting_state.dart';
import 'package:transientmobile/utils/shareStorage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 实体类导入
import 'package:transientmobile/models/store/count_state.dart';
import 'package:transientmobile/models/store/num_state.dart';
import 'package:transientmobile/models/store/mus_play_state.dart';

import '../constants/testData.dart';
import '../service/audioHandlerService.dart';
import '../utils/AudioHandler.dart';
import '../utils/musFun.dart';
// reducers
part  'reducers/countSlice.dart';
part  'reducers/numSlice.dart';
part  'reducers/settingSlice.dart';
part  'reducers/musSlice.dart';
part  'reducers/musPlaySlice.dart';

// 基数据类型
final counterProvider = StateNotifierProvider<CounterSlice, CountState>((ref) => CounterSlice());
final numProvider = StateNotifierProvider<NumSlice, NumState>((ref) => NumSlice());
final settingProvider = StateNotifierProvider<SettingSlice, SettingState>((ref) => SettingSlice());
final musProvider = StateNotifierProvider<MusSlice, MusicState>((ref) => MusSlice(ref));
final musPlayProvider = StateNotifierProvider<MusPlaySlice, MusPlayState>((ref) {
 return MusPlaySlice(AudioHandlerService.instance.handler);
});
/*final localeProvider = StateProvider<Locale>((ref) {
  // 默认用英文，可以从本地存储恢复
  return const Locale('en');
});*/

