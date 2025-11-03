import 'package:flutter/material.dart';
import 'package:transientmobile/extensions/customColors.dart';

import '../music/playMainList.dart';
class GlobalBottomSheet {
  static OverlayEntry? _entry;

  static bool get isShowing => _entry != null;

  static void show({
    required BuildContext context,
    Widget? child, // 可自定义内容，默认用 PlayMainList()
    double maxHeight = 620,
    BorderRadiusGeometry radius =
    const BorderRadius.vertical(top: Radius.circular(16)),
    Color barrierColor = Colors.black54,
    Duration duration = const Duration(milliseconds: 280),
    Curve curve = Curves.easeOutCubic,
  }) {
    // 若已存在，先移除（保证“单例效果”）
    _entry?.remove();

    final overlay = Overlay.of(context, rootOverlay: true);
    _entry = OverlayEntry(
      maintainState: true,
      opaque: false,
      builder: (_) => _BottomSheetHost(
        barrierColor: barrierColor,
        maxHeight: maxHeight,
        radius: radius,
        duration: duration,
        curve: curve,
        onClose: hide,
        child: child ?? PlayMainList(),
      ),
    );
    overlay.insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}

/// 内部真正承载动画+手势的 Widget
class _BottomSheetHost extends StatefulWidget {
  final Widget child;
  final VoidCallback onClose;
  final double maxHeight;
  final BorderRadiusGeometry radius;
  final Color barrierColor;
  final Duration duration;
  final Curve curve;

  const _BottomSheetHost({
    super.key,
    required this.child,
    required this.onClose,
    required this.maxHeight,
    required this.radius,
    required this.barrierColor,
    required this.duration,
    required this.curve,
  });

  @override
  State<_BottomSheetHost> createState() => _BottomSheetHostState();
}

class _BottomSheetHostState extends State<_BottomSheetHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim; // 0=完全展开，1=完全隐藏（从底部）
  double _dragDy = 0.0; // 记录拖拽的像素位移（正数=向下）
  double _sheetHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _ctrl, curve: widget.curve);
    // 初始在底部（隐藏）
    _ctrl.value = 1.0;
    // 播放进入动画：自下而上
    _ctrl.reverse(); // 1.0 -> 0.0
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _ctrl.forward(); // 0.0 -> 1.0（下滑离场）
    widget.onClose();
  }

  // 手势：根据下拉位移，实时设定 controller.value
  void _onVerticalDragUpdate(DragUpdateDetails d) {
    if (_sheetHeight <= 0) return;
    _dragDy += d.delta.dy;
    // 将位移映射为 0..1 的进度偏移（只允许“向下”增加进度；向上不超过展开状态）
    final delta = (_dragDy / _sheetHeight).clamp(0.0, 1.0);
    _ctrl.value = delta; // 0 展开；1 隐藏
  }

  void _onVerticalDragEnd(DragEndDetails d) {
    final vy = d.primaryVelocity ?? 0.0; // 正数=向下，负数=向上
    const velocityThreshold = 650.0; // 速度阈值
    const progressThreshold = 0.35;  // 进度阈值（拖拽超过 35% 就关闭）

    final shouldClose =
        vy > velocityThreshold || _ctrl.value > progressThreshold;

    if (shouldClose) {
      _dismiss();
    } else {
      // 回弹至展开
      _ctrl.reverse();
    }
    _dragDy = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    // 用 LayoutBuilder 拿到实际 sheet 高度
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom; // 兼容键盘
    final maxH = widget.maxHeight;

    return Stack(
      children: [
        // 半透明遮罩
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _dismiss,
            child: FadeTransition(
              opacity: _anim.drive(Tween(begin: 1.0, end: 0.0)), // 展开=1.0，隐藏=0.0
              child: Container(color: widget.barrierColor),
            ),
          ),
        ),

        // 底部弹窗
        AnimatedBuilder(
          animation: _anim,
          builder: (context, _) {
            // 根据进度将 sheet 从底部位移：1.0 → 完全在屏外；0.0 → 贴底
            final translateY = _anim.value * (_sheetHeight == 0 ? maxH : _sheetHeight);

            return Align(
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
                offset: Offset(0, translateY),
                child: Padding(
                  // 兼容键盘顶起
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: Material(
                    color: Colors.transparent,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxH),
                      child: LayoutBuilder(
                        builder: (context, bc) {
                          _sheetHeight = bc.maxHeight; // 记录高度用于拖拽进度
                          return GestureDetector(
                            onVerticalDragUpdate: _onVerticalDragUpdate,
                            onVerticalDragEnd: _onVerticalDragEnd,
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.bg.withOpacity(0.8),
                                borderRadius: widget.radius,
                              ),
                              child: SafeArea(
                                top: false,
                                child: widget.child,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
