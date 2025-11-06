import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transientmobile/utils/NetImage.dart';

/// 播放时旋转的封面组件（不使用 flutter_hooks）
class RotatingAlbumCover extends StatefulWidget {
  final String imageUrl;
  final bool playing;
  final double size;
  final EdgeInsetsGeometry pad;

  const RotatingAlbumCover({
    super.key,
    required this.imageUrl,
    required this.playing,
    this.size = 200,
    this.pad=const EdgeInsets.all(8),
  });

  @override
  State<RotatingAlbumCover> createState() => _RotatingAlbumCoverState();
}

class _RotatingAlbumCoverState extends State<RotatingAlbumCover>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // 一圈20秒
    );

    if (widget.playing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(RotatingAlbumCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 根据播放状态控制旋转开关
    if (widget.playing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.playing && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      // width: widget.size,
      child: Padding(
        padding: widget.pad,
        child: Center(
          child: RotationTransition(
            turns: _controller,
            child: ClipOval(
              child: NetImage(
                url:widget.imageUrl,
                cache: true,
                // width: widget.size,
                // height: widget.size,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
