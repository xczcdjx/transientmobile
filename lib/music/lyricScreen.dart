import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transientmobile/constants/testData.dart';
import 'package:transientmobile/extensions/customColors.dart';
import 'package:transientmobile/utils/musFun.dart';

import '../components/music/comControl.dart';
import '../components/music/comPlaySeek.dart';
import '../hooks/useStore.dart';
import '../service/audioHandlerService.dart';
import '../store/index.dart';

/// Simple lyric line model with optional timestamp.
class LyricLine {
  final int? time;
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
  final List<Map<String, dynamic>> lines; // 传入的歌词
  final double currentPosition; // 当前播放进度（秒）
  final double lineHeight;
  final TextStyle activeStyle;
  final TextStyle normalStyle;
  TextAlign textAlign;
  Alignment alignment;
  EdgeInsetsGeometry padding;
  final Function(double seconds)? onSeek;
  double? sizeHeight;
  double? topHeight;

  LyricsScroller({
    super.key,
    required this.lines,
    required this.currentPosition,
    this.lineHeight = 40,
    this.sizeHeight,
    this.topHeight,
    this.textAlign = TextAlign.center,
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.symmetric(horizontal: 0),
    required this.activeStyle,
    required this.normalStyle,
    this.onSeek,
  });

  @override
  State<LyricsScroller> createState() => _LyricsScrollerState();
}

