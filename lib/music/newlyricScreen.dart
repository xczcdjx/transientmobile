import 'package:flutter_lyric/lyric_ui/ui_netease.dart';
import 'package:flutter_lyric/lyrics_model_builder.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:transientmobile/extensions/customColors.dart';

import '../hooks/useStore.dart';
import '../service/audioHandlerService.dart';
import '../store/index.dart';
import '../utils/musFun.dart';

// 新版歌词组件
class NewLyricScreen extends ConsumerStatefulWidget {
  bool hideSkipPlay;
  LyricAlign lycTextAlign;
  Size? size;
  double defaultSize;
  double defaultExtSize;
  double lineGap;
  double bias;

  NewLyricScreen({
    super.key,
    this.hideSkipPlay = false,
    this.lycTextAlign = LyricAlign.LEFT,
    this.size,
    this.defaultSize = 22,
    this.defaultExtSize = 15,
    this.lineGap = 35,
    this.bias = 0.5,
  });

  @override
  ConsumerState<NewLyricScreen> createState() => NewLyricScreenState();
}

class NewLyricScreenState extends ConsumerState<NewLyricScreen> {
  final _audioHandler = AudioHandlerService.instance.handler;
  late final ProviderSubscription<String?> _lyricSub;
  late UINetease lyricUI; // ✅ 用 late ，不要在这里初始化
  var lyricModel = LyricsModelBuilder.create().bindLyricToMain("").getModel();

  // List<Map<String, dynamic>> demo = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lyricUI = UINetease(
      lyricAlign: widget.lycTextAlign,
      defaultSize: widget.defaultSize,
      lineGap: widget.lineGap,
      bias: widget.bias,
      defaultExtSize: widget.defaultExtSize,
    );
    _lyricSub = ref.listenManual<String?>(
      musProvider.select((s) => s.lyric),
      (prev, next) {
        if (next == null || next == prev || !mounted) return;
        setState(() {
          lyricModel =
              LyricsModelBuilder.create().bindLyricToMain(next).getModel();
        });
      },
    );
    // 如需拿到当前值初始化一次：
    final current = ref.read(musProvider.select((s) => s.lyric)) ?? "";
    lyricModel =
        LyricsModelBuilder.create().bindLyricToMain(current).getModel();
  }

  @override
  void dispose() {
    _lyricSub.close();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final musPStore = useSelector(ref, musPlayProvider, (s) => s);
    final musStore = useSelector(ref, musProvider, (s) => s);
    final currentPosition = musStore.position.inMilliseconds;
    // print(currentPosition);
    return Column(
      children: [
        Expanded(
          child: LyricsReader(
            padding: EdgeInsets.symmetric(horizontal: 15),
            model: lyricModel,
            position: currentPosition,
            lyricUi: lyricUI,
            playing: musPStore.isPlaying,
            size: widget.size,
            emptyBuilder: () => Center(
              child: widget.hideSkipPlay
                  ? SizedBox()
                  : Text(
                      "No lyrics",
                      style: TextStyle(
                          color: context.fc.withOpacity(0.75), fontSize: 16),
                    ),
            ),
            selectLineBuilder: (progress, confirm) {
              return widget.hideSkipPlay
                  ? SizedBox()
                  : GestureDetector(
                      onTap: () {
                        confirm.call();
                        _audioHandler.seek(Duration(milliseconds: progress));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 2.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: context.fc.withOpacity(0.3)),
                                height: 1,
                                width: double.infinity,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: context.lineColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    // color: Colors.white,
                                    size: 13,
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    formatSeconds(progress / 1000),
                                    style: const TextStyle(
                                        // color: Colors.white,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
            },
          ),
        ),
      ],
    );
  }
}
