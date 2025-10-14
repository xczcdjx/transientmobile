part of '../index.dart';

class MusSlice extends StateNotifier<MusicState> {
  MusSlice() : super(const MusicState());

  void updatePosition(Duration pos) {
    state = state.copyWith(position: pos);
  }

  void updateBuffered(Duration buf) {
    state = state.copyWith(bufferedPosition: buf);
  }

  void updateDuration(Duration dur) {
    state = state.copyWith(duration: dur);
  }

  void reset() {
    state = const MusicState();
  }
}

