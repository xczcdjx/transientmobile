import 'package:flutter/material.dart';

Color parseCssColor(String cssColor) {
  cssColor = cssColor.trim().toLowerCase();

  // 1. 处理 hex (#rgb, #rrggbb, #aarrggbb)
  if (cssColor.startsWith('#')) {
    String hex = cssColor.substring(1);
    if (hex.length == 3) {
      hex = hex.split('').map((c) => "$c$c").join(); // #f00 -> ff0000
    }
    if (hex.length == 6) {
      hex = "ff$hex"; // 默认不透明
    }
    return Color(int.parse(hex, radix: 16));
  }

  // 2. 处理 rgb()/rgba()
  if (cssColor.startsWith('rgb')) {
    final nums = cssColor
        .replaceAll(RegExp(r'[^\d,\.]'), '') // 只保留数字和逗号
        .split(',')
        .map((e) => double.parse(e))
        .toList();

    final r = nums[0].toInt();
    final g = nums[1].toInt();
    final b = nums[2].toInt();
    final a = nums.length == 4 ? (nums[3] * 255).toInt() : 255;

    return Color.fromARGB(a, r, g, b);
  }

  // 3. 支持命名颜色
  const namedColors = {
    "red": Colors.red,
    "blue": Colors.blue,
    "green": Colors.green,
    "black": Colors.black,
    "white": Colors.white,
    "gray": Colors.grey,
    "yellow": Colors.yellow,
    "purple": Colors.purple,
    "pink": Colors.pink,
    "orange": Colors.orange,
    "cyan": Colors.cyan,
    "teal": Colors.teal,
    "orangered": Color(0xFFFF4500), // #FF4500
  };

  if (namedColors.containsKey(cssColor)) {
    return namedColors[cssColor]!;
  }

  throw ArgumentError("Unsupported CSS color: $cssColor");
}
