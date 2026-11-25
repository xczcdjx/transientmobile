import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// One initialization and a conservative glass budget for the entire app.
class AppGlass {
  static Future<void>? _initialization;
  static bool _available = true;

  static Future<void> initialize() => _initialization ??= _load();

  static Future<void> _load() async {
    try {
      await LiquidGlassWidgets.initialize(
        enablePerformanceMonitor: false,
        warmUpMode: GlassWarmUpMode.never,
      );
    } catch (error) {
      _available = false;
      debugPrint('Glass shaders unavailable; using basic glass: $error');
    }
  }

  static GlassQuality get quality =>
      _available ? GlassQuality.standard : GlassQuality.minimal;

  static Widget wrap(Widget child) => LiquidGlassWidgets.wrap(
        brightnessResolver: Theme.maybeBrightnessOf,
        theme: GlassThemeData(
          light: GlassThemeVariant.light.copyWith(quality: quality),
          dark: GlassThemeVariant.dark.copyWith(quality: quality),
        ),
        // GlassScaffold uses Widgets/Cupertino rather than Material. Supply
        // Material's text defaults above the navigator, including its overlays.
        child: Material(type: MaterialType.transparency, child: child),
      );
}
