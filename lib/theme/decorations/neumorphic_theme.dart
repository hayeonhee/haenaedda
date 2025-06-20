import 'package:flutter/material.dart';

class NeumorphicTheme {
  static const Offset topLeftOffset = Offset(-2, -2);
  static const Offset deepTopLeftOffset = Offset(-4, -4);
  static const Offset bottomRightOffset = Offset(2, 2);
  static const Offset deepBottomRightOffset = Offset(4, 4);

  static const double blurRadius = 8;
  static BorderRadius defaultBorderRadius = BorderRadius.circular(12);

  /// Pressed (Concave) Effect - Light Mode Only
  /// - Looks pressed inward in light mode
  static BoxDecoration pressedBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: defaultBorderRadius,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          offset: deepTopLeftOffset,
          blurRadius: blurRadius,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.7),
          offset: deepBottomRightOffset,
          blurRadius: blurRadius,
        ),
      ],
    );
  }

  /// Raised (Convex) Effect - Light Mode Only
  /// - Looks raised outward in light mode
  static BoxDecoration raisedBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: defaultBorderRadius,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          offset: deepBottomRightOffset,
          blurRadius: blurRadius,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.7),
          offset: deepTopLeftOffset,
          blurRadius: blurRadius,
        ),
      ],
    );
  }

  static BoxDecoration raisedSettingTileBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          offset: bottomRightOffset,
          blurRadius: 4,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.6),
          offset: topLeftOffset,
          blurRadius: 6,
        ),
      ],
    );
  }

  /// Light mode decoration for recorded (completed) cells
  static BoxDecoration recordedCellDecoration(BuildContext context) {
    return BoxDecoration(
      // TODO: Allow user to customize cell color
      color: const Color(0xFFECE7E0),
      borderRadius: defaultBorderRadius,
      boxShadow: [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.7),
          offset: deepTopLeftOffset,
          blurRadius: blurRadius,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: deepBottomRightOffset,
          blurRadius: blurRadius,
        ),
      ],
    );
  }

  /// Light mode decoration for unrecorded cells
  static BoxDecoration unrecordedCellDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: defaultBorderRadius,
      boxShadow: [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.7),
          offset: bottomRightOffset,
          blurRadius: blurRadius,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: topLeftOffset,
          blurRadius: blurRadius,
        ),
      ],
    );
  }

  static List<BoxShadow> buttonShadow() {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        offset: const Offset(2, 2),
        blurRadius: 5,
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.7),
        offset: const Offset(-2, -2),
        blurRadius: 5,
      ),
    ];
  }
}
