import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../styles/app_glass.dart';
import '../../store/index.dart';
import '../../utils/AudioHandler.dart';

/// Shared by cover, lyrics and wide layouts; transport behavior stays in the store.
class ComControlBtn extends ConsumerWidget {
  const ComControlBtn(
    this.audioHandler, {
    super.key,
    this.openPlayList,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
  });

  final AudioPlayerHandlerImpl audioHandler;
  final VoidCallback? openPlayList;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final accent = colors.primary;
    final dark = colors.brightness == Brightness.dark;
    final ink = dark ? Colors.white : colors.onSurface;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: LayoutBuilder(builder: (context, constraints) {
            final compact = constraints.maxWidth < 340;
            final secondarySize = compact ? 44.0 : 50.0;
            final skipSize = compact ? 52.0 : 58.0;
            final playSize = compact ? 72.0 : 82.0;
            Widget button(
                {required IconData icon,
                required String label,
                required VoidCallback? onTap,
                required double size,
                bool active = false,
                bool secondary = false}) {
              return Tooltip(
                message: label,
                child: GlassButton(
                  icon: Icon(icon),
                  label: label,
                  width: size,
                  height: size,
                  iconSize: secondary ? 23 : 28,
                  iconColor: active ? accent : ink,
                  quality: secondary ? GlassQuality.minimal : AppGlass.quality,
                  enabled: onTap != null,
                  onTap: onTap ?? () {},
                ),
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<AudioServiceRepeatMode>(
                  initialData: audioHandler.playbackState.value.repeatMode,
                  stream: audioHandler.playbackState
                      .map((s) => s.repeatMode)
                      .distinct(),
                  builder: (context, snapshot) {
                    final mode = snapshot.data ?? AudioServiceRepeatMode.none;
                    const cycle = [
                      AudioServiceRepeatMode.none,
                      AudioServiceRepeatMode.all,
                      AudioServiceRepeatMode.one
                    ];
                    final label = switch (mode) {
                      AudioServiceRepeatMode.one => '单曲循环',
                      AudioServiceRepeatMode.all => '列表循环',
                      _ => '顺序播放',
                    };
                    return button(
                      icon: mode == AudioServiceRepeatMode.one
                          ? Icons.repeat_one_rounded
                          : Icons.repeat_rounded,
                      label: label,
                      size: secondarySize,
                      secondary: true,
                      active: mode != AudioServiceRepeatMode.none,
                      onTap: () => audioHandler.setRepeatMode(
                          cycle[(cycle.indexOf(mode) + 1) % cycle.length]),
                    );
                  },
                ),
                button(
                    icon: Icons.skip_previous_rounded,
                    label: '上一首',
                    size: skipSize,
                    onTap: () => ref.read(musPlayProvider.notifier).previous()),
                StreamBuilder<PlaybackState>(
                  initialData: audioHandler.playbackState.value,
                  stream: audioHandler.playbackState,
                  builder: (context, snapshot) {
                    final state = snapshot.data!;
                    final busy = state.processingState ==
                            AudioProcessingState.loading ||
                        state.processingState == AudioProcessingState.buffering;
                    final label = busy
                        ? '正在加载'
                        : state.playing
                            ? '暂停'
                            : '播放';
                    return Tooltip(
                      message: label,
                      child: GlassButton.custom(
                        width: playSize,
                        height: playSize,
                        label: label,
                        enabled: !busy,
                        quality: AppGlass.quality,
                        tintColor: dark
                            ? Colors.white.withValues(alpha: 0.12)
                            : accent.withValues(alpha: 0.08),
                        onTap: () {
                          final actions = ref.read(musPlayProvider.notifier);
                          state.playing ? actions.pause() : actions.play();
                        },
                        child: busy
                            ? SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: ink))
                            : Icon(
                                state.playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 40,
                                color: ink),
                      ),
                    );
                  },
                ),
                button(
                    icon: Icons.skip_next_rounded,
                    label: '下一首',
                    size: skipSize,
                    onTap: () => ref.read(musPlayProvider.notifier).next()),
                button(
                    icon: Icons.queue_music_rounded,
                    label: '播放列表',
                    size: secondarySize,
                    secondary: true,
                    onTap: openPlayList),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class ComPlayCircleBtn extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final double iconSize;
  final double outSize;

  const ComPlayCircleBtn(
      {Key? key,
      required this.position,
      required this.duration,
      required this.isPlaying,
      required this.onPlayPause,
      this.iconSize = 28,
      this.outSize = 35})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progress = (duration.inMilliseconds == 0)
        ? 0
        : position.inMilliseconds / duration.inMilliseconds;

    return GestureDetector(
      onTap: onPlayPause,
      child: SizedBox(
        width: outSize,
        height: outSize,
        child: CustomPaint(
          painter: _CircleProgressPainter(
            progress: progress.clamp(0.0, 1.0),
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Center(
            child: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              size: iconSize,
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
