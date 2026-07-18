# Sync Settings Design

**Date:** 2026-07-12
**Status:** Draft

## Overview

Add sync controls to the existing Settings page: auto-sync toggle, manual sync button with progress indicator, and last synced timestamp display.

## Architecture

A `SyncSettingsCubit` handles the sync settings section independently from the existing `SettingsBloc` (theme/auth). The `SyncEngine` gains an `autoSyncEnabled` flag and a sync status stream so the UI can observe sync state reactively.

## Components

### SyncEngine changes

- Export `enum SyncStatus { idle, syncing, success, failure }` from `sync_engine.dart`
- Add `bool autoSyncEnabled` field (default `true`)
- Gate auto-sync triggers (`_onPendingChange`, `didChangeAppLifecycleState`, connectivity listener) on this flag
- Add `StreamController<SyncStatus>` internally, emit on sync start and completion
- Expose `Stream<SyncStatus> syncStatusStream` getter
- Manual sync still always works via `syncNow()` (public method already exists)

### SyncSettingsCubit (`lib/features/settings/bloc/sync_settings_cubit.dart`)

- **State class:** `SyncSettingsState` with `autoSyncEnabled` (bool, default `true`), `lastSyncedAt` (DateTime?), `syncStatus` (SyncStatus, default `idle`)
- **load():** Reads auto-sync from `SharedPreferences` (key: `auto_sync`), reads `lastSyncedAt` from `SyncMetaDao`, subscribes to `syncEngine.syncStatusStream`
- **toggleAutoSync(bool):** Writes to `SharedPreferences`, sets `SyncEngine.autoSyncEnabled`
- **syncNow():** Calls `SyncEngine.syncNow()`
- **dispose():** Cancels stream subscription

### Settings page UI

A new section in the settings `ListView` below the theme picker:

- **SwitchListTile** — "Auto-sync" with subtitle "Automatically sync when changes are made"
- **Text** — "Last synced: 5 minutes ago" (or "Never" if null)
- **FilledButton** — "Sync Now" with a small `CircularProgressIndicator` when status is `syncing`, otherwise the button text

### Data flow

```
Toggle auto-sync → Cubit → write SharedPreferences + set SyncEngine.autoSyncEnabled
Tap Sync Now → Cubit → SyncEngine.syncNow()
SyncEngine syncs → emits status on stream → Cubit updates state → UI rebuilds
Cubit load() → reads SyncMetaDao.lastSyncedAt → display timestamp
```

### Error handling

- Sync failures: SyncEngine already handles retry with backoff
- Cubit receives `failure` status via stream — UI can show a snackbar or inline error
- `load()` errors: default to `autoSyncEnabled=true`, `lastSyncedAt=null`

## Files

- **Modify:** `frontend/lib/core/sync/sync_engine.dart` — add autoSyncEnabled, syncStatusStream
- **Create:** `frontend/lib/features/settings/bloc/sync_settings_cubit.dart` — Cubit + state
- **Modify:** `frontend/lib/features/settings/settings_page.dart` — add sync settings section
- **Modify:** `frontend/lib/core/di/injection.dart` — no changes needed (SyncEngine already in DI)

## Testing

- `sync_engine_test.dart` — update existing tests to cover autoSyncEnabled=false case
- `sync_settings_cubit_test.dart` — 3 tests: load default state, toggle auto-sync, trigger manual sync
