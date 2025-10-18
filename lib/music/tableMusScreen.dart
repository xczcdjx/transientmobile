import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:transientmobile/components/images/rotatingAlbumCover.dart';
import 'package:transientmobile/components/music/comPlaySeek.dart';
import 'package:transientmobile/extensions/customColors.dart';
import 'package:transientmobile/music/lyricScreen.dart';
import 'package:transientmobile/utils/NetImage.dart';
import '../components/music/comControl.dart';
import '../hooks/useStore.dart';
import '../service/audioHandlerService.dart';
import '../store/index.dart';
import '../utils/AudioHandler.dart';
import 'package:flutter/material.dart';

/// The main screen.
class TableMusScreen extends ConsumerWidget {
  List<Map<String, dynamic>> lines;

  TableMusScreen({super.key, this.lines = const []});

  final _audioHandler = AudioHandlerService.instance.handler;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musStore = useSelector(ref, musProvider, (s) => s);
    final musPlayStore = useSelector(ref, musPlayProvider, (s) => s);
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: // MediaItem display
                  musPlayStore.curSong == null
                          ? SizedBox()
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final maxWidth = constraints.maxWidth;
                                return RotatingAlbumCover(
                                  imageUrl:
                                      (musPlayStore.curSong?.artUri??"").toString(),
                                  playing: musPlayStore.isPlaying,
                                  size: maxWidth / 2.1,
                                );
                              },
                            ),
                ),
                Flexible(
                  flex: 1,
                  child: LyricScreen(
                    hideControl: true,
                    lines: lines,
                  ),
                ),
              ],
            ),
          ),
          // control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        musPlayStore.curSong?.album ?? 'Xxx',
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(musPlayStore.curSong?.title ?? "xxx",
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                    ],
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Transform.translate(
                    offset: Offset(0, -5),
                    child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.favorite_border,
                          size: 30,
                        )))
              ],
            ),
          ),
          // A seek bar.
          Column(
            children: [
              ComMusSeek(audioHandler: _audioHandler),
              const SizedBox(height: 8.0),
              // Playback controls
              ComControlBtn(
                _audioHandler,
                openPlayList: () {

                },
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              // Repeat/shuffle controls
              Row(
                children: [
                  StreamBuilder<AudioServiceRepeatMode>(
                    stream: _audioHandler.playbackState
                        .map((state) => state.repeatMode)
                        .distinct(),
                    builder: (context, snapshot) {
                      final repeatMode =
                          snapshot.data ?? AudioServiceRepeatMode.none;
                      const icons = [
                        Icon(Icons.repeat, color: Colors.grey),
                        Icon(Icons.repeat, color: Colors.orange),
                        Icon(Icons.repeat_one, color: Colors.orange),
                      ];
                      const cycleModes = [
                        AudioServiceRepeatMode.none,
                        AudioServiceRepeatMode.all,
                        AudioServiceRepeatMode.one,
                      ];
                      final index = cycleModes.indexOf(repeatMode);
                      return IconButton(
                        icon: icons[index],
                        onPressed: () {
                          _audioHandler.setRepeatMode(cycleModes[
                              (cycleModes.indexOf(repeatMode) + 1) %
                                  cycleModes.length]);
                        },
                      );
                    },
                  ),
                  Expanded(
                    child: Text(
                      "Download",
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  StreamBuilder<bool>(
                    stream: _audioHandler.playbackState
                        .map((state) =>
                            state.shuffleMode == AudioServiceShuffleMode.all)
                        .distinct(),
                    builder: (context, snapshot) {
                      final shuffleModeEnabled = snapshot.data ?? false;
                      return IconButton(
                        icon: shuffleModeEnabled
                            ? const Icon(Icons.shuffle, color: Colors.orange)
                            : const Icon(Icons.shuffle, color: Colors.grey),
                        onPressed: () async {
                          final enable = !shuffleModeEnabled;
                          await _audioHandler.setShuffleMode(enable
                              ? AudioServiceShuffleMode.all
                              : AudioServiceShuffleMode.none);
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
