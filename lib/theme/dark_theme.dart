import 'package:flutter/material.dart';
import 'package:haenaedda/theme/app_colors.dart';
import 'package:haenaedda/theme/color_scheme_dark.dart';
import 'package:haenaedda/theme/surface_container_colors_dark.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.darkPrimary,
  colorScheme: darkColorScheme,
  fontFamily: 'Pretendard',
  scaffoldBackgroundColor: AppColors.darkSurfaceContainerLowest,
  useMaterial3: true,
  extensions: const [
    darkSurfaceContainerColors,
  ],
);
