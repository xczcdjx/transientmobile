// PlayMainList.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlayMainList extends StatefulWidget {
  final VoidCallback onClose;
  final ValueListenable<bool> visibleListenable; // ✅ 新增

  const PlayMainList({
    super.key,
    required this.onClose,
    required this.visibleListenable,
  });

  @override
  State<PlayMainList> createState() => _PlayMainListState();
}

class _PlayMainListState extends State<PlayMainList>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;   // 位移动画（y 从 1 → 0）
  late final Animation<double> _scrim;   // 遮罩透明度（0 → 0.5）

  @override
  void initState() {
    super.initState();
    print("1111");
    WidgetsBinding.instance.addObserver(this);

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 220),
    );
    final curve = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeInOut,
    );
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curve);
    _scrim = Tween<double>(begin: 0, end: 0.5).animate(curve);

    // 监听可见性，驱动 forward/reverse
    widget.visibleListenable.addListener(_onVisibleChanged);
    if (widget.visibleListenable.value) {
      _ctrl.value = 1; // 如果初始就是可见，直接就位
    }
  }

  void _onVisibleChanged() {
    if (widget.visibleListenable.value) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.visibleListenable.removeListener(_onVisibleChanged);
    _ctrl.dispose();
    super.dispose();
  }

  // 可选：物理返回拦截（通常已由 LocalHistoryEntry 处理，无需必加）
  @override
  Future<bool> didPopRoute() async {
    if (widget.visibleListenable.value) {
      widget.onClose(); // 触发下滑退出
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final showing = _ctrl.value > 0; // 0 表示完全隐藏
        return IgnorePointer(
          // 隐藏时不吃手势
          ignoring: !showing,
          child: Stack(
            children: [
              // 半透明遮罩，点击关闭
              Opacity(
                opacity: _scrim.value,
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(color: Colors.black),
                ),
              ),

              // 底部面板：自下而上滑入/滑出
              Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: _slide,
                  child: SafeArea(
                    top: false,
                    child: _buildPanel(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPanel(BuildContext context) {
    // TODO: 这里放你的播放器内容
    return Material(
      elevation: 12,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.6, // 比如 60% 高
        child: Column(
          children: [
            // 顶部把手/关闭按钮
            Container(
              height: 44,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // ... 你的播放器主 UI ...
          ],
        ),
      ),
    );
  }
}
