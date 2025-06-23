import 'package:flutter/material.dart';

class NeumorphicTheme {
  static const Offset topLeftOffset = Offset(-2, -2);
  static const Offset deepTopLeftOffset = Offset(-4, -4);
  static const Offset bottomRightOffset = Offset(2, 2);
  static const Offset deepBottomRightOffset = Offset(4, 4);

  static const double blurRadius = 8;
  static BorderRadius defaultBorderRadius = BorderRadius.circular(12);

  static BoxDecoration recordedCellDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF6B7380) : const Color(0xFFECE7E0),
      borderRadius: defaultBorderRadius,
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.grey.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.7),
          offset: isDark ? topLeftOffset : deepTopLeftOffset,
          blurRadius: blurRadius,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.7 : 0.1),
          offset: deepBottomRightOffset,
          blurRadius: blurRadius,
        ),
      ],
    );
  }

  static BoxDecoration unrecordedCellDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: defaultBorderRadius,
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.grey.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.7),
          offset: bottomRightOffset,
          blurRadius: blurRadius,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
          offset: topLeftOffset,
          blurRadius: blurRadius,
        ),
      ],
    );
  }

  static List<BoxShadow> buttonShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.7 : 0.05),
        offset: const Offset(2, 2),
        blurRadius: 5,
      ),
      BoxShadow(
        color: isDark
            ? Colors.grey.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.7),
        offset: const Offset(-2, -2),
        blurRadius: 5,
      ),
    ];
  }
}
