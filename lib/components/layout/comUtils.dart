import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
/// 直接拿去替换 Marquee(...) 的自绘滚动文本
class SmoothScrollText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double velocity;           // px/s
  final double blankSpace;         // 两段文本之间的间隔
  final Duration pauseAfterRound;  // 每轮结束后的暂停

  const SmoothScrollText({
    Key? key,
    required this.text,
    required this.style,
    this.velocity = 25.0,
    this.blankSpace = 40.0,
    this.pauseAfterRound = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  State<SmoothScrollText> createState() => _SmoothScrollTextState();
}

class _SmoothScrollTextState extends State<SmoothScrollText> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  double _offset = 0.0;      // 当前位移
  double _textWidth = 0.0;   // 单段文本宽度
  double _viewWidth = 0.0;   // 可视宽度
  bool   _shouldScroll = false;
  bool   _pausing = false;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void didUpdateWidget(covariant SmoothScrollText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style ||
        oldWidget.velocity != widget.velocity || oldWidget.blankSpace != widget.blankSpace) {
      // 文本或参数变化后，重新测量并重置状态
      _offset = 0;
      _pausing = false;
      // 下次 build 的 LayoutBuilder 会重新计算并决定是否滚动
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    if (!_shouldScroll || _pausing) return;

    final dt = (elapsed - _lastTick).inMilliseconds / 1000.0; // 秒
    _lastTick = elapsed;

    final cycle = _textWidth + widget.blankSpace;
    if (cycle <= 0) return;

    // 位置推进
    _offset += widget.velocity * dt;

    // 到达一轮末尾：暂停一下再从 0 继续
    if (_offset >= cycle) {
      _offset = 0;
      if (widget.pauseAfterRound > Duration.zero) {
        _pausing = true;
        Future.delayed(widget.pauseAfterRound, () {
          if (!mounted) return;
          _pausing = false;
        });
      }
    }
    // 请求重绘
    if (mounted) setState(() {});
  }

  void _measureText() {
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    _textWidth = painter.width;
  }

  void _updateTickerState() {
    if (_shouldScroll) {
      if (!_ticker.isActive) {
        _lastTick = Duration.zero;
        _ticker.start();
      }
    } else {
      if (_ticker.isActive) _ticker.stop();
      _offset = 0;
      _pausing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        _viewWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;
        _measureText();

        // 只有文本宽度大于可视宽度且可视宽度有效时才滚动
        _shouldScroll = _viewWidth > 0 && _textWidth > _viewWidth;

        _updateTickerState();

        if (!_shouldScroll) {
          // 不滚动：单行省略
          return Text(
            widget.text,
            style: widget.style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }

        final cycle = _textWidth + widget.blankSpace;
        final dx = -(_offset % cycle);

        return ClipRect(
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.text, style: widget.style),
                SizedBox(width: widget.blankSpace),
                Text(widget.text, style: widget.style),
              ],
            ),
          ),
        );
      },
    );
  }
}

