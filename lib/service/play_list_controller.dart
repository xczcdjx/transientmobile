import 'package:flutter/cupertino.dart';
import '../music/playMainList.dart';

class PlayListController {
  static final PlayListController _instance = PlayListController._internal();
  factory PlayListController() => _instance;
  PlayListController._internal();

  OverlayEntry? _entry;                 // 永久插入（懒加载一次）
  final _visible = ValueNotifier<bool>(false);
  LocalHistoryEntry? _historyEntry;

  bool get isVisible => _visible.value;

  void _ensureOverlayInserted(BuildContext context) {
    if (_entry != null) return;

    final overlay = Overlay.of(context, rootOverlay: true)!;

    // 仅创建一次 MusMainPlay；用 ValueListenableBuilder 控制显隐
    _entry = OverlayEntry(
      maintainState: true,
      builder: (_) => PlayMainList(
        visibleListenable: _visible,   // ✅ 传给子组件驱动动画
        onClose: hide,
      ),
    );

    overlay.insert(_entry!);
  }

  void show(BuildContext context) {
    _ensureOverlayInserted(context);
    if (_visible.value) return;

    _visible.value = true;

    // 每次显示时，压入一条 local history，用于物理返回键
    final route = ModalRoute.of(context);
    _historyEntry = LocalHistoryEntry(onRemove: () {
      // 用户按返回键 → 先移除此条，再回调这里
      _visible.value = false;
      _historyEntry = null;
    });
    route?.addLocalHistoryEntry(_historyEntry!);
  }

  void hide() {
    if (!_visible.value) return;
    _visible.value = false;

    // 主动隐藏时，配对移除本次加入的 local history
    _historyEntry?.remove();
    _historyEntry = null;
  }

  void toggle(BuildContext context) => isVisible ? hide() : show(context);
}
