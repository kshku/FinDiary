import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:findiary/core/auth/auth_service.dart';
import 'package:findiary/core/theme/app_theme.dart';
import 'package:findiary/core/di/injection.dart';
import 'package:findiary/features/auth/bloc/auth_bloc.dart';
import 'package:findiary/features/auth/bloc/auth_event.dart';
import 'bloc/settings_bloc.dart';
import 'bloc/settings_event.dart';
import 'bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc(
        authService: sl<AuthService>(),
        themeCubit: sl<ThemeCubit>(),
        prefs: sl<SharedPreferences>(),
      ),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const SettingsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Theme', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AppTheme.values.map((t) {
                  final selected = state is SettingsLoaded && state.currentTheme == t;
                  return ChoiceChip(
                    label: Text(_themeLabel(t)),
                    selected: selected,
                    onSelected: (_) => context.read<SettingsBloc>().add(ThemeChanged(t)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              FilledButton.tonalIcon(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _themeLabel(AppTheme t) {
    switch (t) {
      case AppTheme.cleanModern:
        return 'Clean Modern';
      case AppTheme.darkFinance:
        return 'Dark Finance';
      case AppTheme.warmMinimal:
        return 'Warm Minimal';
    }
  }
}
