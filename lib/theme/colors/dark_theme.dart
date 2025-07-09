import 'package:flutter/material.dart';
import 'package:haenaedda/theme/colors/app_colors.dart';
import 'package:haenaedda/theme/app_typography.dart';
import 'package:haenaedda/theme/colors/color_scheme_dark.dart';
import 'package:haenaedda/theme/colors/surface_container_colors_dark.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.darkPrimary,
  colorScheme: darkColorScheme,
  fontFamily: appFontFamily,
  textTheme: ThemeData.dark().textTheme.apply(
        fontFamilyFallback: appFontFallback,
      ),
  scaffoldBackgroundColor: AppColors.darkSurfaceContainerLowest,
  useMaterial3: true,
  extensions: const [
    darkSurfaceContainerColors,
  ],
);
