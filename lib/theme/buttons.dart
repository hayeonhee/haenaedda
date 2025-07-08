import 'package:flutter/material.dart';
import 'package:haenaedda/theme/app_colors.dart';

ButtonStyle getTextButtonStyle({
  required Color backgroundColor,
  required Color foregroundColor,
}) {
  return ButtonStyle(
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(vertical: 14),
    ),
    backgroundColor: WidgetStateProperty.all(backgroundColor),
    foregroundColor: WidgetStateProperty.all(foregroundColor),
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

/// ✅ Used for primary actions like "Save", "Confirm", etc.
/// Example: When the user is expected to proceed or submit data.
ButtonStyle getPrimaryButtonStyle(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final backgroundColor = isDark ? AppColors.darkPrimary : AppColors.primary;
  final foregroundColor =
      isDark ? AppColors.darkOnPrimary : AppColors.onPrimary;
  return getTextButtonStyle(
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
  );
}

/// ✅ Used for neutral or secondary actions like "Cancel", "Close", etc.
/// Example: When the action is not destructive and not the main flow.
ButtonStyle getNeutralButtonStyle(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final backgroundColor =
      isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainer;
  final foregroundColor =
      isDark ? AppColors.darkOnSurface : AppColors.onSurface;
  return getTextButtonStyle(
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
  );
}

ButtonStyle getDestructiveButtonStyle(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final backgroundColor =
      isDark ? AppColors.darkError : AppColors.errorContainer;
  final foregroundColor =
      isDark ? AppColors.darkOnError : AppColors.onErrorContainer;
  return getTextButtonStyle(
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
  );
}

TextStyle getButtonTextStyle({
  Color? color,
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.bold,
}) {
  return TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color);
}

ButtonStyle getAppbarButtonStyle(BuildContext context) {
  return ButtonStyle(
    splashFactory: NoSplash.splashFactory,
    overlayColor: WidgetStateProperty.all(Colors.transparent),
    foregroundColor:
        WidgetStateProperty.all(Theme.of(context).colorScheme.onSurface),
  );
}

TextStyle getAppbarButtonTextStyle(BuildContext context, bool isButtonEnabled) {
  final colorScheme = Theme.of(context).colorScheme;
  return TextStyle(
    fontSize: 18,
    color: isButtonEnabled ? colorScheme.onSurface : colorScheme.outline,
    fontWeight: FontWeight.w600,
  );
}
