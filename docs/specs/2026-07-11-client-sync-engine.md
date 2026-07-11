# Client Sync Engine Design

## Overview

Build the Flutter client side of the sync feature. The server-side sync (proto, domain, repository, handler, wiring) is already complete. This spec covers the client half: tracking local changes, communicating with the server sync endpoint, and applying remote changes to the local database.

## Scope

**Transactions only.** Categories and families are relatively static metadata. They can be added in a later phase.

## Architecture

Three classes in `core/sync/`:

```
SyncService   → gRPC wrapper, encodes/decodes between PendingChanges and SyncChangeEntry protos
SyncEngine    → Orchestrator: reads pending changes, calls SyncService, applies remote changes, updates checkpoint
TransactionDao hooks → After each local mutation, writes to PendingChanges table and triggers sync
```

No `connectivity_plus` dependency. Server unavailability is detected via gRPC errors and handled with exponential backoff.

## SyncService

Wraps the generated `SyncServiceClient`. Single public method:

Note on scope: For personal transactions, `scopeType = "personal"` and `scopeId = userUUID` (the user's own ID from the auth response). The server already uses this convention — scopeId maps to the user ID for personal scope, and the family ID for family scope.

```dart
Future<SyncResponse> sync({
  required String scopeId,
  required String scopeType,
  Int64 lastCheckpoint,
  List<PendingChange> localChanges,
});
```

Responsibilities:
- Convert each `PendingChange` (entityType, entityId, action, JSON payload) into a `SyncChangeEntry` proto
- Serialize entity JSON → proto bytes for `SyncChangeEntry.snapshot`
- Set `clientTimestamp` to current time
- Call the unary `Sync` RPC
- Return raw `SyncResponse` for SyncEngine to process

## SyncEngine

Orchestrator. Single sync loop:

1. On trigger (app resume, post-mutation, connectivity restored):
   - If sync already in progress, skip
   - Read `SyncMeta` for `("personal", "personal")` scope
   - Read all `PendingChanges` ordered by `id ASC`
   - Call `SyncService.sync()`
2. On success:
   - For each `remoteChange` in response: deserialize snapshot proto → upsert into TransactionDao
   - Remove all processed PendingChanges from DB
   - Update SyncMeta.lastCheckpoint to `response.newCheckpoint`
   - Log conflicts for telemetry
3. On gRPC error:
   - Exponential backoff (1s, 2s, 4s, 8s, 16s, 30s cap, reset on success)
   - PendingChanges remain for retry

Methods:
```dart
Future<SyncResult> syncNow();    // manual trigger
void start();                     // register app lifecycle listener
void dispose();                   // clean up
```

## TransactionDao Hooks

Every mutation method gets a side effect:

- `upsertTransaction` → `syncMetaDao.addPendingChange(entityType: "transaction", entityId, action: "create"/"update", payload: jsonEncode(entity))`
- `softDeleteTransaction` → `syncMetaDao.addPendingChange(entityType: "transaction", entityId, action: "delete", payload: jsonEncode(entity))`

After writing PendingChanges, debounced call to `SyncEngine.syncNow()` (500ms debounce to batch rapid edits).

## Triggers

1. **App resume** — `WidgetsBindingObserver.didChangeAppLifecycleState(AppLifecycleState.resumed)` → `SyncEngine.syncNow()`
2. **Post-mutation** — After DAO hook writes PendingChanges → `SyncEngine.syncNow()` (debounced 500ms)
3. **Error retry** — Backoff timer resets on success; next trigger reattempts

## Error Handling

- `Unavailable`, `DeadlineExceeded`, `ResourceExhausted`: backoff, retry on next trigger
- `Unauthenticated`: trigger token refresh, retry once
- All other errors: log, skip, retry on next trigger
- `SyncEngine.syncNow()` never throws — all errors caught internally

## DI Wiring

Register new singletons in `injection.dart`:
- `AppDatabase` (not currently in DI)
- `TransactionDao` (needs SyncMetaDao for hooks)
- `SyncService` (from existing GrpcClient)
- `SyncEngine` (singleton, started after runApp)

Init flow: `initDependencies()` creates all. `main()` calls `SyncEngine.start()` after `runApp`.

## File Changes

**New files:**
- `frontend/lib/core/sync/sync_service.dart` — gRPC wrapper
- `frontend/lib/core/sync/sync_engine.dart` — orchestrator

**Modified files:**
- `frontend/lib/core/database/daos/transaction_dao.dart` — add hooks
- `frontend/lib/core/di/injection.dart` — register new dependencies
- `frontend/lib/main.dart` — start sync engine

## Non-Goals

- No sync status UI (last synced, pending count)
- No connectivity_plus dependency
- No sync for categories or families
- No category schema changes (syncStatus columns, soft-delete)
- No conflict display UI
- No manual pull-to-refresh
