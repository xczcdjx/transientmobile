import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transientmobile/store/index.dart';

import '../../hooks/useStore.dart';
import '../../music/common.dart';

import '../../utils/AudioHandler.dart';
class ComMusSeek extends ConsumerWidget {

  final AudioPlayerHandlerImpl audioHandler;
  const ComMusSeek({super.key,required this.audioHandler});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final musStore = useSelector(ref, musProvider, (s) => s);
    final musPStore = useSelector(ref, musPlayProvider, (s) => s);
    return // A seek bar.
      SeekBar(
        duration: musPStore.curSong?.duration??const Duration(seconds: 0),
        position: musStore.position,
        bufferedPosition: musStore.bufferedPosition,
        onChangeEnd: (newPosition) {
          audioHandler.seek(newPosition);
        },
      );
  }
}
