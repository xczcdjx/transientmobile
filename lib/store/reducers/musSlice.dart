part of '../index.dart';
class MusSlice extends StateNotifier<MusicState> {
  MusSlice() : super(MusicState());
  final _audioHandler = AudioHandlerService.instance.handler;
  LrcParser? lrc;

  double _lastLyricUpdate = -1; // 上次更新时间（秒）

  void updatePosition(Duration pos) {
    state = state.copyWith(position: pos);

    // 节流：仅每1秒更新一次歌词
    final sec = pos.inMilliseconds / 1000.0;
    if (lrc == null) return;
    if (sec - _lastLyricUpdate < 1) return; // <1秒就不再更新
    _lastLyricUpdate = sec;

    final l = lrc!.getByTime(sec);
    if (l != null) _audioHandler.updateArtist(l);
  }

  void updateBuffered(Duration buf) {
    state = state.copyWith(bufferedPosition: buf);
    if (state.curPlayMedia != null) {
      final data = lyricDataTest[state.curPlayMedia!.id];
      if (data != null) {
        lrc = LrcParser.from(data);
      }
    }
  }

  void updateDuration(Duration dur) {
    state = state.copyWith(duration: dur);
  }

  void updateMedia(MediaItem media) {
    state = state.copyWith(curPlayMedia: media);
  }

  void reset() {
    state = MusicState();
    _lastLyricUpdate = -1;
    lrc = null;
  }
}
