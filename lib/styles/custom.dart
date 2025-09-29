import 'package:flutter/material.dart';


@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color? bg;
  final Color? fc;
  final Color? pc;
  final Color? pcr;
  final Color? line;
  final Color? lycFc;
  final Color? scrollBarBg;
  final Color? navTopBarBg;
  final Color? mainBg;
  final Color? mainLinearTBg;
  final Color? mainLinearBBg;
  final Color? musicStickBg;
  final Color? lineColor;
  final Color? playProgress;
  final Color? playRangeBarBg;
  final Color? playRangeBufferBg;
  final Color? playRangeProgressBg;
  final Color? playRangeDotBg;
  final Color? coverBorder;
  final Color? explainBorder;
  final Color? scrollbarThumbBg;
  final Color? scrollbarBg;

  const CustomColors({
    this.bg,
    this.fc,
    this.pc,
    this.pcr,
    this.line,
    this.lycFc,
    this.scrollBarBg,
    this.navTopBarBg,
    this.mainBg,
    this.mainLinearTBg,
    this.mainLinearBBg,
    this.musicStickBg,
    this.lineColor,
    this.playProgress,
    this.playRangeBarBg,
    this.playRangeBufferBg,
    this.playRangeProgressBg,
    this.playRangeDotBg,
    this.coverBorder,
    this.explainBorder,
    this.scrollbarThumbBg,
    this.scrollbarBg,
  });

  @override
  CustomColors copyWith({
    Color? bg,
    Color? fc,
    Color? pc,
    Color? pcr,
    Color? line,
    Color? lycFc,
    Color? scrollBarBg,
    Color? navTopBarBg,
    Color? mainBg,
    Color? mainLinearTBg,
    Color? mainLinearBBg,
    Color? musicStickBg,
    Color? lineColor,
    Color? playProgress,
    Color? playRangeBarBg,
    Color? playRangeBufferBg,
    Color? playRangeProgressBg,
    Color? playRangeDotBg,
    Color? coverBorder,
    Color? explainBorder,
    Color? scrollbarThumbBg,
    Color? scrollbarBg,
  }) {
    return CustomColors(
      bg: bg ?? this.bg,
      fc: fc ?? this.fc,
      pc: pc ?? this.pc,
      pcr: pcr ?? this.pcr,
      line: line ?? this.line,
      lycFc: lycFc ?? this.lycFc,
      scrollBarBg: scrollBarBg ?? this.scrollBarBg,
      navTopBarBg: navTopBarBg ?? this.navTopBarBg,
      mainBg: mainBg ?? this.mainBg,
      mainLinearTBg: mainLinearTBg ?? this.mainLinearTBg,
      mainLinearBBg: mainLinearBBg ?? this.mainLinearBBg,
      musicStickBg: musicStickBg ?? this.musicStickBg,
      lineColor: lineColor ?? this.lineColor,
      playProgress: playProgress ?? this.playProgress,
      playRangeBarBg: playRangeBarBg ?? this.playRangeBarBg,
      playRangeBufferBg: playRangeBufferBg ?? this.playRangeBufferBg,
      playRangeProgressBg: playRangeProgressBg ?? this.playRangeProgressBg,
      playRangeDotBg: playRangeDotBg ?? this.playRangeDotBg,
      coverBorder: coverBorder ?? this.coverBorder,
      explainBorder: explainBorder ?? this.explainBorder,
      scrollbarThumbBg: scrollbarThumbBg ?? this.scrollbarThumbBg,
      scrollbarBg: scrollbarBg ?? this.scrollbarBg,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      bg: Color.lerp(bg, other.bg, t),
      fc: Color.lerp(fc, other.fc, t),
      pc: Color.lerp(pc, other.pc, t),
      pcr: Color.lerp(pcr, other.pcr, t),
      line: Color.lerp(line, other.line, t),
      lycFc: Color.lerp(lycFc, other.lycFc, t),
      scrollBarBg: Color.lerp(scrollBarBg, other.scrollBarBg, t),
      navTopBarBg: Color.lerp(navTopBarBg, other.navTopBarBg, t),
      mainBg: Color.lerp(mainBg, other.mainBg, t),
      mainLinearTBg: Color.lerp(mainLinearTBg, other.mainLinearTBg, t),
      mainLinearBBg: Color.lerp(mainLinearBBg, other.mainLinearBBg, t),
      musicStickBg: Color.lerp(musicStickBg, other.musicStickBg, t),
      lineColor: Color.lerp(lineColor, other.lineColor, t),
      playProgress: Color.lerp(playProgress, other.playProgress, t),
      playRangeBarBg: Color.lerp(playRangeBarBg, other.playRangeBarBg, t),
      playRangeBufferBg: Color.lerp(playRangeBufferBg, other.playRangeBufferBg, t),
      playRangeProgressBg: Color.lerp(playRangeProgressBg, other.playRangeProgressBg, t),
      playRangeDotBg: Color.lerp(playRangeDotBg, other.playRangeDotBg, t),
      coverBorder: Color.lerp(coverBorder, other.coverBorder, t),
      explainBorder: Color.lerp(explainBorder, other.explainBorder, t),
      scrollbarThumbBg: Color.lerp(scrollbarThumbBg, other.scrollbarThumbBg, t),
      scrollbarBg: Color.lerp(scrollbarBg, other.scrollbarBg, t),
    );
  }
}
