import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/http.dart';
import '../api/url.dart';
import '../models/req/lyric_entity.dart';
import '../store/index.dart';
import '../utils/AudioHandler.dart';
import '../utils/media_artwork.dart';
import 'audio_lyrics_controller.dart';

class AudioHandlerService {
  static final AudioHandlerService instance = AudioHandlerService._internal();
  AudioHandlerService._internal();

  AudioPlayerHandlerImpl? _handler;
  AudioLyricsController? _lyrics;
  Future<void>? _initialization;
  ProviderSubscription<List<MediaItem>>? _queueSubscription;

  AudioPlayerHandlerImpl get handler =>
      _handler ??
      (throw StateError('AudioHandlerService.init must complete first'));
  AudioLyricsController get lyrics =>
      _lyrics ??
      (throw StateError('AudioHandlerService.init must complete first'));

  /// Concurrent callers share initialization and never create a second player.
  Future<void> init(ProviderContainer container) =>
      _initialization ??= _initialize(container);

  Future<void> _initialize(ProviderContainer container) async {
    _handler = await AudioService.init(
      builder: () => AudioPlayerHandlerImpl(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationIcon: 'drawable/transient_notification_music',
        androidNotificationOngoing: true,
        androidResumeOnClick: true,
        androidShowNotificationBadge: true,
      ),
    );
    _lyrics = AudioLyricsController(
      mediaItems: handler.currentItemStream,
      positions: handler.positionStream,
      playbackStates: handler.playbackState,
      loadLyrics: (id) async {
        final response = await Http().get<Map<String, dynamic>>(
            ExploreU.lycdetail,
            queryParameters: {'musId': id});
        final data = response.data?['data'];
        if (data is! Map<String, dynamic>) return '';
        return LyricEntity.fromJson(data).lyric?.lyric ?? '';
      },
      publishLine: handler.updateNotificationLyric,
    );
    final slice = container.read(musPlayProvider.notifier);
    handler.resolveCurrentItem = () => slice.curMedia;
    await slice.restorePlayback();
    _queueSubscription = container.listen<List<MediaItem>>(
      musPlayProvider.select((value) => value.playList),
      (_, items) =>
          handler.queue.add(List.unmodifiable(items.map(withArtworkHeaders))),
      fireImmediately: true,
    );
    // Keep the UI projection alive; lyric ownership remains in this service.
    container.read(musProvider);
  }

  Future<void> dispose() async {
    await _initialization;
    _queueSubscription?.close();
    _queueSubscription = null;
    await _lyrics?.dispose();
    await _handler?.dispose();
    _lyrics = null;
    _handler = null;
    _initialization = null;
  }
}
