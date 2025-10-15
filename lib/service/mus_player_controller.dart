import 'package:flutter/material.dart';

import '../music/musMainPlay.dart';

class MusPlayerController {
  static final MusPlayerController _instance = MusPlayerController._internal();

  factory MusPlayerController() => _instance;

  MusPlayerController._internal();

  OverlayEntry? _overlayEntry;
  late AnimationController _animController;

  bool get isVisible => _overlayEntry != null;

  void show(BuildContext context) {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    final animationController = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 300),
    );
    _animController = animationController;

    _overlayEntry = OverlayEntry(
      builder: (_) => MusMainPlay(
        animationController: animationController,
        onClose: hide,
      ),
    );

    overlay.insert(_overlayEntry!);
    animationController.forward();
  }

  void hide() async {
    if (_overlayEntry == null) return;
    await _animController.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void toggle(BuildContext context) {
    if (isVisible) {
      hide();
    } else {
      show(context);
    }
  }
}
