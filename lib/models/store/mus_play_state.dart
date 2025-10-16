import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

class MusPlayState {
  int curIndex;
  List<MediaItem> playList;
  List<String> randomIdList;
  PlayerState playState;
  AudioServiceRepeatMode mode;

  MusPlayState({
    this.curIndex = 0,
    this.playList = const [],
    this.randomIdList = const [],
    this.playState = PlayerState.disposed,
    this.mode = AudioServiceRepeatMode.none,
  });

  MusPlayState copyWith({
    int? curIndex,
    List<MediaItem>? playList,
    List<String>? randomIdList,
    PlayerState? playState,
    AudioServiceRepeatMode? mode,
  }) {
    return MusPlayState(
      curIndex: curIndex ?? this.curIndex,
      playList: playList ?? this.playList,
      randomIdList: randomIdList ?? this.randomIdList,
      playState: playState ?? this.playState,
      mode: mode ?? this.mode,
    );
  }
}
