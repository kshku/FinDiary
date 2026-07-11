import 'package:equatable/equatable.dart';
import 'package:findiary/core/theme/app_theme.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLoaded extends SettingsState {
  final AppTheme currentTheme;

  const SettingsLoaded({required this.currentTheme});

  @override
  List<Object?> get props => [currentTheme];
}
