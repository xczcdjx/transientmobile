import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:go_router/go_router.dart';
import 'package:transientmobile/components/music/comPlaySeek.dart';
import 'package:transientmobile/extensions/customColors.dart';
import 'package:transientmobile/utils/NetImage.dart';
import '../components/music/comControl.dart';
import '../service/audioHandlerService.dart';
import '../utils/AudioHandler.dart';
import 'common.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// The main screen.
class MusScreen extends StatelessWidget {
  MusScreen({super.key});

  final _audioHandler = AudioHandlerService.instance.handler;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // MediaItem display
          Expanded(
            child: StreamBuilder<MediaItem?>(
              stream: _audioHandler.mediaItem,
              builder: (context, snapshot) {
                final mediaItem = snapshot.data;
                if (mediaItem == null) return const SizedBox();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (mediaItem.artUri != null)
                      SizedBox(
                        height: MediaQuery.of(context).size.width-20,
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
                                  mediaItem.album ?? '',
                                  style: Theme.of(context).textTheme.titleLarge,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(mediaItem.title,
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
                    )
                  ],
                );
              },
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
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    // 内容超出时可全屏
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) {
                      return // Playlist
                          SizedBox(
                        height: 240.0,
                        child: StreamBuilder<QueueState>(
                          stream: _audioHandler.queueState,
                          builder: (context, snapshot) {
                            final queueState =
                                snapshot.data ?? QueueState.empty;
                            final queue = queueState.queue;
                            return ReorderableListView(
                              onReorder: (int oldIndex, int newIndex) {
                                if (oldIndex < newIndex) newIndex--;
                                _audioHandler.moveQueueItem(oldIndex, newIndex);
                              },
                              children: [
                                for (var i = 0; i < queue.length; i++)
                                  Dismissible(
                                    key: ValueKey(queue[i].id),
                                    background: Container(
                                      color: Colors.redAccent,
                                      alignment: Alignment.centerRight,
                                      child: const Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Icon(Icons.delete,
                                            color: Colors.white),
                                      ),
                                    ),
                                    onDismissed: (dismissDirection) {
                                      _audioHandler.removeQueueItemAt(i);
                                    },
                                    child: Material(
                                      color: i == queueState.queueIndex
                                          ? context.bg
                                          : null,
                                      child: ListTile(
                                        title: Text(queue[i].title,style: TextStyle(color: i == queueState.queueIndex
                                            ? context.pc
                                            : null),),
                                        onTap: () =>
                                            _audioHandler.skipToQueueItem(i),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  );
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
