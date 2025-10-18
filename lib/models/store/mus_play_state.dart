import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

class MusPlayState {
  int curIndex;
  List<MediaItem> playList;
  List<String> randomIdList;
  PlayerState playState;
  bool isPlaying;
  bool isShuffling;
  AudioServiceRepeatMode repeatMode;

  MediaItem? get curSong {
    if (playList.isEmpty || curIndex < 0 || curIndex >= playList.length) {
      return null;
    }
    return playList[curIndex];
  }

  MusPlayState({
    this.curIndex = 0,
    this.playList = const [],
    this.randomIdList = const [],
    this.playState = PlayerState.disposed,
    this.isPlaying = false,
    this.isShuffling = false,
    this.repeatMode = AudioServiceRepeatMode.none,
  });

  MusPlayState copyWith({
    int? curIndex,
    List<MediaItem>? playList,
    List<String>? randomIdList,
    PlayerState? playState,
    bool? isPlaying,
    bool? isShuffling,
    AudioServiceRepeatMode? repeatMode,
  }) {
    return MusPlayState(
      curIndex: curIndex ?? this.curIndex,
      playList: playList ?? this.playList,
      randomIdList: randomIdList ?? this.randomIdList,
      playState: playState ?? this.playState,
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffling: isShuffling ?? this.isShuffling,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }
}
