import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../hooks/useStore.dart';
import '../../music/common.dart';
import '../../store/index.dart';
import '../../utils/AudioHandler.dart';

/*class ControlButtons extends ConsumerWidget {
  final AudioPlayerHandlerImpl audioHandler;

  const ControlButtons(this.audioHandler, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              value: audioHandler.volume.value,
              stream: audioHandler.volume,
              onChanged: audioHandler.setVolume,
            );
          },
        ),
        StreamBuilder<QueueState>(
          stream: audioHandler.queueState,
          builder: (context, snapshot) {
            final queueState = snapshot.data ?? QueueState.empty;
            return IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed:
                  queueState.hasPrevious ? audioHandler.skipToPrevious : null,
            );
          },
        ),
        StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, snapshot) {
            final playbackState = snapshot.data;
            final processingState = playbackState?.processingState;
            final playing = playbackState?.playing;
            if (processingState == AudioProcessingState.loading ||
                processingState == AudioProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: audioHandler.play,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: audioHandler.pause,
              );
            }
          },
        ),
        StreamBuilder<QueueState>(
          stream: audioHandler.queueState,
          builder: (context, snapshot) {
            final queueState = snapshot.data ?? QueueState.empty;
            return IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: queueState.hasNext ? audioHandler.skipToNext : null,
            );
          },
        ),
        StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, snapshot) {
            final queueState = snapshot.data ?? QueueState.empty;
            return IconButton(
              icon: const Icon(Icons.stop),
              onPressed: audioHandler.stop,
            );
          },
        ),
        StreamBuilder<double>(
          stream: audioHandler.speed,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(2)}x",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 6,
                min: 0.5,
                max: 2,
                value: audioHandler.speed.value,
                stream: audioHandler.speed,
                onChanged: audioHandler.setSpeed,
              );
            },
          ),
        ),
      ],
    );
  }
}*/

class ComControlBtn extends ConsumerWidget {
  final AudioPlayerHandlerImpl audioHandler;
  final VoidCallback? openPlayList;
  MainAxisAlignment mainAxisAlignment;

  ComControlBtn(this.audioHandler,
      {Key? key,
      this.openPlayList,
      this.mainAxisAlignment = MainAxisAlignment.spaceBetween})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final musPStore = useSelector(ref, musPlayProvider, (s) => s);
    final dispatch = useDispatch(ref, musPlayProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          StreamBuilder<AudioServiceRepeatMode>(
            stream: audioHandler.playbackState
                .map((state) => state.repeatMode)
                .distinct(),
            builder: (context, snapshot) {
              final repeatMode = snapshot.data ?? AudioServiceRepeatMode.none;
              const icons = [
                Icon(Icons.repeat, color: Colors.grey, size: 30),
                Icon(Icons.repeat, color: Colors.orange, size: 30),
                Icon(Icons.repeat_one, color: Colors.orange, size: 30),
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
                  audioHandler.setRepeatMode(cycleModes[
                      (cycleModes.indexOf(repeatMode) + 1) %
                          cycleModes.length]);
                },
              );
            },
          ),
          IconButton(
              icon: const Icon(
                Icons.skip_previous,
                size: 32,
              ),
              onPressed: dispatch.previous),
          StreamBuilder<PlaybackState>(
            stream: audioHandler.playbackState,
            builder: (context, snapshot) {
              final playbackState = snapshot.data;
              final processingState = playbackState?.processingState;
              final playing = playbackState?.playing;
              if (processingState == AudioProcessingState.loading ||
                  processingState == AudioProcessingState.buffering) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  width: 64.0,
                  height: 64.0,
                  child: const CircularProgressIndicator(),
                );
              } else if (playing != true) {
                return IconButton(
                  icon: const Icon(Icons.play_arrow),
                  iconSize: 64.0,
                  onPressed: (){
                    dispatch.play();
                  },
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.pause),
                  iconSize: 64.0,
                  onPressed: (){
                    dispatch.pause();
                  },
                );
              }
            },
          ),
          IconButton(
              icon: const Icon(
                Icons.skip_next,
                size: 32,
              ),
              onPressed: dispatch.next),
          IconButton(
              onPressed: openPlayList,
              icon: Icon(
                Icons.queue_music_sharp,
                size: 32,
              ))
        ],
      ),
    );
  }
}


class ComPlayCircleBtn extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final VoidCallback onPlayPause;

  const ComPlayCircleBtn({
    Key? key,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.onPlayPause,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progress = (duration.inMilliseconds == 0)
        ? 0
        : position.inMilliseconds / duration.inMilliseconds;

    return GestureDetector(
      onTap: onPlayPause,
      child: SizedBox(
        width: 35,
        height: 35,
        child: CustomPaint(
          painter: _CircleProgressPainter(
            progress: progress.clamp(0.0, 1.0),
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Center(
            child: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircleProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final Paint fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        sweepAngle, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

