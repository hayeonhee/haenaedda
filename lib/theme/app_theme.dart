import 'package:flutter/material.dart';
import 'package:haenaedda/theme/colors/dark_theme.dart';
import 'package:haenaedda/theme/colors/light_theme.dart';

class AppTheme {
  static ThemeData get light => lightTheme;
  static ThemeData get dark => darkTheme;

  static ThemeMode get defaultMode => ThemeMode.system;
}
