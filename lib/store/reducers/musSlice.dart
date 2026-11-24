part of '../index.dart';

/// UI projection only. Background lyric work belongs to AudioHandlerService.
class MusSlice extends StateNotifier<MusicState> {
  MusSlice() : super(AudioHandlerService.instance.lyrics.state.value) {
    _subscription = AudioHandlerService.instance.lyrics.state.listen((value) {
      state = value;
    });
  }

  late final StreamSubscription<MusicState> _subscription;
  LrcParser? get lrc => AudioHandlerService.instance.lyrics.parser;
  List<Map<String, dynamic>> get lines => lrc?.lines ?? const [];

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
