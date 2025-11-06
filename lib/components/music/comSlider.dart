import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:transientmobile/extensions/customColors.dart';
import 'package:transientmobile/music/common.dart';

import '../../utils/formatDate.dart';

class ComSeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  final bool showDuration;
  final bool showRemain;

  const ComSeekBar({
    Key? key,
    required this.duration,
    required this.position,
    this.bufferedPosition = Duration.zero,
    this.onChanged,
    this.onChangeEnd,
    this.showDuration = true,
    this.showRemain = false,
  }) : super(key: key);

  @override
  ComSeekBarState createState() => ComSeekBarState();
}

class ComSeekBarState extends State<ComSeekBar> {
  double? _dragValue; // ms
  bool _dragging = false;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxMs =
        widget.duration.inMilliseconds.toDouble().clamp(0.0, double.infinity);
    final positionMs = (_dragValue ?? widget.position.inMilliseconds.toDouble())
        .clamp(0.0, maxMs);
    final bufferedMs =
        widget.bufferedPosition.inMilliseconds.toDouble().clamp(0.0, maxMs);

    // 拖动结束后下一帧清空 _dragValue（避免卡住）
    if (_dragValue != null && !_dragging) {
      _dragValue = null;
    }

    // 计算“剩余时间”：拖动中显示基于拖动位置的剩余；否则基于实际播放位置
    final remaining =
        widget.duration - Duration(milliseconds: positionMs.round());

    return Stack(
      children: [
        // 缓冲进度条（禁用拇指）
        SliderTheme(
          data: _sliderThemeData.copyWith(
              thumbShape: const _HiddenThumbComponentShape(),
              activeTrackColor: Colors.blue.shade100,
              inactiveTrackColor: Colors.grey.shade300,
              trackShape: FullWidthTrackShape()),
          child: ExcludeSemantics(
            child: Slider(
              min: 0.0,
              max: maxMs > 0 ? maxMs : 1.0, // 防 0
              value: math.min(bufferedMs, maxMs),
              onChanged: null, // 纯显示
            ),
          ),
        ),

        // 时间文本（左：当前位置 / 右：总时长）
        if (widget.showDuration) ...[
          Positioned(
            left: 16.0,
            bottom: -2.0,
            child: Text(
              tranTime(Duration(milliseconds: positionMs.round())),
              style: TextStyle(color: context.fc,fontSize: 13),
            ),
          ),
          Positioned(
            right: 16.0,
            bottom: -2.0,
            child: Text(
              tranTime(widget.duration),
              style: TextStyle(color: context.fc,fontSize: 13),
            ),
          ),
        ],

        // 可交互的主滑条
        SliderTheme(
          data: _sliderThemeData.copyWith(
              inactiveTrackColor: Colors.transparent, // 让下层缓冲条可见
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 5.0,
                pressedElevation: 3.5,
              ),
              trackShape: FullWidthTrackShape()),
          child: Slider(
            min: 0.0,
            max: maxMs > 0 ? maxMs : 1.0,
            value: positionMs.isFinite ? positionMs : 0.0,
            onChanged: (v) {
              if (!_dragging) _dragging = true;

              // 仅当值确实变化时再刷新
              if ((_dragValue ?? -1) != v) {
                setState(() {
                  _dragValue = v.clamp(0.0, maxMs);
                });
              }

              final d = Duration(milliseconds: _dragValue!.round());
              widget.onChanged?.call(d);
            },
            onChangeEnd: (v) {
              final clamped = v.clamp(0.0, maxMs);
              widget.onChangeEnd?.call(Duration(milliseconds: clamped.round()));
              _dragging = false;
              // 不在这里 setState 清空 _dragValue，交给下一帧顶部逻辑清理，避免抖动
              setState(() {});
            },
          ),
        ),

        // 右下角显示剩余时间（随拖动变化）
        if (widget.showRemain)
          Positioned(
            right: 16.0,
            bottom: 0.0,
            child: Text(
              tranTime(remaining),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  /// 外部可读的“剩余时间”（不考虑拖动中的临时位置）
  Duration get remaining => widget.duration - widget.position;
}

/// 一个极简的隐藏拇指形状（若你工程里已有类似实现，可删除此类）
class _HiddenThumbComponentShape extends SliderComponentShape {
  const _HiddenThumbComponentShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    // 故意不画任何东西
  }
}
