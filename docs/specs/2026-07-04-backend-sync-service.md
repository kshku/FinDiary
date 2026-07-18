# Backend Sync Service — Phase 3a

## Overview

Implements the server-side sync protocol for FinDiary's offline-first architecture. Users can create, update, and delete transactions and categories offline; the sync service reconciles these changes with the server.

The existing `change_log` table (migration 000005) already records mutations. This phase adds the sync protocol, checkpoint tracking, and LWW conflict resolution.

## Scope

- Sync protobuf messages (`sync_service.proto`)
- `SyncCheckpoint` domain entity + repository
- `SyncService` — orchestrates sync per scope
- `SyncHandler` — gRPC endpoint
- Migration `000007` for `sync_checkpoints` table
- Wire into server startup
- Unit/integration tests

**Out of scope:** Flutter sync engine (Phase 3b), UI changes (3c+).

## Data Layer

### Migration `000007` — `sync_checkpoints`

```sql
CREATE TABLE IF NOT EXISTS sync_checkpoints (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    scope_id UUID,                      -- NULL for personal scope
    scope_type VARCHAR(20) NOT NULL CHECK (scope_type IN ('personal', 'family')),
    last_checkpoint BIGINT NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_sync_checkpoints_unique
    ON sync_checkpoints(user_id, coalesce(scope_id, '00000000-0000-0000-0000-000000000000'), scope_type);
```

### Domain Entity

`internal/domain/sync.go`:

```go
type SyncScope struct {
    ScopeID   string // "" for personal
    ScopeType string // "personal" | "family"
}

type SyncCheckpoint struct {
    ID             int64
    UserID         string
    ScopeID        *string
    ScopeType      string
    LastCheckpoint int64
    UpdatedAt      string
}

type ChangeLogEntry struct {
    ID              int64
    FamilyID        *string
    ChangedBy       string
    EntityType      string
    EntityID        string
    Action          string    // "create" | "update" | "delete"
    Snapshot        string    // JSON
    ChangedFields   []string
    ServerTimestamp  string
    ClientTimestamp  string
}
```

### Repository

`internal/repository/sync_repo.go` — interfaces:

- `GetOrCreateCheckpoint(ctx, userID, scopeID, scopeType) → (*SyncCheckpoint, error)` — manual upsert (try UPDATE, INSERT if no rows affected) since scope_id can be NULL and ON CONFLICT won't bind
- `UpdateCheckpoint(ctx, userID, scopeID, scopeType, newCheckpoint) → error`
- `GetChangesSince(ctx, scopeID, checkpointID) → ([]ChangeLogEntry, error)` — query change_log WHERE id > checkpoint AND (family_id = scope_id OR (family_id IS NULL AND scope_id IS NULL))
- `AppendChangeLog(ctx, entries []ChangeLogEntry) → error` (idempotent — deduplicate by entity_id + client_timestamp)

## Protocol

### `proto/findiary/v1/sync_service.proto`

```protobuf
service SyncService {
  rpc Sync(SyncRequest) returns (SyncResponse);
}

message SyncRequest {
  string scope_id = 1;           // "" for personal
  string scope_type = 2;         // "personal" | "family"
  int64 last_checkpoint = 3;
  repeated ChangeEntry local_changes = 4;
}

message SyncResponse {
  int64 new_checkpoint = 1;
  repeated ChangeEntry remote_changes = 2;
  repeated ConflictInfo conflicts = 3;
}

message ChangeEntry {
  string entity_type = 1;
  string entity_id = 2;
  string action = 3;
  bytes snapshot = 4;
  google.protobuf.Timestamp client_timestamp = 5;
  repeated string changed_fields = 6;
}

message ConflictInfo {
  string entity_type = 1;
  string entity_id = 2;
  string field = 3;
  string local_value = 4;
  string server_value = 5;
}
```

## Service Layer

`internal/service/sync_service.go`:

```
Sync(ctx, userID, req) → (SyncResponse, error):
  1. Validate scope
     - If "personal": user must own the data
     - If "family": user must be a member
  2. Get or create checkpoint for this user+scope
  3. Apply local changes (in order):
     For each ChangeEntry:
       a. Parse entity_type (transaction, category)
       b. Look up existing entity by entity_id
       c. If "create" and exists → treat as update (LWW)
       d. If "update"/"delete" and doesn't exist → return ConflictInfo
       e. LWW: compare client_timestamp vs entity.updated_at
          - If client is newer: apply change, append to change_log
          - If server is newer: skip, return ConflictInfo
          - Tie: server wins (skip, return ConflictInfo)
       f. Append applied changes to change_log
  4. Query remote changes:
     SELECT * FROM change_log WHERE id > checkpoint AND (family_id = scope_id OR (family_id IS NULL AND scope_type = 'personal'))
     ORDER BY id ASC
  5. Build SyncResponse with:
     - new_checkpoint = max(remote_changes.id, local checkpoint)
     - remote_changes = serialized ChangeEntry list
     - conflicts = any LWW conflicts found
  6. Update checkpoint to new_checkpoint
```

### LWW Details

- Granularity: entity-level (not field-level for Phase 3a)
- Comparison: `client_timestamp` vs `updated_at`
- Server tiebreak: timestamps within 1ms tolerance → server wins
- Applied changes always go to `change_log` regardless of winner/loser

## Handler

`internal/api/sync_handler.go` — gRPC handler implementing `SyncServiceServer`:

```go
type SyncHandler struct {
    svc *service.SyncService
}
```

## Wiring

In `internal/server/server.go`:

- Instantiate `repository.NewSyncRepo(db)`
- Instantiate `service.NewSyncService(syncRepo, txRepo, categoryRepo, familyRepo)`
- Instantiate `api.NewSyncHandler(svc)`
- Register `pbv1connect.NewSyncServiceHandler(handler)` on mux

## Testing

- `internal/repository/sync_repo_test.go` — test checkpoint CRUD, GetChangesSince with real DB
- `internal/service/sync_service_test.go` — unit test with mocks for sync logic

## Files Changed

| File | Action |
|------|--------|
| `backend/migrations/000007_create_sync_checkpoints.up.sql` | Create |
| `backend/migrations/000007_create_sync_checkpoints.down.sql` | Create |
| `backend/internal/domain/sync.go` | Create |
| `backend/internal/repository/sync_repo.go` | Create |
| `backend/internal/repository/sync_repo_test.go` | Create |
| `backend/internal/service/sync_service.go` | Create |
| `backend/internal/service/sync_service_test.go` | Create |
| `backend/internal/api/sync_handler.go` | Create |
| `backend/internal/server/server.go` | Edit |
| `proto/findiary/v1/sync_service.proto` | Create |
| `proto/buf.gen.yaml` | Edit (add sync service) |
| `frontend/lib/generated/...` | Regenerate |
