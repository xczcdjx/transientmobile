import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Simple lyric line model with optional timestamp.
class LyricLine {
  final Duration? time;
  final String text;

  LyricLine({this.time, required this.text});
}

/// A scrolling lyrics widget.
///
/// Features:
/// - Accepts a list of [LyricLine]
/// - Can be driven by an external [currentPosition] (Duration) to auto-scroll
/// - Manual scrolling is allowed (user can drag) — while user drags, auto-scroll pauses
/// - Highlights the current line
/// - Smooth animated scroll to center the active line
class LyricsScroller extends StatefulWidget {
  final List<LyricLine> lines;
  final Duration? currentPosition;
  final TextStyle? normalStyle;
  final TextStyle? highlightedStyle;
  final double lineHeight;
  final Duration scrollDuration;
  final Curve scrollCurve;
  final bool enableAutoScroll;

  /// 当用户点击或滑动选择歌词时回调（用于修改外部播放进度）
  final ValueChanged<Duration>? onSeek;

  const LyricsScroller({
    Key? key,
    required this.lines,
    this.currentPosition,
    this.normalStyle,
    this.highlightedStyle,
    this.lineHeight = 48.0,
    this.scrollDuration = const Duration(milliseconds: 400),
    this.scrollCurve = Curves.easeOutCubic,
    this.enableAutoScroll = true,
    this.onSeek,
  }) : super(key: key);

  @override
  _LyricsScrollerState createState() => _LyricsScrollerState();
}

class _LyricsScrollerState extends State<LyricsScroller> {
  late final ScrollController _controller;
  int _currentIndex = 0;
  bool _userScrolling = false;
  Timer? _resumeTimer;
  int? _hoverIndex;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeScrollToCurrent());
  }

  @override
  void didUpdateWidget(covariant LyricsScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableAutoScroll && widget.currentPosition != oldWidget.currentPosition) {
      _maybeScrollToCurrent();
    }
  }

  @override
  void dispose() {
    _resumeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _maybeScrollToCurrent() {
    if (!widget.enableAutoScroll || widget.currentPosition == null || _userScrolling) return;

    final pos = widget.currentPosition!;
    int idx = 0;
    for (int i = 0; i < widget.lines.length; i++) {
      final t = widget.lines[i].time;
      if (t == null) continue;
      if (t <= pos) idx = i;
      else break;
    }
    if (_currentIndex != idx) {
      _currentIndex = idx;
      _animateToIndex(idx);
    }
  }

  void _animateToIndex(int index) {
    if (!_controller.hasClients) return;
    final targetOffset = index * widget.lineHeight - widget.lineHeight;
    _controller.animateTo(
      targetOffset.clamp(0.0, _controller.position.maxScrollExtent),
      duration: widget.scrollDuration,
      curve: widget.scrollCurve,
    );
  }

  int _getIndexFromOffset(double localDy) {
    final scrollOffset = _controller.offset;
    final absoluteY = scrollOffset + localDy;
    return (absoluteY / widget.lineHeight).floor().clamp(0, widget.lines.length - 1);
  }

  void _pauseAutoScroll() {
    _userScrolling = true;
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 5), () {
      _userScrolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final normal = widget.normalStyle ?? const TextStyle(fontSize: 16, color: Colors.white70);
    final highlighted = widget.highlightedStyle ?? const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold);

    return NotificationListener<ScrollNotification>(
      onNotification: (notif) {
        // 检测滚动时机
        if (notif is UserScrollNotification) {
          // 用户主动拖动
          if (notif.direction != ScrollDirection.idle) {
            _pauseAutoScroll();
            _userScrolling = true;
          } else {
            // 停止拖动后延迟恢复自动滚动
            _resumeTimer?.cancel();
            _resumeTimer = Timer(const Duration(seconds: 2), () {
              _userScrolling = false;
              _hoverIndex = null;
              setState(() {});
            });
          }
        }

        if (notif is ScrollUpdateNotification && _userScrolling) {
          // 只有在用户主动滚动时才更新 hover index
          final offset = _controller.offset;
          final index =
          (offset / widget.lineHeight).round().clamp(0, widget.lines.length - 1);
          if (index != _hoverIndex) {
            _hoverIndex = index;
            _currentIndex = index;
            setState(() {});
          }
        }

        return false;
      },
      child: GestureDetector(
        onTapUp: (details) {
          // 用户点击歌词，触发时间跳转
          final tappedIndex = _getIndexFromOffset(details.localPosition.dy);
          final tapped = widget.lines[tappedIndex];
          if (tapped.time != null) {
            _pauseAutoScroll();
            widget.onSeek?.call(tapped.time!);
            _currentIndex = tappedIndex;
            _hoverIndex = tappedIndex;
            setState(() {});
          }
        },
        onLongPressStart: (_) {
          // 长按时显示时间，但不触发 seek
          _pauseAutoScroll();
          _userScrolling = true;
          setState(() {});
        },
        onLongPressEnd: (_) {
          // 松开后隐藏时间条并恢复自动滚动
          _resumeTimer?.cancel();
          _resumeTimer = Timer(const Duration(seconds: 2), () {
            _userScrolling = false;
            _hoverIndex = null;
            setState(() {});
          });
        },
        child: ListView.builder(
          controller: _controller,
          physics: const BouncingScrollPhysics(),
          itemCount: widget.lines.length,
          padding: EdgeInsets.symmetric(
            vertical: (MediaQuery.of(context).size.height - widget.lineHeight) / 2,
          ),
          itemBuilder: (context, index) {
            final isActive = index == _currentIndex;
            final isHover = index == _hoverIndex;
            return SizedBox(
              height: widget.lineHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: isActive ? highlighted : normal,
                    child: Text(
                      widget.lines[index].text,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_userScrolling && isHover && widget.lines[index].time != null)
                    Positioned(
                      right: 20,
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatDuration(widget.lines[index].time!),
                          style:
                          const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}


/// Example usage of LyricsScroller in a minimal app.
/// In a real app you would drive currentPosition with your audio player's position stream.
void main() {
  runApp(const _ExampleApp());
}

class _ExampleApp extends StatefulWidget {
  const _ExampleApp({Key? key}) : super(key: key);

  @override
  State<_ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<_ExampleApp> {
  final List<LyricLine> demo = List.generate(40, (i) {
    return LyricLine(time: Duration(seconds: i * 3), text: '这是第 ${i + 1} 行词 — 示例文本');
  });

  Duration _pos = Duration.zero;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _pos += const Duration(seconds: 1);
        // loop
        if (_pos > Duration(seconds: demo.length * 3)) _pos = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text('scroll')),
        body: LyricsScroller(
          lines: demo,
          currentPosition: _pos,
          onSeek: (t){
            print(t);
            setState(() {
              _pos=t;
            });
          },
          lineHeight: 56,
          normalStyle: const TextStyle(fontSize: 16, color: Colors.white54),
          highlightedStyle: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
