import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transientmobile/components/music/comControl.dart';
import 'package:transientmobile/extensions/customColors.dart';
import 'package:transientmobile/hooks/useStore.dart';
import 'package:transientmobile/store/index.dart';

import '../service/mus_player_controller.dart';
import '../service/play_list_controller.dart';
import '../utils/NetImage.dart';

class MusBotScreen extends ConsumerStatefulWidget {
  const MusBotScreen({super.key});

  @override
  ConsumerState<MusBotScreen> createState() => _MusBotScreenState();
}

class _MusBotScreenState extends ConsumerState<MusBotScreen> {
  @override
  Widget build(BuildContext context) {
    final musP = useSelector(ref, musPlayProvider, (mp) => mp);
    if (musP.curSong == null) return SizedBox();
    final mus = useSelector(ref, musProvider, (m) => m);
    final isPlaying = musP.isPlaying;
    final m = musP.curSong!;
    final duration = m.duration ?? Duration();
    final position = mus.position;
    final dispatch = useDispatch(ref, musPlayProvider);
    return Container(
      height: 45,
      child: Padding(
        padding: const EdgeInsets.only(left: 10,right: 5,top: 5,bottom: 5),
        child: Row(
          children: [
            GestureDetector(
              onTap: (){
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    m.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w500,
                      color: isPlaying ? context.pcr : context.fc,
                    ),
                  ),
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
                  Transform.translate(
                    offset: const Offset(0,3),
                    child: SizedBox(
                      width: 35,
                      height: 35,
                      child: ComPlayCircleBtn(
                          position: position,
                          duration: duration,
                          isPlaying: isPlaying,
                          onPlayPause: dispatch.playToggle),
                    ),
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
}
