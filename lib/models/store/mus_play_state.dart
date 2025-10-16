import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

class MusPlayState {
  int curIndex;
  List<MediaItem> playList;
  List<String> randomIdList;
  PlayerState playState;
  bool isPlay;
  AudioServiceRepeatMode mode;

  MusPlayState({
    this.curIndex = 0,
    this.playList = const [],
    this.randomIdList = const [],
    this.playState = PlayerState.disposed,
    this.isPlay = false,
    this.mode = AudioServiceRepeatMode.none,
  });

  MusPlayState copyWith({
    int? curIndex,
    List<MediaItem>? playList,
    List<String>? randomIdList,
    PlayerState? playState,
    bool? isPlay,
    AudioServiceRepeatMode? mode,
  }) {
    return MusPlayState(
      curIndex: curIndex ?? this.curIndex,
      playList: playList ?? this.playList,
      randomIdList: randomIdList ?? this.randomIdList,
      playState: playState ?? this.playState,
      isPlay: isPlay ?? this.isPlay,
      mode: mode ?? this.mode,
    );
  }
}
