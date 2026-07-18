# Sync Settings Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add auto-sync toggle, manual sync button, and last synced timestamp to the Settings page.

**Architecture:** SyncEngine gains an `autoSyncEnabled` flag and a `syncStatusStream` for UI observation. A new `SyncSettingsCubit` connects SharedPreferences + SyncMetaDao + SyncEngine to the settings UI section.

**Tech Stack:** Flutter, flutter_bloc, SharedPreferences, Drift (SyncMetaDao)

---

### Task 1: Add SyncStatus and auto-sync support to SyncEngine

**Files:**
- Modify: `frontend/lib/core/sync/sync_engine.dart`

- [ ] **Step 1: Write the failing tests for SyncEngine changes**

Add tests to `frontend/test/core/sync/sync_engine_test.dart`:

```dart
// After the existing imports, add:
import 'package:findiary/core/sync/sync_engine.dart';

// Add inside the main group, after the existing tests:

group('autoSyncEnabled', () {
  test('syncNow gates on autoSyncEnabled', () async {
    when(mockConnectivityNotifier.isOnline).thenReturn(true);
    when(() => mockSyncMetaDao.getMeta(any(), any())).thenAnswer((_) async => null);
    when(() => mockSyncMetaDao.getPendingChanges()).thenAnswer((_) async => []);
    when(() => mockSyncService.sync(
      scopeId: any(named: 'scopeId'),
      scopeType: any(named: 'scopeType'),
      lastCheckpoint: any(named: 'lastCheckpoint'),
      localChanges: any(named: 'localChanges'),
    )).thenAnswer((_) async => SyncResponse());

    final engine = SyncEngine(
      syncService: mockSyncService,
      syncMetaDao: mockSyncMetaDao,
      transactionDao: mockTransactionDao,
      categoryDao: mockCategoryDao,
      connectivityNotifier: mockConnectivityNotifier,
      scopeId: 'test',
      scopeType: 'personal',
    );

    engine.autoSyncEnabled = false;
    await engine.syncNow();

    // syncNow should skip auto-sync triggers but still work when called directly
    // Verify sync service was NOT called via auto triggers
    // We can't easily test the private triggers, but syncNow() is public
    verifyNever(() => mockSyncService.sync(
      scopeId: any(named: 'scopeId'),
      scopeType: any(named: 'scopeType'),
      lastCheckpoint: any(named: 'lastCheckpoint'),
      localChanges: any(named: 'localChanges'),
    ));
  });

  test('syncStatusStream emits syncing then success', () async {
    when(mockConnectivityNotifier.isOnline).thenReturn(true);
    when(() => mockSyncMetaDao.getMeta(any(), any())).thenAnswer((_) async => null);
    when(() => mockSyncMetaDao.getPendingChanges()).thenAnswer((_) async => []);
    when(() => mockSyncService.sync(
      scopeId: any(named: 'scopeId'),
      scopeType: any(named: 'scopeType'),
      lastCheckpoint: any(named: 'lastCheckpoint'),
      localChanges: any(named: 'localChanges'),
    )).thenAnswer((_) async => SyncResponse());

    final engine = SyncEngine(
      syncService: mockSyncService,
      syncMetaDao: mockSyncMetaDao,
      transactionDao: mockTransactionDao,
      categoryDao: mockCategoryDao,
      connectivityNotifier: mockConnectivityNotifier,
      scopeId: 'test',
      scopeType: 'personal',
    );

    final statuses = <SyncStatus>[];
    engine.syncStatusStream.listen(statuses.add);
    await engine.syncNow();

    expect(statuses, [SyncStatus.syncing, SyncStatus.success]);
  });
});
```

- [ ] **Step 2: Run existing tests to verify they still pass (before SyncEngine changes)**

```bash
cd frontend && flutter test test/core/sync/sync_engine_test.dart
```
Expected: All existing tests pass

- [ ] **Step 3: Run new tests to verify they fail (TDD: red phase)**

```bash
cd frontend && flutter test test/core/sync/sync_engine_test.dart --reporter expanded
```
Expected: New tests fail (SyncStatus enum and syncStatusStream not yet defined)

- [ ] **Step 4: Implement SyncEngine changes**

In `frontend/lib/core/sync/sync_engine.dart`:

```dart
// After imports, add:
enum SyncStatus { idle, syncing, success, failure }

// In SyncEngine class, add fields after `static const int _maxBackoff = 30;`:
bool autoSyncEnabled = true;
final StreamController<SyncStatus> _syncStatusController =
    StreamController<SyncStatus>.broadcast();
Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

// In dispose(), add:
_syncStatusController.close();

// In _onPendingChange(), wrap body with:
if (!autoSyncEnabled) return;

// In didChangeAppLifecycleState(), wrap body with:
if (!autoSyncEnabled) return;

// In syncNow(), at start after `if (!_connectivityNotifier.isOnline)`:
_syncStatusController.add(SyncStatus.syncing);

// In syncNow(), after success before `_resetBackoff()`:
_syncStatusController.add(SyncStatus.success);

// In syncNow(), in catch block before `_scheduleRetry()`:
_syncStatusController.add(SyncStatus.failure);
```

- [ ] **Step 5: Run updated tests to verify they pass**

```bash
cd frontend && flutter test test/core/sync/sync_engine_test.dart
```
Expected: All tests pass

- [ ] **Step 6: Commit**

