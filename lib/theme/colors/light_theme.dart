import 'package:flutter/material.dart';

import 'package:haenaedda/theme/app_typography.dart';
import 'package:haenaedda/theme/colors/app_colors.dart';
import 'package:haenaedda/theme/colors/color_scheme_light.dart';
import 'package:haenaedda/theme/colors/surface_container_colors_light.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: lightColorScheme,
  fontFamily: appFontFamily,
  textTheme: ThemeData.light().textTheme.apply(
        fontFamilyFallback: appFontFallback,
      ),
  scaffoldBackgroundColor: AppColors.surfaceContainerLowest,
  useMaterial3: true,
  extensions: const [
    lightSurfaceContainerColors,
  ],
);
