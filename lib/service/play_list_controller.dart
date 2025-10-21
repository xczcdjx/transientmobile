import 'package:flutter/material.dart';

class GlobalBottomSheet {
  static OverlayEntry? _entry;

  static void show({
    required BuildContext context,
    required Widget child,
  }) {
    _entry?.remove();

    final overlay = Overlay.of(context, rootOverlay: true);
    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // 半透明遮罩
          GestureDetector(
            onTap: hide,
            child: Container(color: Colors.black54),
          ),
          // 底部弹窗内容
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              offset: const Offset(0, 0),
              child: Material(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  // padding: const EdgeInsets.all(16),
                  constraints: const BoxConstraints(maxHeight: 520),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
