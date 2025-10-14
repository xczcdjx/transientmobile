import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../store/index.dart';
import '../utils/AudioHandler.dart';

class AudioHandlerService {
  static final AudioHandlerService instance = AudioHandlerService._internal();
  late final AudioPlayerHandler _handler;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _bufSub;
  StreamSubscription<MediaItem?>? _mediaSub;
  StreamSubscription<Duration?>? _durSub;
  AudioHandlerService._internal();

  Future<void> init(ProviderContainer container) async {
    _handler = await AudioService.init(
      builder: () => AudioPlayerHandlerImpl(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.transientmobile.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
      ),
    );
    // ✅ 初始化完毕后监听各个流
    _listenToStreams(container);
  }

  AudioPlayerHandler get handler => _handler;

  void _listenToStreams(ProviderContainer container) {
    final slice = container.read(musProvider.notifier);

    _posSub = _handler.durationStream.listen((pos) {
      print("dur ${pos.toString()}");
      slice.updatePosition(pos);
    });

    _bufSub = _handler.playbackState
        .map((s) => s.bufferedPosition)
        .distinct()
        .listen((buf) {
      slice.updateBuffered(buf);
    });

    _durSub = _handler.mediaItem
        .map((item) => item?.duration)
        .distinct()
        .listen((dur) {
      if (dur != null) slice.updateDuration(dur);
    });
    _mediaSub = _handler.mediaItem
        .listen((media) {
      if (media != null) slice.updateMedia(media);
    });
  }


  Future<void> dispose() async {
    await _posSub?.cancel();
    await _bufSub?.cancel();
    await _durSub?.cancel();
  }
}
