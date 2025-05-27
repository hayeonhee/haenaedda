import 'package:flutter/material.dart';
import 'package:haenaedda/theme/dark_theme.dart';
import 'package:haenaedda/theme/light_theme.dart';

class AppTheme {
  static ThemeData get light => lightTheme;
  static ThemeData get dark => darkTheme;

  static ThemeMode get defaultMode => ThemeMode.system;
}
