import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'themes/clean_modern.dart';
import 'themes/dark_finance.dart';
import 'themes/warm_minimal.dart';

enum AppTheme { cleanModern, darkFinance, warmMinimal }

class ThemeCubit extends Cubit<ThemeData> {
  static const _key = 'app_theme';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_loadTheme(_prefs.getString(_key)));

  static ThemeData _loadTheme(String? name) {
    switch (name) {
      case 'dark_finance':
        return darkFinanceTheme();
      case 'warm_minimal':
        return warmMinimalTheme();
      default:
        return cleanModernTheme();
    }
  }

  void setTheme(AppTheme theme) {
    final name = theme.name.replaceAllMapped(
      RegExp(r'[A-Z]'), (m) => '_${m.group(0)!.toLowerCase()}');
    _prefs.setString(_key, name);
    emit(_loadTheme(name));
  }
}
