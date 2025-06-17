import 'package:flutter/material.dart';

ButtonStyle getButtonStyle({
  required Color background,
  required Color foreground,
}) {
  return ButtonStyle(
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(vertical: 14),
    ),
    backgroundColor: WidgetStateProperty.all(background),
    foregroundColor: WidgetStateProperty.all(foreground),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.black.withValues(alpha: 0.04);
      }
      return null;
    }),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    splashFactory: NoSplash.splashFactory,
  );
}

TextStyle getButtonTextStyle({
  Color? color,
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.bold,
}) {
  return TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color);
}
