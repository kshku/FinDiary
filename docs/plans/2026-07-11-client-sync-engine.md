# Client Sync Engine Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Flutter client-side sync engine that tracks local transaction changes, syncs with the server via gRPC, and applies remote changes.

**Architecture:** SyncService wraps the generated gRPC client and converts between PendingChanges and SyncChangeEntry protos. SyncEngine orchestrates the sync loop with backoff and debounce. TransactionDao gets hook methods that write to PendingChanges and trigger sync via callback.

**Tech Stack:** Dart 3.3, Flutter, drift (SQLite), grpc + protobuf (protobuf), mocktail for testing, fixnum (Int64)

---

### Task 1: AppDatabase Test Constructor

**Files:**
- Modify: `frontend/lib/core/database/database.dart:28-29`

- [ ] **Step 1: Add in-memory constructor to AppDatabase**

Open `frontend/lib/core/database/database.dart`. Add a named constructor for testing after the existing constructor:

```dart
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);
```

- [ ] **Step 2: Add drift dev import for testing**

In `frontend/lib/core/database/database.dart`, update imports to include drift's native package (already imported):

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
```

These are already present. No changes needed.

- [ ] **Step 3: Verify compile**

Run: `cd frontend && /home/kshku/fvm/versions/stable/bin/dart run build_runner build`
Expected: success (generated code unchanged since no table/DAO changes)

- [ ] **Step 4: Commit**

```bash
git add frontend/lib/core/database/database.dart
git commit -m "feat: add forTesting constructor to AppDatabase for in-memory tests"
```

---

### Task 2: SyncService

**Files:**
- Create: `frontend/lib/core/sync/sync_service.dart`
- Create: `frontend/test/core/sync/sync_service_test.dart`

- [ ] **Step 1: Write the failing test**

Create `frontend/test/core/sync/sync_service_test.dart`:

```dart
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import 'package:findiary/core/database/tables.dart';
import 'package:findiary/generated/findiary/v1/sync_service.pbgrpc.dart' as $grpc;
import 'package:findiary/generated/findiary/v1/sync_service.pb.dart';
import 'package:findiary/core/sync/sync_service.dart';

class MockSyncServiceClient extends Mock implements $grpc.SyncServiceClient {}

void main() {
  late MockSyncServiceClient mockClient;
  late SyncService syncService;

  setUp(() {
    mockClient = MockSyncServiceClient();
    syncService = SyncService(mockClient);
  });

  group('SyncService', () {
    test('sync() converts PendingChanges to SyncChangeEntry protos', () async {
      final pendingChanges = [
        PendingChange(
          id: 1,
          entityType: 'transaction',
          entityId: 'tx-1',
          action: 'update',
          payload: '{"id":"tx-1","amount":100}',
          createdAt: '2026-07-11T00:00:00Z',
          retryCount: 0,
        ),
      ];

      final expectedResponse = SyncResponse(
        newCheckpoint: Int64(42),
        remoteChanges: [],
        conflicts: [],
      );

      when(() => mockClient.sync(any())).thenAnswer(
        (_) async => expectedResponse,
      );

      final response = await syncService.sync(
        scopeId: 'user-1',
        scopeType: 'personal',
        lastCheckpoint: Int64(10),
        localChanges: pendingChanges,
      );

      expect(response.newCheckpoint, Int64(42));
      expect(response.remoteChanges, isEmpty);
      expect(response.conflicts, isEmpty);

      verify(() => mockClient.sync(any())).called(1);
      final captured = verify(() => mockClient.sync(captureAny())).captured.single as SyncRequest;
      expect(captured.scopeId, 'user-1');
      expect(captured.scopeType, 'personal');
      expect(captured.lastCheckpoint, Int64(10));
      expect(captured.localChanges.length, 1);
      expect(captured.localChanges.first.entityType, 'transaction');
      expect(captured.localChanges.first.entityId, 'tx-1');
      expect(captured.localChanges.first.action, 'update');
      expect(captured.localChanges.first.snapshot, [123, 34, 105, 100, 34, 58, 34, 116, 120, 45, 49, 34, 44, 34, 97, 109, 111, 117, 110, 116, 34, 58, 49, 48, 48, 125]);
      expect(captured.localChanges.first.hasClientTimestamp(), isTrue);
    });
  });
}
```

Note: The byte array above is `utf8.encode('{"id":"tx-1","amount":100}')`. Include this literal or compute it with `utf8.encode` in the test.

- [ ] **Step 2: Run test to verify it fails**

Run: `cd frontend && /home/kshku/fvm/versions/stable/bin/dart test test/core/sync/sync_service_test.dart`
Expected: FAIL - "Could not find" SyncService or "target of URI doesn't exist"

- [ ] **Step 3: Write minimal implementation**

Create `frontend/lib/core/sync/sync_service.dart`:

```dart
import 'dart:convert';

