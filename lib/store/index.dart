library store;

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:transientmobile/models/store/music_state.dart';
import 'package:transientmobile/models/store/setting_state.dart';
import '../utils/settings_storage.dart';
import '../utils/playback_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 实体类导入
import 'package:transientmobile/models/store/mus_play_state.dart';

import '../service/audioHandlerService.dart';
import '../utils/AudioHandler.dart';
import '../utils/musFun.dart';
// reducers
part 'reducers/settingSlice.dart';
part 'reducers/musSlice.dart';
part 'reducers/musPlaySlice.dart';

// 基数据类型
final settingProvider =
    StateNotifierProvider<SettingSlice, SettingState>((ref) => SettingSlice());
final musProvider =
    StateNotifierProvider<MusSlice, MusicState>((ref) => MusSlice());
final musPlayProvider =
    StateNotifierProvider<MusPlaySlice, MusPlayState>((ref) {
  return MusPlaySlice(AudioHandlerService.instance.handler);
});
/*final localeProvider = StateProvider<Locale>((ref) {
  // 默认用英文，可以从本地存储恢复
  return const Locale('en');
});*/
