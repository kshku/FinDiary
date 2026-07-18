import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:findiary/core/auth/auth_service.dart';
import 'package:findiary/core/theme/app_theme.dart';
import 'package:findiary/core/di/injection.dart';
import 'package:findiary/core/sync/sync_engine.dart';
import 'package:findiary/core/database/daos/sync_meta_dao.dart';
import 'package:findiary/features/auth/bloc/auth_bloc.dart';
import 'package:findiary/features/auth/bloc/auth_event.dart';
import 'bloc/settings_bloc.dart';
import 'bloc/settings_event.dart';
import 'bloc/settings_state.dart';
import 'bloc/sync_settings_cubit.dart';

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
              Text('Sync', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              BlocProvider<SyncSettingsCubit>(
                create: (_) => SyncSettingsCubit(
                  prefs: sl<SharedPreferences>(),
                  syncMetaDao: sl<SyncMetaDao>(),
                  syncEngine: sl<SyncEngine>(),
                )..load(),
                child: BlocBuilder<SyncSettingsCubit, SyncSettingsState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          title: const Text('Auto-sync'),
                          subtitle: const Text('Automatically sync when changes are made'),
                          value: state.autoSyncEnabled,
                          onChanged: (v) => context.read<SyncSettingsCubit>().toggleAutoSync(v),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            state.lastSyncedAt != null
                                ? 'Last synced: ${_timeAgo(state.lastSyncedAt!)}'
                                : 'Last synced: Never',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: FilledButton.tonalIcon(
                            onPressed: state.syncStatus == SyncStatus.syncing
                                ? null
                                : () => context.read<SyncSettingsCubit>().syncNow(),
                            icon: state.syncStatus == SyncStatus.syncing
                                ? const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.sync),
                            label: Text(
                              state.syncStatus == SyncStatus.syncing
                                  ? 'Syncing...'
                                  : 'Sync Now',
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
