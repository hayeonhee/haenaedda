import 'package:flutter/material.dart';

class NeumorphicTheme {
  static const double blurRadius = 8;
  static const Offset topLeftShadowOffset = Offset(-4, -4);
  static const Offset bottomRightShadowOffset = Offset(4, 4);
  static BorderRadius defaultBorderRadius = BorderRadius.circular(12);

  /// Pressed (Concave) Effect - Light Mode Only
  /// - Looks pressed inward in light mode
  static BoxDecoration pressedBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          offset: topLeftShadowOffset,
          blurRadius: blurRadius,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.7),
          offset: bottomRightShadowOffset,
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
          offset: bottomRightShadowOffset,
          blurRadius: blurRadius,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.7),
          offset: topLeftShadowOffset,
          blurRadius: blurRadius,
        ),
      ],
    );
  }

  static BoxDecoration raisedTileBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          offset: const Offset(2, 2),
          blurRadius: 4,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.6),
          offset: const Offset(-2, -2),
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
          offset: topLeftShadowOffset,
          blurRadius: blurRadius,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: bottomRightShadowOffset,
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
          offset: const Offset(2, 2),
          blurRadius: blurRadius,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(-2, -2),
          blurRadius: blurRadius,
        ),
      ],
    );
  }
}
