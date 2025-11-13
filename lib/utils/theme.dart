import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFE74C3C);
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkText = Color(0xFF1a1a1a);
  static const Color lightGrey = Color(0xFFE8E8E8);
  static const Color placeholderGrey = Color(0xFFB0B0B0);

  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryRed,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Roboto',
  );
}
