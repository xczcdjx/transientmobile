import 'package:flutter/material.dart';

import '../../music/common.dart';
import '../../service/audioHandlerService.dart';
import 'package:rxdart/rxdart.dart';

import '../../utils/AudioHandler.dart';
class ComMusSeek extends StatelessWidget {

  final AudioPlayerHandler audioHandler;
  const ComMusSeek({super.key,required this.audioHandler});


  Stream<Duration> get _bufferedPositionStream => audioHandler.playbackState
      .map((state) => state.bufferedPosition)
      .distinct();

  Stream<Duration?> get _durationStream =>
      audioHandler.mediaItem.map((item) => item?.duration).distinct();

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          audioHandler.durationStream,
          _bufferedPositionStream,
          _durationStream,
              (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return // A seek bar.
      StreamBuilder<PositionData>(
        stream: _positionDataStream,
        builder: (context, snapshot) {
          final positionData = snapshot.data ??
              PositionData(Duration.zero, Duration.zero, Duration.zero);
          return SeekBar(
            duration: positionData.duration,
            position: positionData.position,
            onChangeEnd: (newPosition) {
              audioHandler.seek(newPosition);
            },
          );
        },
      );
  }
}