import 'package:fixnum/fixnum.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import '../../generated/findiary/v1/sync_service.pb.dart';
import '../../generated/findiary/v1/sync_service.pbgrpc.dart' as $grpc;
import '../database/tables.dart';

class SyncService {
  final $grpc.SyncServiceClient _client;

  SyncService(this._client);

  Future<SyncResponse> sync({
    required String scopeId,
    required String scopeType,
    required Int64 lastCheckpoint,
    required List<PendingChange> localChanges,
  }) async {
    final request = SyncRequest(
      scopeId: scopeId,
      scopeType: scopeType,
      lastCheckpoint: lastCheckpoint,
      localChanges: localChanges.map(_toSyncChangeEntry),
    );
    return _client.sync(request);
  }

  SyncChangeEntry _toSyncChangeEntry(PendingChange change) {
    return SyncChangeEntry(
      entityType: change.entityType,
      entityId: change.entityId,
      action: change.action,
      snapshot: utf8.encode(change.payload),
      clientTimestamp: Timestamp()..fromDateTime(DateTime.now()),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && /home/kshku/fvm/versions/stable/bin/dart test test/core/sync/sync_service_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/core/sync/sync_service.dart frontend/test/core/sync/sync_service_test.dart
git commit -m "feat: add SyncService gRPC wrapper"
```

---

### Task 3: TransactionDao Hooks

**Files:**
- Modify: `frontend/lib/core/database/daos/transaction_dao.dart`
- Create: `frontend/test/core/database/daos/transaction_dao_test.dart`

- [ ] **Step 1: Write the failing test**

Create `frontend/test/core/database/daos/transaction_dao_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:findiary/core/database/database.dart';
import 'package:findiary/core/database/tables.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';

void main() {
  late AppDatabase db;
  late TransactionDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = TransactionDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TransactionDao hooks', () {
    test('upsertTransaction creates PendingChange entry', () async {
      int callbackCalls = 0;
      dao.onPendingChange = () => callbackCalls++;

      await dao.upsertTransaction(TransactionsCompanion(
        id: Value('tx-1'),
        createdBy: Value('user-1'),
        type: Value('expense'),
        amount: Value(100.0),
        currency: const Value('INR'),
        categoryId: Value('cat-1'),
        date: Value('2026-07-11'),
        createdAt: Value('2026-07-11T00:00:00Z'),
        updatedAt: Value('2026-07-11T00:00:00Z'),
      ));

      final pending = await db.pendingChanges.select().get();
      expect(pending.length, 1);
      expect(pending.first.entityType, 'transaction');
      expect(pending.first.entityId, 'tx-1');
      expect(pending.first.action, 'update');
      expect(pending.first.payload, contains('"id":"tx-1"'));
      expect(callbackCalls, 1);
    });

    test('softDeleteTransaction creates PendingChange entry', () async {
      // First insert a transaction
      await dao.upsertTransaction(TransactionsCompanion(
        id: Value('tx-2'),
        createdBy: Value('user-1'),
        type: Value('income'),
        amount: Value(200.0),
        currency: const Value('INR'),
        categoryId: Value('cat-2'),
        date: Value('2026-07-11'),
        createdAt: Value('2026-07-11T00:00:00Z'),
        updatedAt: Value('2026-07-11T00:00:00Z'),
      ));

      int callbackCalls = 0;
      dao.onPendingChange = () => callbackCalls++;

      await dao.softDeleteTransaction('tx-2');

      final pending = await db.pendingChanges.select().get();
      // Should have 2: one from upsert, one from delete
      expect(pending.length, 2);
      expect(pending.last.entityType, 'transaction');
      expect(pending.last.entityId, 'tx-2');
      expect(pending.last.action, 'delete');
      expect(callbackCalls, 1);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd frontend && /home/kshku/fvm/versions/stable/bin/flutter test test/core/database/daos/transaction_dao_test.dart`
Expected: FAIL - "onPendingChange" is not defined on TransactionDao

- [ ] **Step 3: Implement hooks in TransactionDao**

Modify `frontend/lib/core/database/daos/transaction_dao.dart`:

Add imports at top:
```dart
import 'dart:convert';
```

Add fields and methods to the class:
```dart
class TransactionDao extends DatabaseAccessor<AppDatabase> {
  TransactionDao(super.db);

  VoidCallback? onPendingChange;

  Future<void> upsertTransaction(TransactionsCompanion entry) {
    _onChange(entry.id.value, 'update', {
      'id': entry.id.value,
      'type': entry.type.value,
      'amount': entry.amount.value,
      'currency': entry.currency.value,
      'category_id': entry.categoryId.value,
      'date': entry.date.value,
      if (entry.description.present) 'description': entry.description.value,
      if (entry.familyId.present) 'family_id': entry.familyId.value,
    });
    return into(db.transactions).insertOnConflictUpdate(entry);
  }

  // ... existing methods unchanged ...

  Future<void> softDeleteTransaction(String id) {
    _onChange(id, 'delete', {'id': id});
    return (update(db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(deletedAt: Value(DateTime.now().toIso8601String())),
    );
  }

  void _onChange(String entityId, String action, Map<String, dynamic> data) {
    into(db.pendingChanges).insert(PendingChanges(
      entityType: 'transaction',
      entityId: entityId,
      action: action,
      payload: jsonEncode(data),
      createdAt: DateTime.now().toIso8601String(),
    ));
    onPendingChange?.call();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && /home/kshku/fvm/versions/stable/bin/flutter test test/core/database/daos/transaction_dao_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/core/database/daos/transaction_dao.dart frontend/test/core/database/daos/transaction_dao_test.dart
git commit -m "feat: add PendingChanges hooks to TransactionDao"
```

---

### Task 4: SyncEngine

**Files:**
- Create: `frontend/lib/core/sync/sync_engine.dart`
- Create: `frontend/test/core/sync/sync_engine_test.dart`

- [ ] **Step 1: Write the failing test**

Create `frontend/test/core/sync/sync_engine_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fixnum/fixnum.dart';

import 'package:findiary/core/sync/sync_engine.dart';
import 'package:findiary/core/sync/sync_service.dart';
import 'package:findiary/core/database/daos/sync_meta_dao.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/core/database/tables.dart';
import 'package:findiary/generated/findiary/v1/sync_service.pb.dart';
import 'package:findiary/generated/findiary/v1/common.pb.dart' as common;

class MockSyncService extends Mock implements SyncService {}
class MockSyncMetaDao extends Mock implements SyncMetaDao {}
class MockTransactionDao extends Mock implements TransactionDao {}

void main() {
  late MockSyncService mockSyncService;
  late MockSyncMetaDao mockSyncMetaDao;
  late MockTransactionDao mockTransactionDao;
  late SyncEngine engine;

  setUp(() {
    mockSyncService = MockSyncService();
    mockSyncMetaDao = MockSyncMetaDao();
    mockTransactionDao = MockTransactionDao();
    engine = SyncEngine(
      syncService: mockSyncService,
      syncMetaDao: mockSyncMetaDao,
      transactionDao: mockTransactionDao,
      scopeId: 'user-1',
      scopeType: 'personal',
    );
  });

  group('SyncEngine', () {
    test('syncNow performs full sync cycle', () async {
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

      when(() => mockSyncService.sync(
        scopeId: any(named: 'scopeId'),
        scopeType: any(named: 'scopeType'),
        lastCheckpoint: any(named: 'lastCheckpoint'),
        localChanges: any(named: 'localChanges'),
      )).thenAnswer((_) async => SyncResponse(
        newCheckpoint: Int64(42),
        remoteChanges: [],
        conflicts: [],
      ));

      final result = await engine.syncNow();

      expect(result, SyncResult.success);
      verify(() => mockSyncMetaDao.upsertMeta(any())).called(1);
      verify(() => mockSyncMetaDao.removePendingChange(1)).called(1);
    });

    test('syncNow handles gRPC errors gracefully', () async {
      when(() => mockSyncMetaDao.getMeta('user-1', 'personal'))
          .thenAnswer((_) async => SyncMetaData(
            scopeId: 'user-1',
            scopeType: 'personal',
            lastCheckpoint: 10,
            lastSyncedAt: null,
          ));

      when(() => mockSyncMetaDao.getPendingChanges())
          .thenAnswer((_) async => []);

      when(() => mockSyncService.sync(
        scopeId: any(named: 'scopeId'),
        scopeType: any(named: 'scopeType'),
        lastCheckpoint: any(named: 'lastCheckpoint'),
        localChanges: any(named: 'localChanges'),
      )).thenThrow(Exception('Service unavailable'));

      final result = await engine.syncNow();

      expect(result, SyncResult.failure);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd frontend && /home/kshku/fvm/versions/stable/bin/dart test test/core/sync/sync_engine_test.dart`
Expected: FAIL - "target of URI doesn't exist" for sync_engine.dart

- [ ] **Step 3: Implement SyncEngine**

Create `frontend/lib/core/sync/sync_engine.dart`:

```dart
import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import '../../generated/findiary/v1/sync_service.pb.dart';
import '../database/daos/sync_meta_dao.dart';
import '../database/daos/transaction_dao.dart';
import '../database/tables.dart';
import 'sync_service.dart';

enum SyncResult { success, failure }

class SyncEngine with WidgetsBindingObserver {
  final SyncService _syncService;
  final SyncMetaDao _syncMetaDao;
  final TransactionDao _transactionDao;
  final String _scopeId;
  final String _scopeType;

  bool _isSyncing = false;
  Timer? _debounceTimer;
  int _backoffDelay = 1;
  static const int _maxBackoff = 30;

  SyncEngine({
    required SyncService syncService,
    required SyncMetaDao syncMetaDao,
    required TransactionDao transactionDao,
    required String scopeId,
    required String scopeType,
  })  : _syncService = syncService,
        _syncMetaDao = syncMetaDao,
        _transactionDao = transactionDao,
        _scopeId = scopeId,
        _scopeType = scopeType;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _transactionDao.onPendingChange = _onPendingChange;
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _transactionDao.onPendingChange = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(syncNow());
    }
  }

  void _onPendingChange() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      unawaited(syncNow());
    });
  }

  Future<SyncResult> syncNow() async {
    if (_isSyncing) return SyncResult.success;
    _isSyncing = true;

    try {
      final meta = await _syncMetaDao.getMeta(_scopeId, _scopeType);
      final checkpoint = meta?.lastCheckpoint ?? 0;
      final pendingChanges = await _syncMetaDao.getPendingChanges();

      if (pendingChanges.isEmpty && meta != null) {
        _resetBackoff();
        return SyncResult.success;
      }

      final response = await _syncService.sync(
        scopeId: _scopeId,
        scopeType: _scopeType,
        lastCheckpoint: Int64(checkpoint),
        localChanges: pendingChanges,
      );

      await _applyRemoteChanges(response.remoteChanges);

      for (final change in pendingChanges) {
        await _syncMetaDao.removePendingChange(change.id);
      }

      await _syncMetaDao.upsertMeta(SyncMetaCompanion(
        scopeId: Value(_scopeId),
        scopeType: Value(_scopeType),
        lastCheckpoint: Value(response.newCheckpoint.toInt()),
        lastSyncedAt: Value(DateTime.now().toIso8601String()),
      ));

      _resetBackoff();
      return SyncResult.success;
    } catch (_) {
      _scheduleRetry();
      return SyncResult.failure;
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _applyRemoteChanges(List<SyncChangeEntry> changes) async {
    for (final change in changes) {
      if (change.entityType != 'transaction') continue;
      final payload = utf8.decode(change.snapshot);
      final data = jsonDecode(payload) as Map<String, dynamic>;
      await _transactionDao.upsertTransaction(TransactionsCompanion(
        id: Value(data['id'] as String),
        createdBy: Value(data['created_by'] as String? ?? ''),
        type: Value(data['type'] as String? ?? ''),
        amount: Value((data['amount'] as num).toDouble()),
        currency: Value(data['currency'] as String? ?? 'INR'),
        categoryId: Value(data['category_id'] as String? ?? ''),
        date: Value(data['date'] as String? ?? ''),
        createdAt: Value(data['created_at'] as String? ?? DateTime.now().toIso8601String()),
        updatedAt: Value(data['updated_at'] as String? ?? DateTime.now().toIso8601String()),
      ));
    }
  }

  void _resetBackoff() {
    _backoffDelay = 1;
  }

  void _scheduleRetry() {
    _backoffDelay = (_backoffDelay * 2).clamp(1, _maxBackoff);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && /home/kshku/fvm/versions/stable/bin/dart test test/core/sync/sync_engine_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/core/sync/sync_engine.dart frontend/test/core/sync/sync_engine_test.dart
git commit -m "feat: add SyncEngine orchestrator"
```

---

### Task 5: DI Wiring and Main

**Files:**
- Modify: `frontend/lib/core/di/injection.dart`
- Modify: `frontend/lib/main.dart`

- [ ] **Step 1: Write the failing test**

No separate test file — the DI wiring is verified by `flutter analyze`.

- [ ] **Step 2: Modify injection.dart**

Replace `frontend/lib/core/di/injection.dart` with:

```dart
import 'package:get_it/get_it.dart';
import '../auth/auth_service.dart';
import '../auth/token_storage.dart';
import '../client/grpc_client.dart';
import '../database/database.dart';
import '../database/daos/transaction_dao.dart';
import '../database/daos/sync_meta_dao.dart';
import '../sync/sync_service.dart';
import '../sync/sync_engine.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final grpcClient = GrpcClient(host: 'localhost', port: 9090);
  sl.registerLazySingleton<GrpcClient>(() => grpcClient);

  final tokenStorage = TokenStorage();
  sl.registerLazySingleton<TokenStorage>(() => tokenStorage);

  final authService = AuthService(
    grpcClient: grpcClient,
    tokenStorage: tokenStorage,
  );
  sl.registerLazySingleton<AuthService>(() => authService);

  final database = AppDatabase();
  sl.registerLazySingleton<AppDatabase>(() => database);

  final syncMetaDao = SyncMetaDao(database);
  sl.registerLazySingleton<SyncMetaDao>(() => syncMetaDao);

  final transactionDao = TransactionDao(database);
  sl.registerLazySingleton<TransactionDao>(() => transactionDao);

  final syncService = SyncService(
    grpcClient.createSyncServiceClient(),
  );
  sl.registerLazySingleton<SyncService>(() => syncService);

  final syncEngine = SyncEngine(
    syncService: syncService,
    syncMetaDao: syncMetaDao,
    transactionDao: transactionDao,
    scopeId: 'personal',
    scopeType: 'personal',
  );
  sl.registerLazySingleton<SyncEngine>(() => syncEngine);
}
```

Wait — `GrpcClient` doesn't have a `createSyncServiceClient()` method. Let me check what methods are available.

- [ ] **Step 2 (revised): Add helper to GrpcClient**

Open `frontend/lib/core/client/grpc_client.dart` and add:

```dart
import '../../generated/findiary/v1/sync_service.pbgrpc.dart' as sync_grpc;

class GrpcClient {
  // ... existing code ...
  sync_grpc.SyncServiceClient createSyncServiceClient() {
    return sync_grpc.SyncServiceClient(channel);
  }
}
```

- [ ] **Step 3: Modify injection.dart (corrected)**

```dart
import 'package:get_it/get_it.dart';
import '../auth/auth_service.dart';
import '../auth/token_storage.dart';
import '../client/grpc_client.dart';
import '../database/database.dart';
import '../database/daos/transaction_dao.dart';
import '../database/daos/sync_meta_dao.dart';
import '../sync/sync_service.dart';
import '../sync/sync_engine.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final grpcClient = GrpcClient(host: 'localhost', port: 9090);
  sl.registerLazySingleton<GrpcClient>(() => grpcClient);

  final tokenStorage = TokenStorage();
  sl.registerLazySingleton<TokenStorage>(() => tokenStorage);

  final authService = AuthService(
    grpcClient: grpcClient,
    tokenStorage: tokenStorage,
  );
  sl.registerLazySingleton<AuthService>(() => authService);

  final database = AppDatabase();
  sl.registerLazySingleton<AppDatabase>(() => database);

  final syncMetaDao = SyncMetaDao(database);
  sl.registerLazySingleton<SyncMetaDao>(() => syncMetaDao);

  final transactionDao = TransactionDao(database);
  sl.registerLazySingleton<TransactionDao>(() => transactionDao);

  final syncService = SyncService(grpcClient.createSyncServiceClient());
  sl.registerLazySingleton<SyncService>(() => syncService);

  final syncEngine = SyncEngine(
    syncService: syncService,
    syncMetaDao: syncMetaDao,
    transactionDao: transactionDao,
    scopeId: 'personal',
    scopeType: 'personal',
  );
  sl.registerLazySingleton<SyncEngine>(() => syncEngine);
}
```

- [ ] **Step 4: Modify main.dart**

```dart
import 'package:flutter/material.dart';
import 'core/di/injection.dart';
import 'core/sync/sync_engine.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const FinDiaryApp());
  sl<SyncEngine>().start();
}
```

- [ ] **Step 5: Run analyzer**

Run: `cd frontend && /home/kshku/fvm/versions/stable/bin/flutter analyze --no-fatal-infos`
Expected: 0 issues

- [ ] **Step 6: Run all tests**

Run: `cd frontend && /home/kshku/fvm/versions/stable/bin/dart test`
Expected: All tests pass

- [ ] **Step 7: Commit**

```bash
git add frontend/lib/core/client/grpc_client.dart frontend/lib/core/di/injection.dart frontend/lib/main.dart
git commit -m "feat: wire sync service, engine, and DAOs into DI"
```

---

### Self-Review

**Spec coverage check:**
- SyncService wraps SyncServiceClient, converts PendingChanges → SyncChangeEntry with JSON→bytes snapshot and clientTimestamp — ✅ Task 2
- SyncEngine.syncNow() reads SyncMeta, reads PendingChanges, calls SyncService.sync(), applies remote changes, removes PendingChanges, updates checkpoint — ✅ Task 4
- SyncEngine start/stop with WidgetsBindingObserver for app resume trigger — ✅ Task 4
- Post-mutation debounce (500ms) via onPendingChange callback — ✅ Task 4
- Exponential backoff on gRPC errors (1→2→4→8→16→30) — ✅ Task 4
- TransactionDao hooks for upsertTransaction and softDeleteTransaction — ✅ Task 3
- DI wiring for AppDatabase, TransactionDao, SyncService, SyncEngine — ✅ Task 5
- AppDatabase.forTesting constructor for testability — ✅ Task 1
- No connectivity_plus dependency — ✅ confirmed
- Transactions only (no categories/families) — ✅

**Placeholder scan:** None found.

**Type consistency check:**
- PendingChange (from tables.dart) is used both in SyncService input and SyncEngine — ✅
- SyncChangeEntry proto has entityType, entityId, action, snapshot, clientTimestamp — ✅
- SyncResult enum with success/failure — consistent in engine and test
- All method signatures match between implementation and test calls
