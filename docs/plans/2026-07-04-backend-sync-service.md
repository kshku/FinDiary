# Phase 3a: Backend Sync Service Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement server-side sync protocol — checkpoint tracking, change log querying, LWW conflict resolution, and gRPC sync endpoint.

**Architecture:** SyncService orchestrates sync per scope: applies local changes, queries remote changes from change_log, returns checkpoint. Repository handles checkpoints (manual upsert for NULL scope_id) and change_log queries.

**Tech Stack:** Go 1.26, connect-go, pgx/v5, golang-migrate, google.golang.org/protobuf.

---

### Task 1: Sync Proto + ChangeLog Domain

**Files:**
- Create: `proto/findiary/v1/sync_service.proto`
- Create: `backend/internal/domain/sync.go`

- [ ] **Step 1: Create sync_service.proto**

```protobuf
syntax = "proto3";

package findiary.v1;

option go_package = "github.com/kshku/findiary/backend/internal/api/findiary/v1";

import "google/protobuf/timestamp.proto";

message SyncRequest {
  string scope_id = 1;
  string scope_type = 2;
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

service SyncService {
  rpc Sync(SyncRequest) returns (SyncResponse);
}
```

- [ ] **Step 2: Add UnmarshalTransaction to domain/transaction.go**

In `backend/internal/domain/transaction.go`, add:

```go
func UnmarshalTransaction(data []byte) (*Transaction, error) {
    var tx Transaction
    if err := json.Unmarshal(data, &tx); err != nil {
        return nil, err
    }
    return &tx, nil
}
```

Also add the `encoding/json` import to the file if not present.

- [ ] **Step 3: Create domain/sync.go**

```go
package domain

import "time"

type SyncScope struct {
	ScopeID   string
	ScopeType string
}

type SyncCheckpoint struct {
	ID             int64
	UserID         string
	ScopeID        *string
	ScopeType      string
	LastCheckpoint int64
	UpdatedAt      time.Time
}

type ChangeLogEntry struct {
	ID              int64
	FamilyID        *string
	ChangedBy       string
	EntityType      string
	EntityID        string
	Action          string
	Snapshot        string
	ChangedFields   []string
	ServerTimestamp time.Time
	ClientTimestamp time.Time
}

type SyncChange struct {
	EntityType      string
	EntityID        string
	Action          string
	Snapshot        []byte
	ClientTimestamp time.Time
	ChangedFields   []string
}

type ConflictInfo struct {
	EntityType  string
	EntityID    string
	Field       string
	LocalValue  string
	ServerValue string
}
```

- [ ] **Step 3: Regenerate Go + Dart stubs**

Run: `cd frontend && buf generate ../proto`

Run: `cd proto && buf generate`

- [ ] **Step 4: Commit**

```bash
git add proto/findiary/v1/sync_service.proto backend/internal/domain/sync.go backend/internal/api/findiary/ frontend/lib/generated/
git commit -m "feat(sync): add sync proto and domain types"
```

---

### Task 2: Migration 000007 — Sync Checkpoints

**Files:**
- Create: `backend/migrations/000007_create_sync_checkpoints.up.sql`
- Create: `backend/migrations/000007_create_sync_checkpoints.down.sql`

- [ ] **Step 1: Create the up migration**

```sql
CREATE TABLE IF NOT EXISTS sync_checkpoints (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    scope_id UUID,
    scope_type VARCHAR(20) NOT NULL CHECK (scope_type IN ('personal', 'family')),
    last_checkpoint BIGINT NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_sync_checkpoints_unique
    ON sync_checkpoints(user_id, coalesce(scope_id, '00000000-0000-0000-0000-000000000000'), scope_type);
```

- [ ] **Step 2: Create the down migration**

```sql
DROP TABLE IF EXISTS sync_checkpoints;
```

- [ ] **Step 3: Commit**

```bash
git add backend/migrations/000007_create_sync_checkpoints.up.sql backend/migrations/000007_create_sync_checkpoints.down.sql
git commit -m "feat(sync): add sync_checkpoints migration"
```

---

### Task 3: Sync Repository

**Files:**
- Create: `backend/internal/repository/sync_repo.go`

