import 'package:flutter/material.dart';

ThemeData darkFinanceTheme() {
  const primary = Color(0xFF7CFFB2);
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: primary,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1a1a2e),
    cardTheme: const CardThemeData(
      color: Color(0xFF16213e),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF16213e),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}
