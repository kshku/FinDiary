import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:findiary/core/sync/sync_engine.dart';
import 'package:findiary/core/database/daos/sync_meta_dao.dart';

class SyncSettingsState {
  final bool autoSyncEnabled;
  final DateTime? lastSyncedAt;
  final SyncStatus syncStatus;

  const SyncSettingsState({
    this.autoSyncEnabled = true,
    this.lastSyncedAt,
    this.syncStatus = SyncStatus.idle,
  });

  SyncSettingsState copyWith({
    bool? autoSyncEnabled,
    DateTime? lastSyncedAt,
    SyncStatus? syncStatus,
  }) {
    return SyncSettingsState(
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

class SyncSettingsCubit extends Cubit<SyncSettingsState> {
  final SharedPreferences _prefs;
  final SyncMetaDao _syncMetaDao;
  final SyncEngine _syncEngine;
  StreamSubscription<SyncStatus>? _statusSub;

  SyncSettingsCubit({
    required SharedPreferences prefs,
    required SyncMetaDao syncMetaDao,
    required SyncEngine syncEngine,
  })  : _prefs = prefs,
        _syncMetaDao = syncMetaDao,
        _syncEngine = syncEngine,
        super(const SyncSettingsState());

  Future<void> load() async {
    try {
      final autoSync = _prefs.getBool('auto_sync') ?? true;
      _syncEngine.autoSyncEnabled = autoSync;

      final meta = await _syncMetaDao.getMeta('personal', 'personal');
      final lastSynced = meta != null ? DateTime.tryParse(meta.lastSyncedAt ?? '') : null;

      _statusSub?.cancel();
      _statusSub = _syncEngine.syncStatusStream.listen((status) {
        emit(state.copyWith(syncStatus: status));
      });

      emit(SyncSettingsState(
        autoSyncEnabled: autoSync,
        lastSyncedAt: lastSynced,
      ));
    } catch (_) {
      emit(const SyncSettingsState());
    }
  }

  void toggleAutoSync(bool value) {
    _prefs.setBool('auto_sync', value);
    _syncEngine.autoSyncEnabled = value;
    emit(state.copyWith(autoSyncEnabled: value));
  }

  Future<void> syncNow() async {
    await _syncEngine.syncNow();
  }

  @override
  Future<void> close() {
    _statusSub?.cancel();
    return super.close();
  }
}
