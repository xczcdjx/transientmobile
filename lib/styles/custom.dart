import 'package:flutter/material.dart';

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color? primaryButton;
  final Color? cardBackground;
  final Color? successText;
  final Color? warningText;
  final Color? primaryText;

  const CustomColors({
    this.primaryButton,
    this.cardBackground,
    this.successText,
    this.warningText,
    this.primaryText,
  });

  @override
  CustomColors copyWith({
    Color? primaryButton,
    Color? primaryText,
    Color? cardBackground,
    Color? successText,
    Color? warningText,
  }) {
    return CustomColors(
      primaryButton: primaryButton ?? this.primaryButton,
      cardBackground: cardBackground ?? this.cardBackground,
      successText: successText ?? this.successText,
      warningText: warningText ?? this.warningText,
      primaryText: primaryText ?? this.primaryText,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      primaryButton: Color.lerp(primaryButton, other.primaryButton, t),
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t),
      successText: Color.lerp(successText, other.successText, t),
      warningText: Color.lerp(warningText, other.warningText, t),
      primaryText: Color.lerp(primaryText, other.primaryText, t),
    );
  }
}
