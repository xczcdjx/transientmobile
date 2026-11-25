import 'package:flutter/material.dart';

/// Ready for a future random-track action without inventing a current song.
class EmptyMiniPlayer extends StatelessWidget {
  const EmptyMiniPlayer({super.key, required this.wide, required this.onPlay});
  final bool wide;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: wide ? 70 : 50,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: wide ? 16 : 10),
        child: Row(children: [
          Container(
              width: wide ? 44 : 36,
              height: wide ? 44 : 36,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [colors.primary, colors.tertiary])),
              child: Icon(Icons.music_note_rounded,
                  color: colors.onPrimary, size: wide ? 28 : 24)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Music',
                    style: TextStyle(
                        color: colors.onSurface, fontWeight: FontWeight.w600)),
                Text('让音乐陪伴此刻',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: colors.onSurfaceVariant, fontSize: 11)),
              ])),
          if (wide)
            const IconButton(
                tooltip: '上一首',
                onPressed: null,
                icon: Icon(Icons.skip_previous_rounded)),
          IconButton(
              tooltip: '播放',
              onPressed: onPlay,
              icon: Icon(Icons.play_circle_filled_rounded,
                  color: colors.onSurface),
              iconSize: 30),
          const IconButton(
              tooltip: '下一首',
              onPressed: null,
              icon: Icon(Icons.skip_next_rounded)),
          const IconButton(
              tooltip: '播放列表',
              onPressed: null,
              icon: Icon(Icons.queue_music_rounded)),
        ]),
      ),
    );
  }
}
