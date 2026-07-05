package repository_test

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/repository"
	"github.com/kshku/findiary/backend/internal/service"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestSyncRepo_GetOrCreateCheckpoint(t *testing.T) {
	ctx := context.Background()
	db := setupTestDB(t)
	repo := repository.NewSyncRepo(db)

	user := createTestUser(t, ctx, db)

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

	cat := &domain.Category{
		ID:    uuid.New().String(),
		Scope: "personal",
		Name:  "Test Category",
		Type:  "expense",
	}
	require.NoError(t, catRepo.Create(ctx, cat))

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
