import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transientmobile/store/index.dart';

import '../../hooks/useStore.dart';
import '../../music/common.dart';

import '../../utils/AudioHandler.dart';
class ComMusSeek extends ConsumerWidget {

  final AudioPlayerHandler audioHandler;
  const ComMusSeek({super.key,required this.audioHandler});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final musStore = useSelector(ref, musProvider, (s) => s);
    return // A seek bar.
      SeekBar(
        duration: musStore.duration,
        position: musStore.position,
        bufferedPosition: musStore.bufferedPosition,
        onChangeEnd: (newPosition) {
          audioHandler.seek(newPosition);
        },
      );
  }
}