class _LyricsScrollerState extends State<LyricsScroller> {
  static const double _badgeReserveWidth = 60.0;
  final ScrollController _controller = ScrollController();
  int _currentIndex = 0;
  int? _hoverIndex;
  bool _userScrolling = false;
  Timer? _resumeTimer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("2222");
  }

  @override
  void didUpdateWidget(covariant LyricsScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_userScrolling) {
      _updateCurrentIndexByTime(widget.currentPosition);
    }
  }

  void _pauseAutoScroll() {
    _userScrolling = true;
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 3), () {
      _userScrolling = false;
    });
  }

  void _resumeAutoScrollLater() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 1), () {
      _userScrolling = false;
      _hoverIndex = null;
      setState(() {});
    });
  }

  void _updateCurrentIndexByTime(double positionSeconds) {
    for (int i = 0; i < widget.lines.length; i++) {
      final currentTime = widget.lines[i]["time"]?.toDouble() ?? 0;
      final nextTime = i < widget.lines.length - 1
          ? widget.lines[i + 1]["time"]?.toDouble() ?? double.infinity
          : double.infinity;
      if (positionSeconds >= currentTime && positionSeconds < nextTime) {
        if (_currentIndex != i) {
          _currentIndex = i;
          _animateToIndex(i);
          // widget.onActText?.call(widget.lines[i]["lrc"]);
        }
        break;
      }
    }
  }

  void _animateToIndex(int index) {
    final offset = index * widget.lineHeight;
    if (_controller.hasClients) {
      _controller.animateTo(
        offset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  int _getIndexFromOffset(double localDy, double topPadding) {
    final scrollOffset = _controller.hasClients ? _controller.offset : 0.0;
    final absoluteY = scrollOffset + localDy - topPadding;
    final idx = (absoluteY / widget.lineHeight).round();
    return idx.clamp(0, widget.lines.length - 1);
  }

  String _formatSeconds(double seconds) {
    final d = Duration(seconds: seconds.floor());
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lines.isEmpty)
      return Center(
        child: Text(
          "暂无歌词",
          style: TextStyle(color: context.fc.withOpacity(0.75), fontSize: 16),
        ),
      );
    final totHeight = widget.sizeHeight ?? MediaQuery.of(context).size.height;
    widget.sizeHeight ??= totHeight;
    final padTop =
        widget.topHeight ?? ((widget.sizeHeight! - widget.lineHeight) / 2);
    return NotificationListener<ScrollNotification>(
      onNotification: (notif) {
        if (notif is UserScrollNotification) {
          if (notif.direction != ScrollDirection.idle) {
            _pauseAutoScroll();
          } else {
            // _resumeAutoScrollLater();
          }
        }

        if (notif is ScrollUpdateNotification && _userScrolling) {
          final offset = _controller.offset;
          final index = (offset / widget.lineHeight)
              .round()
              .clamp(0, widget.lines.length - 1);
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
          final tappedIndex =
              _getIndexFromOffset(details.localPosition.dy, padTop);
          print("tappedIndex $tappedIndex");
          // 如果点击的不是第一句，就用上一句的时间，否则从0开始
          // final prevIndex = tappedIndex > 0 ? tappedIndex - 1 : 0;
          final prevIndex = tappedIndex;
          final tapped = widget.lines[prevIndex];
          final time = tapped["time"]?.toDouble();
          if (time != null) {
            // _pauseAutoScroll();
            widget.onSeek?.call(time);
            _currentIndex = tappedIndex;
            _hoverIndex = tappedIndex;
            _animateToIndex(tappedIndex);
            _resumeAutoScrollLater();
            setState(() {});
          }
        },
        child: ListView.builder(
          controller: _controller,
          physics: const BouncingScrollPhysics(),
          itemCount: widget.lines.length,
          padding: EdgeInsets.only(
            top: padTop,
            bottom: totHeight - padTop - widget.lineHeight,
          ),
          itemBuilder: (context, index) {
            final isActive = index == _currentIndex;
            final isHover = index == _hoverIndex;
            final line = widget.lines[index];
            return SizedBox(
              height: widget.lineHeight,
              child: Padding(
                padding: widget.padding,
                child: Stack(
                  alignment: widget.alignment,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          right: _userScrolling ? _badgeReserveWidth : 0),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style:
                            isActive ? widget.activeStyle : widget.normalStyle,
                        child: Text(
                          line["lrc"] ?? "",
                          textAlign: widget.textAlign,
                          softWrap: true,
                          // overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (_userScrolling && isHover && line["time"] != null)
                      Positioned(
                        right: 5,
                        child: Container(
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
                                _formatSeconds(line["time"].toDouble()),
                                style: const TextStyle(
                                    // color: Colors.white,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LyricScreen extends ConsumerStatefulWidget {
  bool hideControl;
  List<Map<String,dynamic>> lines;

  LyricScreen({super.key, this.hideControl = false,this.lines=const []});

  @override
  ConsumerState<LyricScreen> createState() => LyricScreenState();
}

class LyricScreenState extends ConsumerState<LyricScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // ✅ 保持页面状态
  final _audioHandler = AudioHandlerService.instance.handler;
  // List<Map<String, dynamic>> demo = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("1111");
  }

  List<Widget> _renderControl() {
    if (!widget.hideControl) {
      return [
        // A seek bar.
        const SizedBox(height: 18.0),
        ComMusSeek(audioHandler: _audioHandler),
        const SizedBox(height: 8.0),
        // Playback controls
        ComControlBtn(_audioHandler),
        const SizedBox(height: 15.0),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final musStore = useSelector(ref, musProvider, (s) => s);
    final currentPosition=musStore.position.inMilliseconds / 1000;
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scrollerHeight = constraints.maxHeight;
              // print("scrollerHeight $scrollerHeight,ctxHeight ${MediaQuery.of(context).size.height}");
              return LyricsScroller(
                lines: widget.lines,
                currentPosition: currentPosition,
                textAlign: TextAlign.start,
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(left: 10),
                topHeight: scrollerHeight / 3,
                sizeHeight: scrollerHeight,
                onSeek: (t) {
                  _audioHandler.seek(Duration(seconds: t.toInt()));
                },
                lineHeight: 65,
                normalStyle: TextStyle(
                    fontSize: 16, color: context.fc.withOpacity(0.75)),
                activeStyle: TextStyle(
                    fontSize: 21,
                    color: context.pc,
                    fontWeight: FontWeight.w700),
              );
            },
          ),
        ),
        ..._renderControl()
      ],
    );
  }
}
