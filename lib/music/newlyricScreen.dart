import 'dart:async';

import 'package:flutter_lyric/lyric_ui/ui_netease.dart';
import 'package:flutter_lyric/lyrics_model_builder.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:transientmobile/constants/testData.dart';
import 'package:transientmobile/extensions/customColors.dart';

import '../components/music/comControl.dart';
import '../components/music/comPlaySeek.dart';
import '../hooks/useStore.dart';
import '../models/store/mus_play_state.dart';
import '../service/audioHandlerService.dart';
import '../service/play_list_controller.dart';
import '../store/index.dart';
class NewLyricScreen extends ConsumerStatefulWidget {
  bool hideControl;

  NewLyricScreen({super.key, this.hideControl = false});

  @override
  ConsumerState<NewLyricScreen> createState() => NewLyricScreenState();
}

class NewLyricScreenState extends ConsumerState<NewLyricScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // ✅ 保持页面状态
  final _audioHandler = AudioHandlerService.instance.handler;
  late final ProviderSubscription<String?> _lyricSub;
  var lyricUI = UINetease(lyricAlign: LyricAlign.LEFT,defaultSize: 20);
  var lyricModel = LyricsModelBuilder.create()
      .bindLyricToMain("")
      .getModel();
  // List<Map<String, dynamic>> demo = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _lyricSub = ref.listenManual<String?>(
      musProvider.select((s) => s.lyric),
          (prev, next) {
        if (next == null || next == prev || !mounted) return;
        setState(() {
          lyricModel = LyricsModelBuilder.create()
              .bindLyricToMain(next)
              .getModel();
        });
      },
    );
    // 如需拿到当前值初始化一次：
    final current = ref.read(musProvider.select((s) => s.lyric)) ?? "";
    lyricModel = LyricsModelBuilder.create().bindLyricToMain(current).getModel();
  }

  List<Widget> _renderControl() {
    if (!widget.hideControl) {
      return [
        // A seek bar.
        const SizedBox(height: 18.0),
        ComMusSeek(audioHandler: _audioHandler),
        const SizedBox(height: 8.0),
        // Playback controls
        ComControlBtn(_audioHandler,openPlayList: (){
          GlobalBottomSheet.show(context: context);
        },),
        const SizedBox(height: 15.0),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final musPStore = useSelector(ref, musPlayProvider, (s) => s);
    final musStore = useSelector(ref, musProvider, (s) => s);
    final currentPosition=musStore.position.inMilliseconds;
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
            // size: Size(double.infinity, MediaQuery.of(context).size.height / 2),
            emptyBuilder: () => Center(
              child: Text(
                "No lyrics",
                style: TextStyle(color: context.fc.withOpacity(0.75), fontSize: 16),
              ),
            ),
            selectLineBuilder: (progress, confirm) {
              return Row(
                children: [
                  IconButton(
                      onPressed: () {
                        confirm.call();
                       /* setState(() {
                          audioPlayer?.seek(Duration(milliseconds: progress));
                        });*/
                      },
                      icon: Icon(Icons.play_arrow, color: Colors.green)),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.green),
                      height: 1,
                      width: double.infinity,
                    ),
                  ),
                  Text(
                    progress.toString(),
                    style: TextStyle(color: Colors.green),
                  )
                ],
              );
            },
          ),
        ),
        ..._renderControl()
      ],
    );
  }
}