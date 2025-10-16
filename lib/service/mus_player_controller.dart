import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../music/musMainPlay.dart';

/// 悬浮播放器控制器：
/// - 叠加层仅插入一次（maintainState）
/// - 用 ValueNotifier<bool> 控制显隐
/// - 用 LocalHistoryEntry 接管物理返回键（返回先收起，而不是直接退出路由）
class MusPlayerController {
  static final MusPlayerController _instance = MusPlayerController._internal();
  factory MusPlayerController() => _instance;
  MusPlayerController._internal();

  OverlayEntry? _entry;                       // 懒加载一次并永久驻留
  final ValueNotifier<bool> _visible = ValueNotifier<bool>(false);
  LocalHistoryEntry? _historyEntry;

  bool get isVisible => _visible.value;
  ValueListenable<bool> get visibleListenable => _visible;

  void _ensureOverlayInserted(BuildContext context) {
    if (_entry != null) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    assert(overlay != null, 'No Overlay found. Make sure you call this after MaterialApp.');
    if (overlay == null) return;

    _entry = OverlayEntry(
      maintainState: true,
      builder: (_) => MusMainPlay(
        // ✅ 由子组件自己根据 visible 来做显隐动画/布局占位
        visibleListenable: _visible,
        onClose: hide,
      ),
    );

    overlay.insert(_entry!);
  }

  /// 显示：插入 overlay（若未插入）并置可见；
  /// 同时压入一条 LocalHistoryEntry 以处理物理返回键为“先收起”
  void show(BuildContext context) {
    _ensureOverlayInserted(context);
    if (_visible.value) return;

    _visible.value = true;

    final route = ModalRoute.of(context);
    if (route != null) {
      _historyEntry = LocalHistoryEntry(onRemove: () {
        // 用户按返回键：先把这条 history 弹出 → 回调到这里
        _visible.value = false;
        _historyEntry = null;
      });
      route.addLocalHistoryEntry(_historyEntry!);
    }
  }

  /// 隐藏：仅切换可见性；并配对移除本次加入的 LocalHistoryEntry
  void hide() {
    if (!_visible.value) return;
    _visible.value = false;

    _historyEntry?.remove();
    _historyEntry = null;
  }

  void toggle(BuildContext context) => isVisible ? hide() : show(context);

  /// 可选：在应用退出或不再需要时调用，彻底移除 OverlayEntry
  void dispose() {
    _historyEntry?.remove();
    _historyEntry = null;
    _entry?.remove();
    _entry = null;
    _visible.dispose();
  }
}
