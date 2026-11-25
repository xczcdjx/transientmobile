import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyric_ui/ui_netease.dart';

/// Keep the existing dark palette; use readable ink on the light cover backdrop.
class PlayerLyricUI extends UINetease {
  PlayerLyricUI(
      {required this.colors,
      super.lyricAlign,
      super.defaultSize,
      super.defaultExtSize,
      super.lineGap,
      super.bias});

  final ColorScheme colors;
  bool get _light => colors.brightness == Brightness.light;

  @override
  TextStyle getPlayingMainTextStyle() => _light
      ? super.getPlayingMainTextStyle().copyWith(color: colors.onSurface)
      : super.getPlayingMainTextStyle();

  @override
  TextStyle getOtherMainTextStyle() => _light
      ? super
          .getOtherMainTextStyle()
          .copyWith(color: colors.onSurface.withValues(alpha: 0.72))
      : super.getOtherMainTextStyle();

  @override
  TextStyle getPlayingExtTextStyle() => _light
      ? super.getPlayingExtTextStyle().copyWith(color: colors.onSurfaceVariant)
      : super.getPlayingExtTextStyle();

  @override
  TextStyle getOtherExtTextStyle() => _light
      ? super.getOtherExtTextStyle().copyWith(color: colors.onSurfaceVariant)
      : super.getOtherExtTextStyle();

  @override
  Color getLyricHightlightColor() =>
      _light ? colors.primary : super.getLyricHightlightColor();
}
