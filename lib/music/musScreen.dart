import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_lyric/lyric_ui/lyric_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transientmobile/components/music/comPlaySeek.dart';
import 'package:transientmobile/music/newlyricScreen.dart';
import 'package:transientmobile/service/play_list_controller.dart';
import 'package:transientmobile/utils/NetImage.dart';
import '../components/music/comControl.dart';
import '../hooks/useStore.dart';
import '../service/audioHandlerService.dart';
import '../store/index.dart';
import 'package:flutter/material.dart';

// music 音乐主控
class MusScreen extends ConsumerWidget {
  MusScreen({super.key,this.onImageTap});
  VoidCallback? onImageTap;
  final _audioHandler = AudioHandlerService.instance.handler;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musPStore = useSelector(ref, musPlayProvider, (s) => s);
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // MediaItem display
          Expanded(
            child: StreamBuilder<MediaItem?>(
              stream: _audioHandler.mediaItem,
              builder: (context, snapshot) {
                final mediaItem = musPStore.curSong;
                if (mediaItem == null) return const SizedBox();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (mediaItem.artUri != null)
                      GestureDetector(
                        onTap: (){
                          onImageTap?.call();
                        },
                        child: SizedBox(
                          height: MediaQuery.of(context).size.width - 20,
                          // height: 150,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: NetImage(
                                  url: mediaItem.artUri.toString(),
                                  cache: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mediaItem.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(mediaItem.artist ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1),
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
                    SizedBox(height: 20,),
                    SizedBox(
                      child: NewLyricScreen(
                        lycTextAlign: LyricAlign.CENTER,
                        size: Size(double.infinity, 60),
                        hideSkipPlay: true,
                        defaultSize: 18,
                        lineGap: 15,
                        defaultExtSize: 13,
                      ),
                      height: 60,
                    )
                  ],
                );
              },
            ),
          ),
          // short Lyric
          // A seek bar.
          Column(
            children: [
              ComMusSeek(audioHandler: _audioHandler),
              const SizedBox(height: 8.0),
              // Playback controls
              ComControlBtn(
                _audioHandler,
                openPlayList: () {
                  GlobalBottomSheet.show(context: context);
                },
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
