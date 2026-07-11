import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:findiary/core/auth/auth_service.dart';
import 'package:findiary/core/theme/app_theme.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final ThemeCubit _themeCubit;
  final SharedPreferences _prefs;

  SettingsBloc({
    required AuthService authService,
    required ThemeCubit themeCubit,
    required SharedPreferences prefs,
  })  : _themeCubit = themeCubit,
        _prefs = prefs,
        super(const SettingsInitial()) {
    on<SettingsRequested>(_onRequested);
    on<ThemeChanged>(_onThemeChanged);
  }

  void _onRequested(SettingsRequested event, Emitter<SettingsState> emit) {
    final stored = _prefs.getString('app_theme');
    final theme = AppTheme.values.firstWhere(
      (t) => _themeName(t) == stored,
      orElse: () => AppTheme.cleanModern,
    );
    emit(SettingsLoaded(currentTheme: theme));
  }

  void _onThemeChanged(ThemeChanged event, Emitter<SettingsState> emit) {
    _themeCubit.setTheme(event.theme);
    emit(SettingsLoaded(currentTheme: event.theme));
  }

  String _themeName(AppTheme t) {
    switch (t) {
      case AppTheme.cleanModern:
        return 'clean_modern';
      case AppTheme.darkFinance:
        return 'dark_finance';
      case AppTheme.warmMinimal:
        return 'warm_minimal';
    }
  }
}
