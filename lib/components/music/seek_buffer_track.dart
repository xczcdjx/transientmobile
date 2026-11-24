import 'package:flutter/material.dart';

/// Buffered range is lighter than played progress; loading overlays a moving
/// highlight without inventing a download percentage.
class SeekBufferTrack extends StatelessWidget {
  const SeekBufferTrack(
      {super.key,
      required this.duration,
      required this.bufferedPosition,
      this.isLoading = false,
      this.inset = 24});
  final Duration duration;
  final Duration bufferedPosition;
  final bool isLoading;
  final double inset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = duration.inMilliseconds;
    final fraction = total <= 0
        ? 0.0
        : (bufferedPosition.inMilliseconds / total).clamp(0.0, 1.0);
    final accent =
        theme.sliderTheme.activeTrackColor ?? theme.colorScheme.primary;
    return IgnorePointer(
        child: ExcludeSemantics(
            child: SizedBox(
      height: 48,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: inset),
        child: Center(
            child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Stack(children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: fraction, end: fraction),
              duration: const Duration(milliseconds: 250),
              builder: (_, value, __) => LinearProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  minHeight: 2,
                  color: accent.withOpacity(0.36),
                  backgroundColor:
                      theme.colorScheme.onSurface.withOpacity(0.16)),
            ),
            if (isLoading)
              LinearProgressIndicator(
                  value: null,
                  minHeight: 2,
                  color: accent.withOpacity(0.7),
                  backgroundColor: Colors.transparent),
          ]),
        )),
      ),
    )));
  }
}
