import 'package:flutter/material.dart';

import '../utils/parseColor.dart';
import 'custom.dart';

final lightTheme = ThemeData.light().copyWith(
  extensions: [
    CustomColors(
      fc: parseCssColor('#000'),
      pc: parseCssColor('orange'),
      pcr: parseCssColor('red'),
      line: parseCssColor('rgba(26, 27, 34, 0.5)'),
      lycFc: parseCssColor('rgba(22,22,23,0.4)'),
      scrollBarBg: parseCssColor('#e6e9ec'),
      navTopBarBg: parseCssColor('rgb(236,238,242)'),
      mainBg: parseCssColor('#fff'),
      mainLinearTBg: parseCssColor('rgba(255, 255, 255, 0.25)'),
      mainLinearBBg: parseCssColor('rgba(255, 255, 255, 0.65)'),
      musicStickBg: parseCssColor('#efeff0'),
      lineColor: parseCssColor('rgba(51,51,51,0.32)'),
      playProgress: parseCssColor('rgba(222,217,217,0.52)'),
      playRangeBarBg: parseCssColor('rgba(204, 204, 204, 0.75)'),
      playRangeBufferBg: parseCssColor('rgba(170, 170, 170, 0.65)'),
      playRangeProgressBg: parseCssColor('orangered'),
      playRangeDotBg: parseCssColor('#ee5959'),
      coverBorder: parseCssColor('rgba(236,125,65,0.73)'),
      explainBorder: parseCssColor('rgba(11,47,225,0.71)'),
      scrollbarThumbBg: parseCssColor('rgba(74, 74, 74, 0.4)'),
      scrollbarBg: parseCssColor('rgba(74, 74, 74, 0.05)'),
    ),
  ],
);

final darkTheme = ThemeData.dark().copyWith(
  extensions: [
    CustomColors(
      bg: parseCssColor('#000'),
      fc: parseCssColor('#fff'),
      pc: parseCssColor('rgba(255,111,0,0.69)'),
      pcr: parseCssColor('rgb(199,30,46)'),
      line: parseCssColor('rgba(239, 239, 240, 0.4)'),
      lycFc: parseCssColor('rgba(206,203,203,0.3)'),
      scrollBarBg: parseCssColor('#1a1b22'),
      navTopBarBg: parseCssColor('rgb(20,20,27)'),
      musicStickBg: parseCssColor('#2c2d38'),
      mainBg: parseCssColor('#000'),
      mainLinearTBg: parseCssColor('rgba(0, 0, 0, 0.1)'),
      mainLinearBBg: parseCssColor('rgba(0, 0, 0, 0.9)'),
      lineColor: parseCssColor('rgba(218,220,223,0.34)'),
      playProgress: parseCssColor('rgba(222,217,217,0.52)'),
      playRangeBarBg: parseCssColor('rgba(218, 220, 223, 0.2)'),
      playRangeBufferBg: parseCssColor('rgba(218, 220, 223, 0.24)'),
      playRangeProgressBg: parseCssColor('rgba(255, 69, 0, 0.78)'),
      playRangeDotBg: parseCssColor('rgba(238, 89, 89, 0.8)'),
      coverBorder: parseCssColor('rgba(236,125,65,0.89)'),
      explainBorder: parseCssColor('#052be5'),
      scrollbarThumbBg: parseCssColor('rgba(161, 154, 154, 0.4)'),
      scrollbarBg: parseCssColor('rgba(161, 154, 154, 0.05)'),
    )
  ],
);
