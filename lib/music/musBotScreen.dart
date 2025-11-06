import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:transientmobile/components/music/comControl.dart';
import 'package:transientmobile/components/music/comSlider.dart';
import 'package:transientmobile/extensions/customColors.dart';
import 'package:transientmobile/hooks/useStore.dart';
import 'package:transientmobile/store/index.dart';
import 'package:transientmobile/utils/formatDate.dart';

import '../components/images/rotatingAlbumCover.dart';
import '../service/audioHandlerService.dart';
import '../service/mus_player_controller.dart';
import '../service/play_list_controller.dart';
import '../utils/NetImage.dart';
import '../utils/getDevice.dart';

class MusBotScreen extends ConsumerStatefulWidget {
  const MusBotScreen({super.key});

  @override
  ConsumerState<MusBotScreen> createState() => _MusBotScreenState();
}

class _MusBotScreenState extends ConsumerState<MusBotScreen> {
  final audioHandler = AudioHandlerService.instance.handler;

  @override
  Widget build(BuildContext context) {
    final isTab = isTabletAll(context);
    final musP = useSelector(ref, musPlayProvider, (mp) => mp);
    if (musP.curSong == null) return SizedBox();
    final mus = useSelector(ref, musProvider, (m) => m);
    final isPlaying = musP.isPlaying;
    final m = musP.curSong!;
    final duration = m.duration ?? Duration();
    final position = mus.position;
    final dispatch = useDispatch(ref, musPlayProvider);
    if (isTab) {
      return Container(
        height: 70,
        color: context.musicStickBg.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12.5),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  MusPlayerController().show(context);
                },
                child: SizedBox(
                  height: 55,
                  width: 55,
                  child: RotatingAlbumCover(
                    pad: const EdgeInsets.all(3.5),
                    imageUrl: (musP.curSong?.artUri ?? "").toString(),
                    playing: musP.isPlaying,
                    size: 55,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 标题 + 歌手
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildTitleArtist(m,isPlaying),),
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 80,
                          child: Row(
                            children: [
                              _renderText(tranTime(mus.position), context),
                              SizedBox(
                                width: 2.5,
                              ),
                              _renderText("/", context),
                              SizedBox(
                                width: 2.5,
                              ),
                              _renderText(
                                  tranTime(musP.curSong?.duration ??
                                      const Duration(seconds: 0)),
                                  context),
                            ],
                          ),
                        )
                      ],
                    ),
                    Expanded(
                      child: ComSeekBar(
                        duration: musP.curSong?.duration ??
                            const Duration(seconds: 0),
                        position: mus.position,
                        bufferedPosition: mus.bufferedPosition,
                        showDuration: false,
                        onChangeEnd: (newPosition) {
                          audioHandler.seek(newPosition);
                        },
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 210,
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                        icon: const Icon(
                          Icons.skip_previous,
                          size: 30,
                        ),
                        onPressed: dispatch.previous),
                    Transform.translate(
                      offset: const Offset(0, 1),
                      child: SizedBox(
                        width: 45,
                        height: 45,
                        child: ComPlayCircleBtn(
                            outSize: 45,
                            iconSize: 35,
                            position: position,
                            duration: duration,
                            isPlaying: isPlaying,
                            onPlayPause: dispatch.playToggle),
                      ),
                    ),
                    IconButton(
                        icon: const Icon(
                          Icons.skip_next,
                          size: 30,
                        ),
                        onPressed: dispatch.next),
                    IconButton(
                        onPressed: () {
                          GlobalBottomSheet.show(context: context);
                        },
                        icon: Icon(
                          Icons.queue_music_sharp,
                          size: 30,
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }
    return Container(
      height: 50,
      color: context.musicStickBg.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                MusPlayerController().show(context);
              },
              child: SizedBox(
                width: 35,
                height: 35,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NetImage(
                    url: m.artUri.toString(),
                    cache: true,
                    width: 35,
                    height: 35,
                    loadingWidget: (ctx, str) => const Padding(
                      padding: EdgeInsets.all(15),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 标题 + 歌手
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTitle(m,isPlaying),
                  // const SizedBox(height: 3),
                  Text(
                    m.artist ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 179,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      icon: const Icon(
                        Icons.skip_previous,
                        size: 24,
                      ),
                      onPressed: dispatch.previous),
                  SizedBox(
                    width: 35,
                    height: 35,
                    child: ComPlayCircleBtn(
                        position: position,
                        duration: duration,
                        isPlaying: isPlaying,
                        onPlayPause: dispatch.playToggle),
                  ),
                  IconButton(
                      icon: const Icon(
                        Icons.skip_next,
                        size: 24,
                      ),
                      onPressed: dispatch.next),
                  IconButton(
                      onPressed: () {
                        GlobalBottomSheet.show(context: context);
                      },
                      icon: Icon(
                        Icons.queue_music_sharp,
                        size: 24,
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _renderText(String str, BuildContext ctx) {
    return Text(
      str,
      style: TextStyle(color: ctx.line.withOpacity(0.7), fontSize: 11),
    );
  }

  Widget _buildTitleArtist(MediaItem m, bool isPlaying) {
    final title = m.title;
    final artist = m.artist ?? '';
    final text = "$title  -  $artist";

    if (isPlaying) {
      return _PlayingTitle(text: text,style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: context.pcr,
      ),);
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.fc,
            ),
          ),
          const TextSpan(text: '  -  '),
          TextSpan(
            text: artist,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
  Widget _buildTitle(MediaItem m, bool isPlaying){
    if (isPlaying) {
      return _PlayingTitle(text: m.title,style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: context.pcr,
      ),);
    }
    return Text(
      m.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 12,
      ),
    );
  }
}
class _PlayingTitle extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _PlayingTitle({
    Key? key,
    required this.text,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        // 父级必须给有界宽度，否则 TextScroll 不会动
        if (!maxW.isFinite || maxW <= 0) {
          return Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          );
        }

        // 测量文本宽度，只有溢出才滚动
        final tp = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout(maxWidth: double.infinity);

        final needScroll = tp.width > maxW;

        if (!needScroll) {
          return Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          );
        }

        // 有界 + 溢出：启动 TextScroll
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: TextScroll(
            text,
            mode: TextScrollMode.endless,                 // endless 更直观
            intervalSpaces: 8,                            // 循环间隔
            velocity: const Velocity(pixelsPerSecond: Offset(50, 0)),
            delayBefore: const Duration(milliseconds: 300),
            pauseBetween: Duration.zero,                  // 也可给 300ms 小停顿
            style: style,
            textAlign: TextAlign.left,
            selectable: false,                            // 先禁掉，避免个别布局冲突
          ),
        );
      },
    );
  }
}
