import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../music/musMainPlay.dart';

/// Player and playlist share the Navigator's ordering and back-button handling.
/// Audio ownership stays in AudioHandlerService when the player route closes.
class MusPlayerController {
  static final MusPlayerController _instance = MusPlayerController._internal();
  factory MusPlayerController() => _instance;
  MusPlayerController._internal();

  Route<void>? _route;
  final ValueNotifier<bool> _visible = ValueNotifier<bool>(false);
  bool _disposed = false;

  bool get isVisible => _visible.value;
  ValueListenable<bool> get visibleListenable => _visible;

  void show(BuildContext context) {
    if (_disposed || _route != null) return;
    _visible.value = true;
    final route = PlayerModalRoute(
      child: MusMainPlay(visibleListenable: _visible, onClose: hide),
    );
    _route = route;
    Navigator.of(context, rootNavigator: true).push(route);
    route.completed.whenComplete(() {
      if (identical(_route, route)) {
        _route = null;
        if (!_disposed) _visible.value = false;
      }
    });
  }

  void hide() {
    final route = _route;
    if (route != null && route.isCurrent) route.navigator?.pop();
  }

  void toggle(BuildContext context) => isVisible ? hide() : show(context);

  void dispose() {
    _disposed = true;
    final route = _route;
    _route = null;
    if (route != null && route.isActive) route.navigator?.removeRoute(route);
    _visible.dispose();
  }
}

/// Fullscreen sliding route; a queue/dialog pushed above it never needs an
/// Overlay.rearrange after the animation has finished.
class PlayerModalRoute extends PopupRoute<void> {
  PlayerModalRoute({required this.child});
  final Widget child;
  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
  @override
  Color? get barrierColor => Colors.transparent;
  @override
  bool get barrierDismissible => false;
  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
      child;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
      SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic)),
        child: FadeTransition(opacity: animation, child: child),
      );
}
