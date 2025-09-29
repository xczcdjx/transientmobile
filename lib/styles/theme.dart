import 'package:flutter/material.dart';

import 'custom.dart';

final lightTheme = ThemeData.light().copyWith(
  extensions: [
    const CustomColors(
        primaryButton: Colors.blue,
        cardBackground: Color(0xFFF7F7F7),
        successText: Colors.green,
        warningText: Colors.red,
        primaryText: Colors.orange),
  ],
);

final darkTheme = ThemeData.dark().copyWith(
  extensions: [
    const CustomColors(
        primaryButton: Colors.teal,
        cardBackground: Color(0xFF1E1E1E),
        successText: Colors.lightGreen,
        warningText: Colors.deepOrange,
        primaryText: Colors.blue),
  ],
);
