import 'package:flutter/material.dart';
import 'package:haenaedda/theme/app_colors.dart';
import 'package:haenaedda/theme/color_scheme_light.dart';
import 'package:haenaedda/theme/surface_container_colors_light.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: lightColorScheme,
  fontFamily: 'Pretendard',
  scaffoldBackgroundColor: AppColors.surfaceContainerLowest,
  useMaterial3: true,
  extensions: const [
    lightSurfaceContainerColors,
  ],
);
