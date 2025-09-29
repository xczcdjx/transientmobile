import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../styles/custom.dart';

extension CustomThemeColors on BuildContext {
  CustomColors get customColors =>
      Theme.of(this).extension<CustomColors>()!;

  Color get primaryBtn => customColors.primaryButton ?? Theme.of(this).colorScheme.primary;
  Color get cardBg => customColors.cardBackground ?? Theme.of(this).colorScheme.surface;
  Color get success => customColors.successText ?? Colors.green;
  Color get primary => customColors.primaryText ?? Colors.orange;
  Color get warning => customColors.warningText ?? Colors.red;
}
