import 'package:equatable/equatable.dart';
import 'package:findiary/core/theme/app_theme.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

final class SettingsRequested extends SettingsEvent {
  const SettingsRequested();
}

final class ThemeChanged extends SettingsEvent {
  final AppTheme theme;

  const ThemeChanged(this.theme);

  @override
  List<Object?> get props => [theme];
}