- [ ] **Step 1: Write sync_repo.go**

```go
package repository

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/kshku/findiary/backend/internal/domain"
)

type SyncRepo struct {
	pool *pgxpool.Pool
}

func NewSyncRepo(pool *pgxpool.Pool) *SyncRepo {
	return &SyncRepo{pool: pool}
}

func (r *SyncRepo) GetOrCreateCheckpoint(ctx context.Context, userID string, scopeID *string, scopeType string) (*domain.SyncCheckpoint, error) {
	var rawScopeID *uuid.UUID
	if scopeID != nil {
		uid, err := uuid.Parse(*scopeID)
		if err != nil {
			return nil, fmt.Errorf("parse scope_id: %w", err)
		}
		rawScopeID = &uid
	}

	cp := &domain.SyncCheckpoint{}
	err := r.pool.QueryRow(ctx,
		`SELECT id, user_id, scope_id, scope_type, last_checkpoint, updated_at
		 FROM sync_checkpoints
		 WHERE user_id = $1 AND (scope_id = $2 OR (scope_id IS NULL AND $2 IS NULL)) AND scope_type = $3`,
		userID, rawScopeID, scopeType,
	).Scan(&cp.ID, &cp.UserID, &cp.ScopeID, &cp.ScopeType, &cp.LastCheckpoint, &cp.UpdatedAt)

	if err == nil {
		return cp, nil
	}

	if !strings.Contains(err.Error(), "no rows") {
		return nil, fmt.Errorf("query checkpoint: %w", err)
	}

	// No existing checkpoint — create
	cp = &domain.SyncCheckpoint{
		UserID:         userID,
		ScopeID:        scopeID,
		ScopeType:      scopeType,
		LastCheckpoint: 0,
		UpdatedAt:      time.Now().UTC(),
	}
	err = r.pool.QueryRow(ctx,
		`INSERT INTO sync_checkpoints (user_id, scope_id, scope_type, last_checkpoint, updated_at)
		 VALUES ($1, $2, $3, 0, $4)
		 RETURNING id, user_id, scope_id, scope_type, last_checkpoint, updated_at`,
		userID, rawScopeID, scopeType, cp.UpdatedAt,
	).Scan(&cp.ID, &cp.UserID, &cp.ScopeID, &cp.ScopeType, &cp.LastCheckpoint, &cp.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("create checkpoint: %w", err)
	}
	return cp, nil
}

func (r *SyncRepo) UpdateCheckpoint(ctx context.Context, userID string, scopeID *string, scopeType string, newCheckpoint int64) error {
	var rawScopeID *uuid.UUID
	if scopeID != nil {
		uid, err := uuid.Parse(*scopeID)
		if err != nil {
			return fmt.Errorf("parse scope_id: %w", err)
		}
		rawScopeID = &uid
	}

	_, err := r.pool.Exec(ctx,
		`UPDATE sync_checkpoints
		 SET last_checkpoint = $1, updated_at = NOW()
		 WHERE user_id = $2 AND (scope_id = $3 OR (scope_id IS NULL AND $3 IS NULL)) AND scope_type = $4`,
		newCheckpoint, userID, rawScopeID, scopeType,
	)
	if err != nil {
		return fmt.Errorf("update checkpoint: %w", err)
	}
	return nil
}

func (r *SyncRepo) GetChangesSince(ctx context.Context, scopeID *string, checkpointID int64) ([]domain.ChangeLogEntry, error) {
	var rawScopeID *uuid.UUID
	if scopeID != nil {
		uid, err := uuid.Parse(*scopeID)
		if err != nil {
			return nil, fmt.Errorf("parse scope_id: %w", err)
		}
		rawScopeID = &uid
	}

	rows, err := r.pool.Query(ctx,
		`SELECT id, family_id, changed_by, entity_type, entity_id, action, snapshot, changed_fields, server_timestamp, client_timestamp
		 FROM change_log
		 WHERE id > $1 AND (family_id = $2 OR (family_id IS NULL AND $2 IS NULL))
		 ORDER BY id ASC`,
		checkpointID, rawScopeID,
	)
	if err != nil {
		return nil, fmt.Errorf("query change_log: %w", err)
	}
	defer rows.Close()

	var entries []domain.ChangeLogEntry
	for rows.Next() {
		var e domain.ChangeLogEntry
		var familyID *uuid.UUID
		err := rows.Scan(&e.ID, &familyID, &e.ChangedBy, &e.EntityType, &e.EntityID, &e.Action, &e.Snapshot, &e.ChangedFields, &e.ServerTimestamp, &e.ClientTimestamp)
		if err != nil {
			return nil, fmt.Errorf("scan change_log row: %w", err)
		}
		if familyID != nil {
			fid := familyID.String()
			e.FamilyID = &fid
		}
		entries = append(entries, e)
	}
	return entries, nil
}

func (r *SyncRepo) AppendChangeLog(ctx context.Context, entry domain.ChangeLogEntry) error {
	var familyID *uuid.UUID
	if entry.FamilyID != nil {
		uid, err := uuid.Parse(*entry.FamilyID)
		if err != nil {
			return fmt.Errorf("parse family_id: %w", err)
		}
		familyID = &uid
	}

	_, err := r.pool.Exec(ctx,
		`INSERT INTO change_log (family_id, changed_by, entity_type, entity_id, action, snapshot, changed_fields, server_timestamp, client_timestamp)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
		familyID, entry.ChangedBy, entry.EntityType, entry.EntityID, entry.Action, entry.Snapshot, entry.ChangedFields, entry.ServerTimestamp, entry.ClientTimestamp,
	)
	if err != nil {
		return fmt.Errorf("append change_log: %w", err)
	}
	return nil
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/internal/repository/sync_repo.go
git commit -m "feat(sync): add sync repository with checkpoint and change_log queries"
```

---

### Task 4: Sync Repository + Service Tests

**Files:**
- Create: `backend/internal/repository/sync_repo_test.go`
- Modify: `backend/internal/repository/setup_test.go`

- [ ] **Step 1: Add change_log and sync_checkpoints to test schema**

In `setup_test.go`, after the `transactions` table and before the closing backtick, add:

```go
CREATE TABLE IF NOT EXISTS change_log (
    id BIGSERIAL PRIMARY KEY,
    family_id UUID REFERENCES families(id),
    changed_by UUID NOT NULL REFERENCES users(id),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('create', 'update', 'delete')),
    snapshot JSONB NOT NULL DEFAULT '{}',
    changed_fields TEXT[],
    server_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    client_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_change_log_family ON change_log(family_id);
