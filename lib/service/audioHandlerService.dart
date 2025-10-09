import 'package:audio_service/audio_service.dart';
import '../utils/AudioHandler.dart';

class AudioHandlerService {
  static final AudioHandlerService instance = AudioHandlerService._internal();
  late final AudioPlayerHandler _handler;

  AudioHandlerService._internal();

  Future<void> init() async {
    _handler = await AudioService.init(
      builder: () => AudioPlayerHandlerImpl(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.transientmobile.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
      ),
    );
  }

  AudioPlayerHandler get handler => _handler;
}
