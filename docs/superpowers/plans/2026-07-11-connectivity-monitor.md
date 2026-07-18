# Connectivity Monitor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add device-level network awareness so SyncEngine skips sync attempts when offline and triggers sync on reconnect.

**Architecture:** A `ConnectivityNotifier` wrapping `connectivity_plus` exposes a synchronous `isOnline` and a `Stream<bool> onConnectivityChanged`. SyncEngine uses it to gate gRPC calls and listen for reconnect.

**Tech Stack:** Flutter, connectivity_plus ^6.1.0, mocktail

---

### Task 1: Add connectivity_plus dependency

**Files:**
- Modify: `frontend/pubspec.yaml`

- [ ] **Step 1: Add dependency**

Edit `frontend/pubspec.yaml` — add `connectivity_plus` under `dependencies`:

```yaml
dependencies:
  ...
  connectivity_plus: ^6.1.0
```

- [ ] **Step 2: Install dependency**

Run: `cd frontend && flutter pub get`
Expected: Packages installed successfully, no errors.

- [ ] **Step 3: Commit**

```bash
git add frontend/pubspec.yaml frontend/pubspec.lock
git commit -m "chore: add connectivity_plus dependency"
```

---

### Task 2: Create ConnectivityNotifier

**Files:**
- Create: `frontend/lib/core/network/connectivity_notifier.dart`
- Create: `frontend/test/core/network/connectivity_notifier_test.dart`

- [ ] **Step 1: Write the failing test**

