import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyric_ui/ui_netease.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transientmobile/styles/player_lyric_ui.dart';

void main() {
  test('light lyrics use dark text and theme highlight', () {
    final colors = ColorScheme.fromSeed(seedColor: Colors.blue);
    final ui = PlayerLyricUI(colors: colors);
    expect(ui.getPlayingMainTextStyle().color, colors.onSurface);
    expect(ui.getPlayingExtTextStyle().color, colors.onSurfaceVariant);
    expect(
        ui.getOtherMainTextStyle().color!.computeLuminance(), lessThan(0.15));
    expect(ui.getLyricHightlightColor(), colors.primary);
  });
  test('dark lyrics preserve the existing palette', () {
    final colors = ColorScheme.fromSeed(
        seedColor: Colors.blue, brightness: Brightness.dark);
    final ui = PlayerLyricUI(colors: colors);
    final original = UINetease();
    expect(ui.getPlayingMainTextStyle(), original.getPlayingMainTextStyle());
    expect(ui.getOtherMainTextStyle(), original.getOtherMainTextStyle());
    expect(ui.getPlayingExtTextStyle(), original.getPlayingExtTextStyle());
    expect(ui.getOtherExtTextStyle(), original.getOtherExtTextStyle());
    expect(ui.getLyricHightlightColor(), original.getLyricHightlightColor());
  });
}
