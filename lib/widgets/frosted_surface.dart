import 'dart:ui';
import 'package:flutter/material.dart';

/// Bounded backdrop blur for the two floating surfaces in the wide layout.
class FrostedSurface extends StatelessWidget {
  const FrostedSurface({super.key, required this.child, this.radius = 24});
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: (dark ? const Color(0xFF273245) : Colors.white)
                .withValues(alpha: dark ? 0.38 : 0.5),
            border: Border.all(
              color: Colors.white.withValues(alpha: dark ? 0.12 : 0.65),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