CREATE INDEX IF NOT EXISTS idx_change_log_entity ON change_log(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_change_log_server_timestamp ON change_log(server_timestamp);

CREATE TABLE IF NOT EXISTS sync_checkpoints (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    scope_id UUID,
    scope_type VARCHAR(20) NOT NULL CHECK (scope_type IN ('personal', 'family')),
    last_checkpoint BIGINT NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_sync_checkpoints_unique
    ON sync_checkpoints(user_id, coalesce(scope_id, '00000000-0000-0000-0000-000000000000'), scope_type);
```

Also add `sync_checkpoints` to the TRUNCATE table list in `setupTestDB`:

```go
_, err = pool.Exec(context.Background(), "TRUNCATE TABLE sync_checkpoints, change_log, transactions, invitations, family_members, categories, families, users CASCADE")
```

- [ ] **Step 2: Write sync_repo_test.go**

```go
package repository_test

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/repository"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestSyncRepo_GetOrCreateCheckpoint(t *testing.T) {
	ctx := context.Background()
	db := setupTestDB(t)
	repo := repository.NewSyncRepo(db)

	user := createTestUser(t, ctx, db)

	personalScope := ""
	scopeType := "personal"

	cp, err := repo.GetOrCreateCheckpoint(ctx, user.ID, nil, scopeType)
	require.NoError(t, err)
	assert.Equal(t, user.ID, cp.UserID)
	assert.Nil(t, cp.ScopeID)
	assert.Equal(t, scopeType, cp.ScopeType)
	assert.Equal(t, int64(0), cp.LastCheckpoint)

	cp2, err := repo.GetOrCreateCheckpoint(ctx, user.ID, nil, scopeType)
	require.NoError(t, err)
	assert.Equal(t, cp.ID, cp2.ID)
	assert.Equal(t, int64(0), cp2.LastCheckpoint)
}

func TestSyncRepo_UpdateCheckpoint(t *testing.T) {
	ctx := context.Background()
	db := setupTestDB(t)
	repo := repository.NewSyncRepo(db)

	user := createTestUser(t, ctx, db)
	scopeType := "personal"

	cp, err := repo.GetOrCreateCheckpoint(ctx, user.ID, nil, scopeType)
	require.NoError(t, err)

	err = repo.UpdateCheckpoint(ctx, user.ID, nil, scopeType, 42)
	require.NoError(t, err)

	cp2, err := repo.GetOrCreateCheckpoint(ctx, user.ID, nil, scopeType)
	require.NoError(t, err)
	assert.Equal(t, int64(42), cp2.LastCheckpoint)
	assert.True(t, cp2.UpdatedAt.After(cp.UpdatedAt) || cp2.UpdatedAt.Equal(cp.UpdatedAt))
}

func TestSyncRepo_GetChangesSince(t *testing.T) {
	ctx := context.Background()
	db := setupTestDB(t)
	repo := repository.NewSyncRepo(db)

	user := createTestUser(t, ctx, db)

	// Insert personal-scope change_log entries (family_id = NULL)
	_, err := db.Exec(ctx,
		`INSERT INTO change_log (changed_by, entity_type, entity_id, action, snapshot)
		 VALUES ($1, 'transaction', $2, 'create', '{}')`,
		user.ID, uuid.New().String())
	require.NoError(t, err)

	_, err = db.Exec(ctx,
		`INSERT INTO change_log (changed_by, entity_type, entity_id, action, snapshot)
		 VALUES ($1, 'transaction', $2, 'update', '{"amount": 50}')`,
		user.ID, uuid.New().String())
	require.NoError(t, err)

	entries, err := repo.GetChangesSince(ctx, nil, 0)
	require.NoError(t, err)
	assert.Len(t, entries, 2)
	assert.Equal(t, "create", entries[0].Action)
	assert.Equal(t, "update", entries[1].Action)
}

func TestSyncRepo_AppendChangeLog(t *testing.T) {
	ctx := context.Background()
	db := setupTestDB(t)
	repo := repository.NewSyncRepo(db)

	user := createTestUser(t, ctx, db)
	now := time.Now().UTC()

	entry := domain.ChangeLogEntry{
		ChangedBy:       user.ID,
		EntityType:      "transaction",
		EntityID:        uuid.New().String(),
		Action:          "create",
		Snapshot:        `{"amount": 100}`,
		ChangedFields:   []string{"amount"},
		ClientTimestamp: now,
		ServerTimestamp: now,
	}

	err := repo.AppendChangeLog(ctx, entry)
	require.NoError(t, err)
}
```

- [ ] **Step 3: Run repository tests**

Run: `cd backend && go test ./internal/repository/ -run TestSyncRepo -v`

Expected: All tests pass

- [ ] **Step 4: Commit**

```bash
git add backend/internal/repository/sync_repo_test.go backend/internal/repository/setup_test.go
git commit -m "feat(sync): add sync repo tests"
```

---

### Task 5: Sync Service

**Files:**
- Create: `backend/internal/service/sync_service.go`

- [ ] **Step 1: Write sync_service.go**

```go
package service

import (
	"context"
	"fmt"
	"time"

	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/repository"
	"github.com/kshku/findiary/backend/pkg/validator"
)

type SyncService struct {
	syncRepo      *repository.SyncRepo
	txRepo        domain.TransactionRepository
	categoryRepo  domain.CategoryRepository
	familyRepo    domain.FamilyRepository
	userRepo      domain.UserRepository
}

func NewSyncService(
	syncRepo *repository.SyncRepo,
	txRepo domain.TransactionRepository,
	categoryRepo domain.CategoryRepository,
	familyRepo domain.FamilyRepository,
	userRepo domain.UserRepository,
) *SyncService {
	return &SyncService{
		syncRepo:     syncRepo,
		txRepo:       txRepo,
		categoryRepo: categoryRepo,
		familyRepo:   familyRepo,
		userRepo:     userRepo,
	}
}

type SyncResult struct {
	NewCheckpoint  int64
	RemoteChanges  []domain.ChangeLogEntry
	Conflicts      []domain.ConflictInfo
}

func (s *SyncService) Sync(ctx context.Context, userID string, scopeID string, scopeType string, lastCheckpoint int64, localChanges []domain.SyncChange) (*SyncResult, error) {
	if err := s.validateScope(ctx, userID, scopeID, scopeType); err != nil {
		return nil, err
	}

	scopePtr := scopeIDtoPtr(scopeID)

	cp, err := s.syncRepo.GetOrCreateCheckpoint(ctx, userID, scopePtr, scopeType)
	if err != nil {
		return nil, fmt.Errorf("get checkpoint: %w", err)
	}

	var conflicts []domain.ConflictInfo

	for _, ch := range localChanges {
		switch ch.Action {
		case "create", "update":
			conflict, err := s.applyUpsert(ctx, userID, scopePtr, ch)
			if err != nil {
				return nil, fmt.Errorf("apply %s %s: %w", ch.EntityType, ch.EntityID, err)
			}
			if conflict != nil {
				conflicts = append(conflicts, *conflict)
			}
		case "delete":
			conflict, err := s.applyDelete(ctx, userID, scopePtr, ch)
			if err != nil {
				return nil, fmt.Errorf("apply delete %s: %w", ch.EntityID, err)
			}
			if conflict != nil {
				conflicts = append(conflicts, *conflict)
			}
		}
	}

	remoteChanges, err := s.syncRepo.GetChangesSince(ctx, scopePtr, lastCheckpoint)
	if err != nil {
		return nil, fmt.Errorf("get remote changes: %w", err)
	}

	newCheckpoint := lastCheckpoint
	for _, rc := range remoteChanges {
		if rc.ID > newCheckpoint {
			newCheckpoint = rc.ID
		}
	}

	if err := s.syncRepo.UpdateCheckpoint(ctx, userID, scopePtr, scopeType, newCheckpoint); err != nil {
		return nil, fmt.Errorf("update checkpoint: %w", err)
	}

	return &SyncResult{
		NewCheckpoint: newCheckpoint,
		RemoteChanges: remoteChanges,
		Conflicts:     conflicts,
	}, nil
}

func (s *SyncService) Sync(ctx context.Context, userID string, scopeID string, scopeType string, lastCheckpoint int64, localChanges []domain.SyncChange) (*SyncResult, error) {
	if err := s.validateScope(ctx, userID, scopeID, scopeType); err != nil {
		return nil, err
	}

	scopePtr := scopeIDtoPtr(scopeID)

	cp, err := s.syncRepo.GetOrCreateCheckpoint(ctx, userID, scopePtr, scopeType)
	if err != nil {
		return nil, fmt.Errorf("get checkpoint: %w", err)
	}

	var conflicts []domain.ConflictInfo

	for _, ch := range localChanges {
		switch ch.Action {
		case "create", "update":
			conflict, err := s.applyUpsert(ctx, userID, scopePtr, ch)
			if err != nil {
				return nil, fmt.Errorf("apply %s %s: %w", ch.EntityType, ch.EntityID, err)
			}
			if conflict != nil {
				conflicts = append(conflicts, *conflict)
			}
		case "delete":
			conflict, err := s.applyDelete(ctx, userID, scopePtr, ch)
			if err != nil {
				return nil, fmt.Errorf("apply delete %s: %w", ch.EntityID, err)
			}
			if conflict != nil {
				conflicts = append(conflicts, *conflict)
			}
		}
	}

	remoteChanges, err := s.syncRepo.GetChangesSince(ctx, scopePtr, lastCheckpoint)
	if err != nil {
		return nil, fmt.Errorf("get remote changes: %w", err)
	}

	newCheckpoint := lastCheckpoint
	for _, rc := range remoteChanges {
		if rc.ID > newCheckpoint {
			newCheckpoint = rc.ID
		}
	}

	if err := s.syncRepo.UpdateCheckpoint(ctx, userID, scopePtr, scopeType, newCheckpoint); err != nil {
		return nil, fmt.Errorf("update checkpoint: %w", err)
	}

	return &SyncResult{
		NewCheckpoint:  newCheckpoint,
		RemoteChanges:  remoteChanges,
		Conflicts:      conflicts,
	}, nil
}

func (s *SyncService) validateScope(ctx context.Context, userID, scopeID, scopeType string) error {
	if scopeType != "personal" && scopeType != "family" {
		return fmt.Errorf("%w: scope_type must be personal or family", domain.ErrInvalidInput)
	}

	if _, err := s.userRepo.FindByID(ctx, userID); err != nil {
		return fmt.Errorf("%w: user not found", domain.ErrInvalidInput)
	}

	if scopeType == "family" && scopeID != "" {
		isMember, err := s.familyRepo.IsMember(ctx, scopeID, userID)
		if err != nil {
			return fmt.Errorf("check membership: %w", err)
		}
		if !isMember {
			return fmt.Errorf("%w: not a family member", domain.ErrForbidden)
		}
	}

	return nil
}

func (s *SyncService) applyUpsert(ctx context.Context, userID string, scopePtr *string, ch domain.SyncChange) (*domain.ConflictInfo, error) {
	switch ch.EntityType {
	case "transaction":
		return s.applyTransactionUpsert(ctx, userID, scopePtr, ch)
	case "category":
		return nil, nil
	default:
		return nil, fmt.Errorf("%w: unknown entity type %s", domain.ErrInvalidInput, ch.EntityType)
	}
}

func (s *SyncService) applyTransactionUpsert(ctx context.Context, userID string, scopePtr *string, ch domain.SyncChange) (*domain.ConflictInfo, error) {
	tx, err := domain.UnmarshalTransaction(ch.Snapshot)
	if err != nil {
		return nil, fmt.Errorf("unmarshal transaction: %w", err)
	}

	existing, err := s.txRepo.FindByID(ctx, ch.EntityID)
	if err != nil && !domain.IsNotFound(err) {
		return nil, err
	}

	if existing != nil && existing.DeletedAt != nil {
		return &domain.ConflictInfo{
			EntityType: "transaction",
			EntityID:   ch.EntityID,
			Field:      "deleted_at",
			ServerValue: "deleted",
		}, nil
	}

	if existing != nil {
		if !ch.ClientTimestamp.After(existing.UpdatedAt) {
			return &domain.ConflictInfo{
				EntityType: "transaction",
				EntityID:   ch.EntityID,
				Field:      "updated_at",
				LocalValue: ch.ClientTimestamp.Format(time.RFC3339),
				ServerValue: existing.UpdatedAt.Format(time.RFC3339),
			}, nil
		}
		now := time.Now().UTC().Format(time.RFC3339Nano)
		existing.Type = tx.Type
		existing.Amount = tx.Amount
		existing.Currency = tx.Currency
		existing.CategoryID = tx.CategoryID
		existing.Description = tx.Description
		existing.Date = tx.Date
		existing.UpdatedAt = now
		if err := s.txRepo.Update(ctx, existing); err != nil {
			return nil, err
		}
	} else {
		now := time.Now().UTC().Format(time.RFC3339Nano)
		tx.FamilyID = scopePtr
		tx.CreatedBy = userID
		tx.CreatedAt = now
		tx.UpdatedAt = now
		if err := s.txRepo.Create(ctx, tx); err != nil {
			return nil, err
		}
	}

	return nil, nil
}

func (s *SyncService) applyDelete(ctx context.Context, userID string, scopePtr *string, ch domain.SyncChange) (*domain.ConflictInfo, error) {
	switch ch.EntityType {
	case "transaction":
		existing, err := s.txRepo.FindByID(ctx, ch.EntityID)
		if err != nil {
			if domain.IsNotFound(err) {
				return nil, nil
			}
			return nil, err
		}
		if existing.DeletedAt != nil {
			return nil, nil
		}
		return nil, s.txRepo.SoftDelete(ctx, ch.EntityID)
	default:
		return nil, fmt.Errorf("%w: unknown entity type %s", domain.ErrInvalidInput, ch.EntityType)
	}
}

func scopeIDtoPtr(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/internal/service/sync_service.go
git commit -m "feat(sync): add sync service with LWW conflict resolution"
```

---

### Task 5b: Sync Service Tests

**Files:**
- Create: `backend/internal/service/sync_service_test.go`

Note: Service tests in a separate `service_test` package can't access `setupTestDB` from `repository_test` (Go package boundary). Options:
1. Put sync service tests in `repository_test` package (same file)
2. Export `SetupTestDB` from `repository` package
3. Skip service unit tests and rely on repository tests + e2e tests

**Recommended: Option 1** — Add sync service tests to `sync_repo_test.go` (same file, same package `repository_test`). Add:

```go
func TestSyncService_EndToEnd(t *testing.T) {
	ctx := context.Background()
	db := setupTestDB(t)

	syncRepo := repository.NewSyncRepo(db)
	txRepo := repository.NewTransactionRepo(db)
	catRepo := repository.NewCategoryRepo(db)
	famRepo := repository.NewFamilyRepo(db)
	userRepo := repository.NewUserRepo(db)

	svc := service.NewSyncService(syncRepo, txRepo, catRepo, famRepo, userRepo)

	user := createTestUser(t, ctx, db)
	cat := createTestCategory(t, ctx, db)

	txID := uuid.New().String()
	snapshot, _ := json.Marshal(map[string]interface{}{
		"Type":        "expense",
		"Amount":      5000,
		"Currency":    "INR",
		"CategoryID":  cat.ID,
		"Description": "test sync",
		"Date":        "2026-07-04",
	})

	localChanges := []domain.SyncChange{
		{
			EntityType:      "transaction",
			EntityID:        txID,
			Action:          "create",
			Snapshot:        snapshot,
			ClientTimestamp: time.Now().UTC(),
		},
	}

	result, err := svc.Sync(ctx, user.ID, "", "personal", 0, localChanges)
	require.NoError(t, err)
	assert.Empty(t, result.Conflicts)
	assert.GreaterOrEqual(t, result.NewCheckpoint, int64(0))

	tx, err := txRepo.FindByID(ctx, txID)
	require.NoError(t, err)
	assert.Equal(t, "expense", tx.Type)
	assert.Equal(t, 5000.0, tx.Amount)
}

func TestSyncService_RejectsInvalidScope(t *testing.T) {
	ctx := context.Background()
	db := setupTestDB(t)

	syncRepo := repository.NewSyncRepo(db)
	txRepo := repository.NewTransactionRepo(db)
	catRepo := repository.NewCategoryRepo(db)
	famRepo := repository.NewFamilyRepo(db)
	userRepo := repository.NewUserRepo(db)

	svc := service.NewSyncService(syncRepo, txRepo, catRepo, famRepo, userRepo)

	user := createTestUser(t, ctx, db)

	_, err := svc.Sync(ctx, user.ID, "", "invalid_scope", 0, nil)
	assert.Error(t, err)
}
```

You'll need to add these imports to the test file: `encoding/json`, `time`, `github.com/kshku/findiary/backend/internal/service`.

- [ ] **Step 1: Add the e2e tests to sync_repo_test.go**

- [ ] **Step 2: Run the combined tests**

Run: `cd backend && go test ./internal/repository/ -run TestSync -v`

Expected: All sync tests pass

---

### Task 6: Sync Handler

**Files:**
- Create: `backend/internal/api/sync_handler.go`

- [ ] **Step 1: Write sync_handler.go**

```go
package api

import (
	"context"
	"errors"
	"time"

	"github.com/bufbuild/connect-go"
	pb "github.com/kshku/findiary/backend/internal/api/findiary/v1"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/service"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type SyncHandler struct {
	svc *service.SyncService
}

func NewSyncHandler(svc *service.SyncService) *SyncHandler {
	return &SyncHandler{svc: svc}
}

func (h *SyncHandler) Sync(ctx context.Context, req *connect.Request[pb.SyncRequest]) (*connect.Response[pb.SyncResponse], error) {
	userID := GetUserID(ctx)

	localChanges := make([]domain.SyncChange, len(req.Msg.LocalChanges))
	for i, lc := range req.Msg.LocalChanges {
		localChanges[i] = domain.SyncChange{
			EntityType:      lc.EntityType,
			EntityID:        lc.EntityId,
			Action:          lc.Action,
			Snapshot:        lc.Snapshot,
			ClientTimestamp: lc.ClientTimestamp.AsTime(),
			ChangedFields:   lc.ChangedFields,
		}
	}

	result, err := h.svc.Sync(ctx, userID, req.Msg.ScopeId, req.Msg.ScopeType, req.Msg.LastCheckpoint, localChanges)
	if err != nil {
		if errors.Is(err, domain.ErrForbidden) {
			return nil, connect.NewError(connect.CodePermissionDenied, err)
		}
		if errors.Is(err, domain.ErrInvalidInput) {
			return nil, connect.NewError(connect.CodeInvalidArgument, err)
		}
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	resp := &pb.SyncResponse{
		NewCheckpoint: result.NewCheckpoint,
	}

	for _, rc := range result.RemoteChanges {
		pbEntry := changeLogEntryToProto(&rc)
		resp.RemoteChanges = append(resp.RemoteChanges, pbEntry)
	}

	for _, c := range result.Conflicts {
		resp.Conflicts = append(resp.Conflicts, conflictInfoToProto(&c))
	}

	return connect.NewResponse(resp), nil
}

func changeLogEntryToProto(entry *domain.ChangeLogEntry) *pb.ChangeEntry {
	ts := timestamppb.New(entry.ClientTimestamp)
	return &pb.ChangeEntry{
		EntityType:      entry.EntityType,
		EntityId:        entry.EntityID,
		Action:          entry.Action,
		Snapshot:        []byte(entry.Snapshot),
		ClientTimestamp: ts,
		ChangedFields:   entry.ChangedFields,
	}
}

func conflictInfoToProto(c *domain.ConflictInfo) *pb.ConflictInfo {
	return &pb.ConflictInfo{
		EntityType: c.EntityType,
		EntityId:   c.EntityID,
		Field:      c.Field,
		LocalValue: c.LocalValue,
		ServerValue: c.ServerValue,
	}
}
```

- [ ] **Step 2: Commit**

```bash
git add backend/internal/api/sync_handler.go
git commit -m "feat(sync): add sync gRPC handler"
```

---

### Task 7: Wire into Server

**Files:**
- Modify: `backend/internal/server/server.go`

- [ ] **Step 1: Update server.go**

Add new imports:
```go
pbv1connect "github.com/kshku/findiary/backend/internal/api/findiary/v1/v1connect"
```

Add after existing repo/service/handler init:
```go
syncRepo := repository.NewSyncRepo(db)
syncSvc := service.NewSyncService(syncRepo, txRepo, categoryRepo, familyRepo, userRepo)
syncHandler := api.NewSyncHandler(syncSvc)

syncPattern, syncHTTPHandler := pbv1connect.NewSyncServiceHandler(
    syncHandler,
    connect.WithInterceptors(
        LoggingInterceptor(logger),
        AuthInterceptor(mgr),
    ),
)
mux.Handle(syncPattern, syncHTTPHandler)
```

- [ ] **Step 2: Commit**

```bash
git add backend/internal/server/server.go
git commit -m "feat(sync): wire sync service into server"
```

---

### Task 8: Verify Backend Tests

**Files:**
- Modify: None (test-only)

- [ ] **Step 1: Run all backend tests**

Run: `cd backend && go test ./... -v 2>&1 | tail -50`

Expected: All tests pass (may need to apply migration 000007 first)

- [ ] **Step 2: If migration was added, run it**

```bash
cd backend && make migrate-up
```

Or manually via psql:
- [ ] **Step 2: Apply migration 000007**

If tests need the migration, run: `cd backend && go run ./cmd/migrate up`

- [ ] **Step 3: Run tests again**

Run: `cd backend && go test ./... -v 2>&1 | tail -50`

Expected: All tests pass

- [ ] **Step 4: Commit any remaining changes**

```bash
git add -A
git commit -m "chore: finalize Phase 3a sync service"
```
