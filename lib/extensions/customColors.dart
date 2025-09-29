import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../styles/custom.dart';

extension CustomThemeColors on BuildContext {
  CustomColors get customColors =>
      Theme.of(this).extension<CustomColors>()!;

  // 常用别名
  Color get primaryBtn => customColors.pc ?? Theme.of(this).colorScheme.primary;
  Color get cardBg => customColors.bg ?? Theme.of(this).colorScheme.surface;

  // === 对应 token 的快捷 getter ===
  Color get bg => customColors.bg ?? Theme.of(this).scaffoldBackgroundColor;
  Color get fc => customColors.fc ?? Theme.of(this).colorScheme.onBackground;
  Color get pc => customColors.pc ?? Theme.of(this).colorScheme.primary;
  Color get pcr => customColors.pcr ?? Theme.of(this).colorScheme.error;
  Color get line => customColors.line ?? Colors.grey;
  Color get lycFc => customColors.lycFc ?? Colors.grey;
  Color get scrollBarBg => customColors.scrollBarBg ?? Colors.transparent;
  Color get navTopBarBg => customColors.navTopBarBg ?? Theme.of(this).appBarTheme.backgroundColor ?? Colors.transparent;
  Color get mainBg => customColors.mainBg ?? Theme.of(this).scaffoldBackgroundColor;
  Color get mainLinearTBg => customColors.mainLinearTBg ?? Colors.transparent;
  Color get mainLinearBBg => customColors.mainLinearBBg ?? Colors.transparent;
  Color get musicStickBg => customColors.musicStickBg ?? Theme.of(this).colorScheme.surfaceVariant;
  Color get lineColor => customColors.lineColor ?? Colors.grey;
  Color get playProgress => customColors.playProgress ?? Colors.grey;
  Color get playRangeBarBg => customColors.playRangeBarBg ?? Colors.grey;
  Color get playRangeBufferBg => customColors.playRangeBufferBg ?? Colors.grey;
  Color get playRangeProgressBg => customColors.playRangeProgressBg ?? Theme.of(this).colorScheme.primary;
  Color get playRangeDotBg => customColors.playRangeDotBg ?? Theme.of(this).colorScheme.secondary;
  Color get coverBorder => customColors.coverBorder ?? Colors.grey;
  Color get explainBorder => customColors.explainBorder ?? Colors.grey;
  Color get scrollbarThumbBg => customColors.scrollbarThumbBg ?? Colors.grey;
  Color get scrollbarBg => customColors.scrollbarBg ?? Colors.transparent;
}

