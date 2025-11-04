import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transientmobile/extensions/customColors.dart';
import 'package:transientmobile/hooks/useStore.dart';
import 'package:transientmobile/music/newlyricScreen.dart';
import 'package:transientmobile/store/index.dart';

import '../components/music/comControl.dart';
import '../components/music/comPlaySeek.dart';
import '../service/audioHandlerService.dart';
import '../service/play_list_controller.dart';
import '../utils/NetImage.dart';
// music 词主控
class MusLyricScreen extends ConsumerStatefulWidget {
  const MusLyricScreen({super.key});

  @override
  ConsumerState<MusLyricScreen> createState() => _MusLyricScreenState();
}

class _MusLyricScreenState extends ConsumerState<MusLyricScreen>
    with AutomaticKeepAliveClientMixin {
  final _audioHandler = AudioHandlerService.instance.handler;

  @override
  bool get wantKeepAlive => true; // ✅ 保持页面状态
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final musP = useSelector(ref, musPlayProvider, (m) => m);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            children: [
              SizedBox(
                height: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NetImage(
                    url: (musP.curSong?.artUri.toString()) ?? "",
                    cache: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      musP.curSong?.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: context.fc
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      musP.curSong?.artist ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10,),
        Expanded(child: NewLyricScreen()),
        const SizedBox(height: 18.0),
        ComMusSeek(audioHandler: _audioHandler),
        const SizedBox(height: 8.0),
        // Playback controls
        ComControlBtn(
          _audioHandler,
          openPlayList: () {
            GlobalBottomSheet.show(context: context);
          },
        ),
        const SizedBox(height: 15.0),
      ],
    );
  }
}