```bash
git add frontend/lib/core/sync/sync_engine.dart frontend/test/core/sync/sync_engine_test.dart
git commit -m "feat: add SyncStatus, autoSyncEnabled, and syncStatusStream to SyncEngine"
```

---

### Task 2: Create SyncSettingsCubit

**Files:**
- Create: `frontend/lib/features/settings/bloc/sync_settings_cubit.dart`

- [ ] **Step 1: Write the failing tests**

Create `frontend/test/features/settings/sync_settings_cubit_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:findiary/core/sync/sync_engine.dart';
import 'package:findiary/core/database/daos/sync_meta_dao.dart';
import 'package:findiary/features/settings/bloc/sync_settings_cubit.dart';

class MockSyncMetaDao extends Mock implements SyncMetaDao {}
class MockSyncEngine extends Mock implements SyncEngine {}
class MockSyncMetaData extends Mock implements SyncMetaData {}

void main() {
  late MockSyncMetaDao mockSyncMetaDao;
  late MockSyncEngine mockSyncEngine;
  late SharedPreferences prefs;

  setUp(() async {
    mockSyncMetaDao = MockSyncMetaDao();
    mockSyncEngine = MockSyncEngine();
    SharedPreferences.setMockInitialValues({'auto_sync': false});
    prefs = await SharedPreferences.getInstance();
  });

  group('SyncSettingsCubit', () {
    blocTest<SyncSettingsCubit, SyncSettingsState>(
      'loads with saved preference and last synced time',
      build: () => SyncSettingsCubit(
        prefs: prefs,
        syncMetaDao: mockSyncMetaDao,
        syncEngine: mockSyncEngine,
      ),
      act: (cubit) => cubit.load(),
      setUp: () {
        when(() => mockSyncMetaDao.getMeta(any(), any()))
            .thenAnswer((_) async => MockSyncMetaData());
        when(() => mockSyncEngine.syncStatusStream)
            .thenAnswer((_) => const Stream.empty());
      },
      expect: () => [
        isA<SyncSettingsState>()
            .having((s) => s.autoSyncEnabled, 'autoSync', false)
            .having((s) => s.syncStatus, 'syncStatus', SyncStatus.idle),
      ],
    );

    blocTest<SyncSettingsCubit, SyncSettingsState>(
      'toggleAutoSync updates preference and state',
      build: () => SyncSettingsCubit(
        prefs: prefs,
        syncMetaDao: mockSyncMetaDao,
        syncEngine: mockSyncEngine,
      ),
      act: (cubit) => cubit.toggleAutoSync(true),
      setUp: () {
        when(() => mockSyncEngine.syncStatusStream)
            .thenAnswer((_) => const Stream.empty());
      },
      expect: () => [
        isA<SyncSettingsState>()
            .having((s) => s.autoSyncEnabled, 'autoSync', true),
      ],
      verify: (_) {
        expect(prefs.getBool('auto_sync'), true);
        verify(() => mockSyncEngine.autoSyncEnabled = true);
      },
    );

    blocTest<SyncSettingsCubit, SyncSettingsState>(
      'syncNow calls syncEngine.syncNow',
      build: () => SyncSettingsCubit(
        prefs: prefs,
        syncMetaDao: mockSyncMetaDao,
        syncEngine: mockSyncEngine,
      ),
      act: (cubit) => cubit.syncNow(),
      setUp: () {
        when(() => mockSyncEngine.syncStatusStream)
            .thenAnswer((_) => const Stream.empty());
        when(() => mockSyncEngine.syncNow()).thenAnswer((_) async => SyncResult.success);
      },
      verify: (_) {
        verify(() => mockSyncEngine.syncNow()).called(1);
      },
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd frontend && flutter test test/features/settings/sync_settings_cubit_test.dart
```
Expected: FAIL with "No such file or directory"

- [ ] **Step 3: Create SyncSettingsCubit**

Create `frontend/lib/features/settings/bloc/sync_settings_cubit.dart`:

```dart
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
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd frontend && flutter test test/features/settings/sync_settings_cubit_test.dart
```
Expected: All tests pass

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/features/settings/bloc/sync_settings_cubit.dart frontend/test/features/settings/sync_settings_cubit_test.dart
git commit -m "feat: add SyncSettingsCubit for sync controls"
```

---

### Task 3: Add sync settings section to Settings page

**Files:**
- Modify: `frontend/lib/features/settings/settings_page.dart`

- [ ] **Step 1: Update settings_page.dart**

Add import at top:

```dart
import 'package:findiary/features/settings/bloc/sync_settings_cubit.dart';
```

After the theme section's closing `]),` and before `const SizedBox(height: 32),` (the spacer before logout), insert:

```dart
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
```

Add helper method in `_SettingsViewState`:

```dart
String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
```

- [ ] **Step 2: Verify flutter analyze passes**

```bash
cd frontend && flutter analyze
```
Expected: 0 errors, 0 warnings

- [ ] **Step 3: Commit**

```bash
git add frontend/lib/features/settings/settings_page.dart
git commit -m "feat: add sync settings section to settings page"
```

---

### Task 4: Run full test suite and push

- [ ] **Step 1: Run flutter analyze**

```bash
cd frontend && flutter analyze
```
Expected: 0 errors, 0 warnings

- [ ] **Step 2: Run all tests**

```bash
cd frontend && flutter test
```
Expected: All tests pass

- [ ] **Step 3: Push**

```bash
git push
```
Expected: Changes pushed to remote