Create `frontend/test/core/network/connectivity_notifier_test.dart`:

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:findiary/core/network/connectivity_notifier.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;
  late ConnectivityNotifier notifier;

  setUp(() {
    mockConnectivity = MockConnectivity();
    notifier = ConnectivityNotifier(connectivity: mockConnectivity);
  });

  group('ConnectivityNotifier', () {
    test('initialize sets isOnline to true when wifi is available', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => const Stream<bool>.empty());

      await notifier.initialize();

      expect(notifier.isOnline, isTrue);
    });

    test('initialize sets isOnline to false when no connectivity', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => const Stream<bool>.empty());

      await notifier.initialize();

      expect(notifier.isOnline, isFalse);
    });

    test('onConnectivityChanged emits when state changes', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.wifi]));

      final states = <bool>[];
      notifier.onConnectivityChanged.listen(states.add);

      await notifier.initialize();

      expect(notifier.isOnline, isTrue);
      expect(states, [true]);
    });

    test('isOnline defaults to false', () {
      expect(notifier.isOnline, isFalse);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd frontend && flutter test test/core/network/connectivity_notifier_test.dart`
Expected: FAIL — file not found or class not defined

- [ ] **Step 3: Write minimal implementation**

Create `frontend/lib/core/network/connectivity_notifier.dart`:

```dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityNotifier {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = false;
  final _controller = StreamController<bool>.broadcast();

  bool get isOnline => _isOnline;
  Stream<bool> get onConnectivityChanged => _controller.stream;

  ConnectivityNotifier({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final online = !results.contains(ConnectivityResult.none);
    if (online != _isOnline) {
      _isOnline = online;
      _controller.add(online);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && flutter test test/core/network/connectivity_notifier_test.dart`
Expected: All 4 tests PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/core/network/connectivity_notifier.dart frontend/test/core/network/connectivity_notifier_test.dart
git commit -m "feat: add ConnectivityNotifier wrapping connectivity_plus"
```

---

### Task 3: Update SyncEngine to use ConnectivityNotifier

**Files:**
- Modify: `frontend/lib/core/sync/sync_engine.dart`
- Modify: `frontend/test/core/sync/sync_engine_test.dart`

- [ ] **Step 1: Write the failing tests**

Update `frontend/test/core/sync/sync_engine_test.dart` — add tests for connectivity gating and reconnect trigger:

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
// ... existing imports ...

class MockSyncMetaDao extends Mock implements SyncMetaDao {}
class MockTransactionDao extends Mock implements TransactionDao {}
class MockCategoryDao extends Mock implements CategoryDao {}
class MockConnectivityNotifier extends Mock implements ConnectivityNotifier {}

void main() {
  late MockSyncMetaDao mockSyncMetaDao;
  late MockTransactionDao mockTransactionDao;
  late MockCategoryDao mockCategoryDao;
  late MockConnectivityNotifier mockConnectivity;

  setUpAll(() {
    registerFallbackValue(const SyncMetaCompanion());
    registerFallbackValue(0);
  });

  setUp(() {
    mockSyncMetaDao = MockSyncMetaDao();
    mockTransactionDao = MockTransactionDao();
    mockCategoryDao = MockCategoryDao();
    mockConnectivity = MockConnectivityNotifier();

    when(() => mockSyncMetaDao.removePendingChange(any()))
        .thenAnswer((_) async {});
    when(() => mockSyncMetaDao.upsertMeta(any()))
        .thenAnswer((_) async {});
  });

  group('SyncEngine', () {
    test('syncNow performs full sync cycle', () async {
      when(() => mockConnectivity.isOnline).thenReturn(true);

      when(() => mockSyncMetaDao.getMeta('user-1', 'personal'))
          .thenAnswer((_) async => SyncMetaData(
            scopeId: 'user-1',
            scopeType: 'personal',
            lastCheckpoint: 10,
            lastSyncedAt: null,
          ));

      when(() => mockSyncMetaDao.getPendingChanges())
          .thenAnswer((_) async => [
            PendingChange(
              id: 1,
              entityType: 'transaction',
              entityId: 'tx-1',
              action: 'update',
              payload: '{"id":"tx-1"}',
              createdAt: '2026-07-11T00:00:00Z',
              retryCount: 0,
            ),
          ]);

      var syncCalled = false;
      final engine = SyncEngine(
        syncService: SyncService((request) async {
          syncCalled = true;
          expect(request.scopeId, 'user-1');
          expect(request.scopeType, 'personal');
          expect(request.lastCheckpoint, Int64(10));
          expect(request.localChanges.length, 1);
          return SyncResponse(
            newCheckpoint: Int64(42),
            remoteChanges: [],
            conflicts: [],
          );
        }),
        syncMetaDao: mockSyncMetaDao,
        transactionDao: mockTransactionDao,
        categoryDao: mockCategoryDao,
        connectivityNotifier: mockConnectivity,
        scopeId: 'user-1',
        scopeType: 'personal',
      );

      final result = await engine.syncNow();

      expect(result, SyncResult.success);
      expect(syncCalled, isTrue);
      verify(() => mockSyncMetaDao.upsertMeta(any())).called(1);
      verify(() => mockSyncMetaDao.removePendingChange(1)).called(1);
    });

    test('syncNow skips sync when offline', () async {
      when(() => mockConnectivity.isOnline).thenReturn(false);

      when(() => mockSyncMetaDao.getMeta('user-1', 'personal'))
          .thenAnswer((_) async => SyncMetaData(
            scopeId: 'user-1',
            scopeType: 'personal',
            lastCheckpoint: 10,
            lastSyncedAt: null,
          ));

      when(() => mockSyncMetaDao.getPendingChanges())
          .thenAnswer((_) async => []);

      final engine = SyncEngine(
        syncService: SyncService((request) async {
          throw Exception('Should not be called');
        }),
        syncMetaDao: mockSyncMetaDao,
        transactionDao: mockTransactionDao,
        categoryDao: mockCategoryDao,
        connectivityNotifier: mockConnectivity,
        scopeId: 'user-1',
        scopeType: 'personal',
      );

      final result = await engine.syncNow();

      expect(result, SyncResult.failure);
      verifyNever(() => mockSyncMetaDao.upsertMeta(any()));
    });

    test('syncNow handles gRPC errors gracefully', () async {
      when(() => mockConnectivity.isOnline).thenReturn(true);

      when(() => mockSyncMetaDao.getMeta('user-1', 'personal'))
          .thenAnswer((_) async => SyncMetaData(
            scopeId: 'user-1',
            scopeType: 'personal',
            lastCheckpoint: 10,
            lastSyncedAt: null,
          ));

      when(() => mockSyncMetaDao.getPendingChanges())
          .thenAnswer((_) async => [
            PendingChange(
              id: 1,
              entityType: 'transaction',
              entityId: 'tx-1',
              action: 'update',
              payload: '{"id":"tx-1"}',
              createdAt: '2026-07-11T00:00:00Z',
              retryCount: 0,
            ),
          ]);

      final engine = SyncEngine(
        syncService: SyncService((request) async {
          throw Exception('Service unavailable');
        }),
        syncMetaDao: mockSyncMetaDao,
        transactionDao: mockTransactionDao,
        categoryDao: mockCategoryDao,
        connectivityNotifier: mockConnectivity,
        scopeId: 'user-1',
        scopeType: 'personal',
      );

      final result = await engine.syncNow();

      expect(result, SyncResult.failure);
    });

    test('start subscribes to connectivity changes and triggers sync on reconnect', () async {
      when(() => mockConnectivity.isOnline).thenReturn(true);

      when(() => mockSyncMetaDao.getMeta('user-1', 'personal'))
          .thenAnswer((_) async => SyncMetaData(
            scopeId: 'user-1',
            scopeType: 'personal',
            lastCheckpoint: 10,
            lastSyncedAt: null,
          ));

      when(() => mockSyncMetaDao.getPendingChanges())
          .thenAnswer((_) async => []);

      final engine = SyncEngine(
        syncService: SyncService((request) async {
          return SyncResponse(
            newCheckpoint: Int64(42),
            remoteChanges: [],
            conflicts: [],
          );
        }),
        syncMetaDao: mockSyncMetaDao,
        transactionDao: mockTransactionDao,
        categoryDao: mockCategoryDao,
        connectivityNotifier: mockConnectivity,
        scopeId: 'user-1',
        scopeType: 'personal',
      );

      StreamController<bool> controller = StreamController<bool>.broadcast();
      when(() => mockConnectivity.onConnectivityChanged).thenAnswer((_) => controller.stream);

      engine.start();

      controller.add(true);
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockSyncMetaDao.upsertMeta(any())).called(1);

      controller.close();
      engine.dispose();
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd frontend && flutter test test/core/sync/sync_engine_test.dart`
Expected: FAIL — SyncEngine missing connectivityNotifier parameter

- [ ] **Step 3: Update SyncEngine implementation**

Edit `frontend/lib/core/sync/sync_engine.dart`:

Add import:
```dart
import '../network/connectivity_notifier.dart';
```

Add field and constructor parameter:
```dart
class SyncEngine with WidgetsBindingObserver {
  final SyncService _syncService;
  final SyncMetaDao _syncMetaDao;
  final TransactionDao _transactionDao;
  final CategoryDao _categoryDao;
  final ConnectivityNotifier _connectivityNotifier;
  final String _scopeId;
  final String _scopeType;
  StreamSubscription<bool>? _connectivitySub;

  bool _isSyncing = false;
  bool _isApplyingRemote = false;
  Timer? _debounceTimer;
  int _backoffDelay = 1;
  static const int _maxBackoff = 30;

  SyncEngine({
    required SyncService syncService,
    required SyncMetaDao syncMetaDao,
    required TransactionDao transactionDao,
    required CategoryDao categoryDao,
    required ConnectivityNotifier connectivityNotifier,
    required String scopeId,
    required String scopeType,
  })  : _syncService = syncService,
        _syncMetaDao = syncMetaDao,
        _transactionDao = transactionDao,
        _categoryDao = categoryDao,
        _connectivityNotifier = connectivityNotifier,
        _scopeId = scopeId,
        _scopeType = scopeType;
```

Update `start()`:
```dart
void start() {
  WidgetsBinding.instance.addObserver(this);
  _transactionDao.onPendingChange = _onPendingChange;
  _connectivitySub = _connectivityNotifier.onConnectivityChanged.listen((online) {
    if (online) {
      unawaited(syncNow());
    }
  });
}
```

Update `dispose()`:
```dart
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  _debounceTimer?.cancel();
  _transactionDao.onPendingChange = null;
  _connectivitySub?.cancel();
}
```

Add connectivity check at the top of `syncNow()`:
```dart
Future<SyncResult> syncNow() async {
  if (_isSyncing) return SyncResult.success;
  if (!_connectivityNotifier.isOnline) return SyncResult.failure;
  // ... rest of method unchanged ...
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && flutter test test/core/sync/sync_engine_test.dart`
Expected: All tests PASS (existing 2 + new 3 = 5 tests)

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/core/sync/sync_engine.dart frontend/test/core/sync/sync_engine_test.dart
git commit -m "feat: integrate ConnectivityNotifier into SyncEngine"
```

---

### Task 4: Wire ConnectivityNotifier in DI

**Files:**
- Modify: `frontend/lib/core/di/injection.dart`

- [ ] **Step 1: Register ConnectivityNotifier in DI**

Edit `frontend/lib/core/di/injection.dart` — add import and registration:

Add import:
```dart
import '../network/connectivity_notifier.dart';
```

Add before SyncEngine registration:
```dart
  final connectivityNotifier = ConnectivityNotifier();
  sl.registerLazySingleton<ConnectivityNotifier>(() => connectivityNotifier);
```

Update SyncEngine registration to pass `connectivityNotifier`:
```dart
  final syncEngine = SyncEngine(
    syncService: syncService,
    syncMetaDao: syncMetaDao,
    transactionDao: transactionDao,
    categoryDao: categoryDao,
    connectivityNotifier: connectivityNotifier,
    scopeId: 'personal',
    scopeType: 'personal',
  );
  sl.registerLazySingleton<SyncEngine>(() => syncEngine);
```

Also initialize the notifier after DI setup (in `main.dart` or app startup):

- [ ] **Step 2: Initialize on app start**

Edit `frontend/lib/main.dart`:

```dart
import 'core/sync/sync_engine.dart';
import 'core/network/connectivity_notifier.dart';
// ... existing imports ...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await sl<ConnectivityNotifier>().initialize();
  sl<SyncEngine>().start();
  runApp(const App());
}
```

- [ ] **Step 3: Run flutter analyze**

Run: `cd frontend && flutter analyze`
Expected: No errors or warnings

- [ ] **Step 4: Run full test suite**

Run: `cd frontend && flutter test`
Expected: All tests PASS (existing + new)

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/core/di/injection.dart frontend/lib/main.dart
git commit -m "feat: wire ConnectivityNotifier in DI and initialize on app start"
```
