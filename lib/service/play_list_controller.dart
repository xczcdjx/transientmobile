import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../music/playMainList.dart';

/// A real modal route makes Android back dismiss the queue before its player.
class GlobalBottomSheet {
  static _PlaylistRoute? _route;
  static bool get isShowing => _route != null;

  static void show({
    required BuildContext context,
    Widget? child,
    double maxHeight = 620,
    BorderRadiusGeometry radius = const BorderRadius.all(Radius.circular(28)),
    Color barrierColor = Colors.black54,
    Duration duration = const Duration(milliseconds: 280),
    Curve curve = Curves.easeOutCubic,
  }) {
    if (isShowing) return;
    final route = _PlaylistRoute(
      child: child ?? const PlayMainList(),
      maxHeight: maxHeight,
      radius: radius,
      barrierColor: barrierColor,
      duration: duration,
      curve: curve,
      themes: InheritedTheme.capture(
          from: context,
          to: Navigator.of(context, rootNavigator: true).context),
    );
    _route = route;
    Navigator.of(context, rootNavigator: true).push(route).whenComplete(() {
      if (identical(_route, route)) _route = null;
    });
  }

  static Future<bool> confirmClear(BuildContext context) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final dialog = DialogRoute<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('清空播放列表？'),
              content: const Text('全部歌曲将从当前列表移除，并停止播放。'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('取消')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('确认清空')),
              ],
            ));
    final result = navigator.push(dialog);
    return await result ?? false;
  }

  static void hide() {
    final route = _route;
    if (route == null) return;
    if (route.isCurrent) {
      route.navigator?.pop();
    } else if (route.isActive) {
      route.navigator?.removeRoute(route);
    }
  }
}

class _PlaylistRoute extends PopupRoute<void> {
  _PlaylistRoute(
      {required this.child,
      required this.maxHeight,
      required this.radius,
      required this.barrierColor,
      required this.duration,
      required this.curve,
      required this.themes});
  final Widget child;
  final double maxHeight;
  final BorderRadiusGeometry radius;
  final Duration duration;
  final Curve curve;
  final CapturedThemes themes;
  @override
  final Color barrierColor;
  @override
  bool get barrierDismissible => true;
  @override
  String get barrierLabel => '关闭播放列表';
  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
      themes.wrap(Builder(builder: (context) {
        final media = MediaQuery.of(context);
        final wide = media.size.width > 756;
        final colors = Theme.of(context).colorScheme;
        final bottom = wide ? 20.0 : 0.0;
        final height = math.min(
            maxHeight,
            math.max(
                0.0,
                media.size.height -
                    media.padding.top -
                    media.viewInsets.bottom -
                    bottom -
                    20));
        return AnimatedPadding(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(wide ? 20 : 0, 0, wide ? 20 : 0, bottom),
              child: SizedBox(
                width: 560,
                height: height,
                child: Material(
                  color: colors.surface,
                  borderRadius: radius,
                  clipBehavior: Clip.antiAlias,
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.alphaBlend(
                                  colors.primary.withValues(alpha: 0.08),
                                  colors.surface),
                              colors.surface
                            ]),
                        border: Border.all(
                            color:
                                colors.outlineVariant.withValues(alpha: 0.4)),
                        borderRadius: radius,
                      ),
                      child: SafeArea(
                          top: false,
                          child: Column(children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onVerticalDragEnd: (details) {
                                if ((details.primaryVelocity ?? 0) > 250) {
                                  GlobalBottomSheet.hide();
                                }
                              },
                              child: SizedBox(
                                  height: 24,
                                  width: double.infinity,
                                  child: Center(
                                      child: Container(
                                          width: 36,
                                          height: 4,
                                          decoration: BoxDecoration(
                                              color: colors.onSurfaceVariant
                                                  .withValues(alpha: 0.3),
                                              borderRadius:
                                                  BorderRadius.circular(4))))),
                            ),
                            Expanded(child: child),
                          ]))),
                ),
              ),
            ),
          ),
        );
      }));

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
      SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(
                parent: animation,
                curve: curve,
                reverseCurve: Curves.easeInCubic)),
        child: child,
      );
}
