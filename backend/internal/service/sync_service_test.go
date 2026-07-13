package service_test

import (
	"context"
	"encoding/json"
	"errors"
	"testing"
	"time"

	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/service"
	"github.com/stretchr/testify/require"
)

type mockSyncRepo struct {
	checkpoints map[string]*domain.SyncCheckpoint
	changeLogs  []domain.ChangeLogEntry
	nextCLID    int64
}

func newMockSyncRepo() *mockSyncRepo {
	return &mockSyncRepo{
		checkpoints: make(map[string]*domain.SyncCheckpoint),
	}
}

func (m *mockSyncRepo) GetOrCreateCheckpoint(ctx context.Context, userID string, scopeID *string, scopeType string) (*domain.SyncCheckpoint, error) {
	key := userID + "|" + scopeType
	if scopeID != nil {
		key += "|" + *scopeID
	}
	if cp, ok := m.checkpoints[key]; ok {
		return cp, nil
	}
	cp := &domain.SyncCheckpoint{
		UserID:         userID,
		ScopeID:        scopeID,
		ScopeType:      scopeType,
		LastCheckpoint: 0,
		UpdatedAt:      time.Now().UTC(),
	}
	m.checkpoints[key] = cp
	return cp, nil
}

func (m *mockSyncRepo) UpdateCheckpoint(ctx context.Context, userID string, scopeID *string, scopeType string, checkpoint int64) error {
	key := userID + "|" + scopeType
	if scopeID != nil {
		key += "|" + *scopeID
	}
	if cp, ok := m.checkpoints[key]; ok {
		cp.LastCheckpoint = checkpoint
	}
	return nil
}

func (m *mockSyncRepo) AppendChangeLog(ctx context.Context, entry domain.ChangeLogEntry) error {
	m.nextCLID++
	entry.ID = m.nextCLID
	m.changeLogs = append(m.changeLogs, entry)
	return nil
}

func (m *mockSyncRepo) GetChangesSince(ctx context.Context, scopeID *string, since int64) ([]domain.ChangeLogEntry, error) {
	var result []domain.ChangeLogEntry
	for _, e := range m.changeLogs {
		if e.ID > since {
			result = append(result, e)
		}
	}
	return result, nil
}

type mockSyncTxRepo struct {
	transactions map[string]*domain.Transaction
}

func newMockSyncTxRepo() *mockSyncTxRepo {
	return &mockSyncTxRepo{transactions: make(map[string]*domain.Transaction)}
}

func (m *mockSyncTxRepo) Create(ctx context.Context, tx *domain.Transaction) error {
	m.transactions[tx.ID] = tx
	return nil
}

func (m *mockSyncTxRepo) FindByID(ctx context.Context, id string) (*domain.Transaction, error) {
	if tx, ok := m.transactions[id]; ok {
		return tx, nil
	}
	return nil, domain.ErrNotFound
}

func (m *mockSyncTxRepo) Update(ctx context.Context, tx *domain.Transaction) error {
	m.transactions[tx.ID] = tx
	return nil
}

func (m *mockSyncTxRepo) SoftDelete(ctx context.Context, id string) error {
	if tx, ok := m.transactions[id]; ok {
		now := time.Now().UTC().Format(time.RFC3339Nano)
		tx.DeletedAt = &now
	}
	return nil
}

func (m *mockSyncTxRepo) List(ctx context.Context, filter domain.TransactionFilter) ([]*domain.Transaction, int, error) {
	return nil, 0, errors.New("not implemented")
}

type mockSyncCatRepo struct {
	categories map[string]*domain.Category
}

func newMockSyncCatRepo() *mockSyncCatRepo {
	return &mockSyncCatRepo{categories: make(map[string]*domain.Category)}
}

func (m *mockSyncCatRepo) Create(ctx context.Context, cat *domain.Category) error {
	m.categories[cat.ID] = cat
	return nil
}

func (m *mockSyncCatRepo) FindByID(ctx context.Context, id string) (*domain.Category, error) {
	if cat, ok := m.categories[id]; ok {
		return cat, nil
	}
	return nil, domain.ErrNotFound
}

func (m *mockSyncCatRepo) Update(ctx context.Context, cat *domain.Category) error {
	m.categories[cat.ID] = cat
	return nil
}

func (m *mockSyncCatRepo) Delete(ctx context.Context, id string) error {
	delete(m.categories, id)
	return nil
}

func (m *mockSyncCatRepo) List(ctx context.Context, scope string, familyID *string, catType string) ([]*domain.Category, error) {
	var result []*domain.Category
	for _, c := range m.categories {
		result = append(result, c)
	}
	return result, nil
}

type mockSyncFamilyRepo struct {
}

func (m *mockSyncFamilyRepo) Create(ctx context.Context, family *domain.Family) error {
	return nil
}
func (m *mockSyncFamilyRepo) FindByID(ctx context.Context, id string) (*domain.Family, error) {
	return nil, domain.ErrNotFound
}
func (m *mockSyncFamilyRepo) Update(ctx context.Context, family *domain.Family) error {
	return nil
}
func (m *mockSyncFamilyRepo) ListByUser(ctx context.Context, userID string) ([]*domain.Family, error) {
	return nil, nil
}
func (m *mockSyncFamilyRepo) AddMember(ctx context.Context, member *domain.FamilyMember) error {
	return nil
}
func (m *mockSyncFamilyRepo) RemoveMember(ctx context.Context, familyID, userID string) error {
	return nil
}
func (m *mockSyncFamilyRepo) ListMembers(ctx context.Context, familyID string) ([]*domain.FamilyMember, error) {
	return nil, nil
}
func (m *mockSyncFamilyRepo) IsMember(ctx context.Context, familyID, userID string) (bool, error) {
	return true, nil
}
func (m *mockSyncFamilyRepo) CreateInvitation(ctx context.Context, invite *domain.Invitation) error {
	return nil
}
func (m *mockSyncFamilyRepo) FindInvitationByCode(ctx context.Context, code string) (*domain.Invitation, error) {
	return nil, domain.ErrNotFound
}
func (m *mockSyncFamilyRepo) UpdateInvitation(ctx context.Context, invite *domain.Invitation) error {
	return nil
}
func (m *mockSyncFamilyRepo) ListInvitations(ctx context.Context, familyID string) ([]*domain.Invitation, error) {
	return nil, nil
}
func (m *mockSyncFamilyRepo) ListInvitationsByEmail(ctx context.Context, email string) ([]*domain.Invitation, error) {
	return nil, nil
}

type mockSyncUserRepo struct {
	users map[string]*domain.User
}

func newMockSyncUserRepo() *mockSyncUserRepo {
	return &mockSyncUserRepo{users: make(map[string]*domain.User)}
}

func (m *mockSyncUserRepo) Create(ctx context.Context, user *domain.User) error {
	m.users[user.ID] = user
	return nil
}

func (m *mockSyncUserRepo) FindByID(ctx context.Context, id string) (*domain.User, error) {
	if u, ok := m.users[id]; ok {
		return u, nil
	}
	return nil, domain.ErrNotFound
}

func (m *mockSyncUserRepo) FindByEmail(ctx context.Context, email string) (*domain.User, error) {
	for _, u := range m.users {
		if u.Email == email {
			return u, nil
		}
	}
	return nil, domain.ErrNotFound
}

func setupSyncTest(userID string) (*service.SyncService, *mockSyncRepo, *mockSyncTxRepo, *mockSyncCatRepo) {
	syncRepo := newMockSyncRepo()
	txRepo := newMockSyncTxRepo()
	catRepo := newMockSyncCatRepo()
	mockUserRepo := newMockSyncUserRepo()

	mockUserRepo.Create(context.Background(), &domain.User{
		ID: userID, Email: "test@test.com", DisplayName: "Test",
	})

	svc := service.NewSyncService(syncRepo, txRepo, catRepo, &mockSyncFamilyRepo{}, mockUserRepo)
	return svc, syncRepo, txRepo, catRepo
}

func strPtr(s string) *string { return &s }

func TestSync_EmptyLocalChanges(t *testing.T) {
	svc, syncRepo, _, _ := setupSyncTest("user-1")
	ctx := context.Background()

	syncRepo.checkpoints["user-1|personal"] = &domain.SyncCheckpoint{LastCheckpoint: 5}

	result, err := svc.Sync(ctx, "user-1", "personal", "personal", 5, nil)
	require.NoError(t, err)
	require.NotNil(t, result)
	// No local changes → no change logs written
	require.Empty(t, syncRepo.changeLogs)
	// No remote changes
	require.Empty(t, result.RemoteChanges)
	// Checkpoint stays at the input value
	require.Equal(t, int64(5), result.NewCheckpoint)
}

func TestSync_TransactionCreate(t *testing.T) {
	svc, syncRepo, _, _ := setupSyncTest("user-1")
	ctx := context.Background()

	syncRepo.checkpoints["user-1|personal"] = &domain.SyncCheckpoint{LastCheckpoint: 0}

	txSnapshot, _ := json.Marshal(map[string]interface{}{
		"type": "expense", "amount": 50.00, "currency": "INR",
		"category_id": "cat-1", "description": "lunch", "date": "2026-07-12",
	})
	localChanges := []domain.SyncChange{
		{
			EntityType: "transaction", EntityID: "tx-1", Action: "create",
			Snapshot: txSnapshot, ClientTimestamp: time.Now().UTC(),
		},
	}

	result, err := svc.Sync(ctx, "user-1", "personal", "personal", 0, localChanges)
	require.NoError(t, err)
	require.NotNil(t, result)
	// Change log should have 1 entry
	require.Len(t, syncRepo.changeLogs, 1)
	require.Equal(t, "transaction", syncRepo.changeLogs[0].EntityType)
	require.Equal(t, "tx-1", syncRepo.changeLogs[0].EntityID)
	require.Equal(t, "create", syncRepo.changeLogs[0].Action)
	// Snapshot should contain the merged transaction JSON
	require.Contains(t, syncRepo.changeLogs[0].Snapshot, `"Amount":50`)
	// Remote changes should include what we just wrote
	require.Len(t, result.RemoteChanges, 1)
	// New checkpoint > 0
	require.Greater(t, result.NewCheckpoint, int64(0))
}

func TestSync_TransactionUpdate(t *testing.T) {
	svc, _, txRepo, _ := setupSyncTest("user-1")
	ctx := context.Background()

	now := time.Now().UTC()
	// Pre-existing transaction on server
	txRepo.Create(ctx, &domain.Transaction{
		ID: "tx-1", Type: "expense", Amount: 30.00, Currency: "INR",
		CategoryID: "cat-1", Description: strPtr("coffee"), Date: "2026-07-12",
		CreatedBy: "user-1", CreatedAt: now.Format(time.RFC3339Nano),
		UpdatedAt: now.Format(time.RFC3339Nano),
	})

	// Client sends update with newer timestamp
	updatedSnapshot, _ := json.Marshal(map[string]interface{}{
		"type": "expense", "amount": 35.00, "currency": "INR",
		"category_id": "cat-1", "description": "latte", "date": "2026-07-12",
	})
	localChanges := []domain.SyncChange{
		{
			EntityType: "transaction", EntityID: "tx-1", Action: "update",
			Snapshot: updatedSnapshot,
			ClientTimestamp: now.Add(time.Hour),
		},
	}

	result, err := svc.Sync(ctx, "user-1", "personal", "personal", 0, localChanges)
	require.NoError(t, err)
	require.Empty(t, result.Conflicts)
	// Transaction should be updated
	updated, _ := txRepo.FindByID(ctx, "tx-1")
	require.Equal(t, 35.00, updated.Amount)
	require.Equal(t, "latte", *updated.Description)
}

func TestSync_TransactionConflict_OlderTimestamp(t *testing.T) {
	svc, _, txRepo, _ := setupSyncTest("user-1")
	ctx := context.Background()

	now := time.Now().UTC()
	txRepo.Create(ctx, &domain.Transaction{
		ID: "tx-1", Type: "expense", Amount: 100.00, Currency: "INR",
		CategoryID: "cat-1", Description: strPtr("dinner"), Date: "2026-07-12",
		CreatedBy: "user-1",
		CreatedAt: now.Add(-2 * time.Hour).Format(time.RFC3339Nano),
		UpdatedAt: now.Format(time.RFC3339Nano),
	})

	// Client sends update with OLDER timestamp → conflict
	olderSnapshot, _ := json.Marshal(map[string]interface{}{
		"type": "expense", "amount": 80.00, "currency": "INR",
		"category_id": "cat-1", "description": "cheap dinner",
		"date": "2026-07-12",
	})
	localChanges := []domain.SyncChange{
		{
			EntityType: "transaction", EntityID: "tx-1", Action: "update",
			Snapshot: olderSnapshot,
			ClientTimestamp: now.Add(-3 * time.Hour),
		},
	}

	result, err := svc.Sync(ctx, "user-1", "personal", "personal", 0, localChanges)
	require.NoError(t, err)
	require.Len(t, result.Conflicts, 1)
	require.Equal(t, "tx-1", result.Conflicts[0].EntityID)
	// Server value should prevail (not overwritten)
	tx, _ := txRepo.FindByID(ctx, "tx-1")
	require.Equal(t, 100.00, tx.Amount)
	require.Equal(t, "dinner", *tx.Description)
}

func TestSync_TransactionDelete(t *testing.T) {
	svc, syncRepo, txRepo, _ := setupSyncTest("user-1")
	ctx := context.Background()

	txRepo.Create(ctx, &domain.Transaction{
		ID: "tx-1", Type: "expense", Amount: 25.00, Currency: "INR",
		CategoryID: "cat-1", Description: strPtr("snack"), Date: "2026-07-12",
		CreatedBy: "user-1",
		UpdatedAt: time.Now().UTC().Format(time.RFC3339Nano),
	})

	localChanges := []domain.SyncChange{
		{
			EntityType: "transaction", EntityID: "tx-1", Action: "delete",
			Snapshot: []byte(`{}`),
			ClientTimestamp: time.Now().UTC(),
		},
	}

	result, err := svc.Sync(ctx, "user-1", "personal", "personal", 0, localChanges)
	require.NoError(t, err)
	require.Empty(t, result.Conflicts)
	require.Len(t, syncRepo.changeLogs, 1)
	require.Equal(t, "delete", syncRepo.changeLogs[0].Action)
	// Transaction should be soft-deleted
	tx, _ := txRepo.FindByID(ctx, "tx-1")
	require.NotNil(t, tx.DeletedAt)
}

func TestSync_CategoryUpsert(t *testing.T) {
	svc, syncRepo, _, catRepo := setupSyncTest("user-1")
	ctx := context.Background()

	catSnapshot, _ := json.Marshal(map[string]interface{}{
		"name": "Groceries", "type": "expense", "icon": "shopping", "color": "#FF0000",
	})
	localChanges := []domain.SyncChange{
		{
			EntityType: "category", EntityID: "cat-1", Action: "create",
			Snapshot: catSnapshot, ClientTimestamp: time.Now().UTC(),
		},
	}

	result, err := svc.Sync(ctx, "user-1", "personal", "personal", 0, localChanges)
	require.NoError(t, err)
	require.Len(t, result.RemoteChanges, 1)
	require.Len(t, syncRepo.changeLogs, 1)
	require.Equal(t, "category", syncRepo.changeLogs[0].EntityType)

	// Category should be created
	cat, err := catRepo.FindByID(ctx, "cat-1")
	require.NoError(t, err)
	require.Equal(t, "Groceries", cat.Name)
}

func TestSync_CategoryDelete(t *testing.T) {
	svc, syncRepo, _, catRepo := setupSyncTest("user-1")
	ctx := context.Background()

	catRepo.Create(ctx, &domain.Category{
		ID: "cat-1", Name: "Old Category", Type: "expense",
	})

	localChanges := []domain.SyncChange{
		{
			EntityType: "category", EntityID: "cat-1", Action: "delete",
			Snapshot: []byte(`{}`),
			ClientTimestamp: time.Now().UTC(),
		},
	}

	result, err := svc.Sync(ctx, "user-1", "personal", "personal", 0, localChanges)
	require.NoError(t, err)
	require.Empty(t, result.Conflicts)
	require.Len(t, syncRepo.changeLogs, 1)
	require.Equal(t, "delete", syncRepo.changeLogs[0].Action)
	// Category is hard-deleted
	_, err = catRepo.FindByID(ctx, "cat-1")
	require.ErrorIs(t, err, domain.ErrNotFound)
}

func TestSync_InvalidScopeType(t *testing.T) {
	svc, _, _, _ := setupSyncTest("user-1")
	ctx := context.Background()

	_, err := svc.Sync(ctx, "user-1", "", "invalid", 0, nil)
	require.ErrorIs(t, err, domain.ErrInvalidInput)
}

func TestSync_InvalidUser(t *testing.T) {
	svc, _, _, _ := setupSyncTest("user-1")
	ctx := context.Background()

	// Non-existent user
	_, err := svc.Sync(ctx, "nonexistent", "", "personal", 0, nil)
	require.ErrorIs(t, err, domain.ErrInvalidInput)
}

func TestSync_RemoteChangesReturned(t *testing.T) {
	svc, syncRepo, _, _ := setupSyncTest("user-1")
	ctx := context.Background()

	// Pre-populate some change logs (what another client sent earlier)
	earlier := time.Now().UTC()
	syncRepo.checkpoints["user-1|personal"] = &domain.SyncCheckpoint{LastCheckpoint: 0}
	syncRepo.AppendChangeLog(ctx, domain.ChangeLogEntry{
		ID: 1, FamilyID: nil, ChangedBy: "user-2",
		EntityType: "transaction", EntityID: "tx-remote", Action: "create",
		Snapshot: `{"amount":99}`, ServerTimestamp: earlier, ClientTimestamp: earlier,
	})

	// Local sync with no local changes, checkpoint=0 should get remote changes
	result, err := svc.Sync(ctx, "user-1", "personal", "personal", 0, nil)
	require.NoError(t, err)
	require.Len(t, result.RemoteChanges, 1)
	require.Equal(t, "tx-remote", result.RemoteChanges[0].EntityID)
	require.Equal(t, int64(1), result.NewCheckpoint)
}

func TestSync_MultipleChanges(t *testing.T) {
	svc, syncRepo, _, _ := setupSyncTest("user-1")
	ctx := context.Background()

	syncRepo.checkpoints["user-1|personal"] = &domain.SyncCheckpoint{LastCheckpoint: 0}

	txSnap1, _ := json.Marshal(map[string]interface{}{"type": "expense", "amount": 10})
	txSnap2, _ := json.Marshal(map[string]interface{}{"type": "income", "amount": 1000})
	catSnap, _ := json.Marshal(map[string]interface{}{"name": "Food", "type": "expense"})

	localChanges := []domain.SyncChange{
		{EntityType: "transaction", EntityID: "tx-1", Action: "create", Snapshot: txSnap1, ClientTimestamp: time.Now().UTC()},
		{EntityType: "transaction", EntityID: "tx-2", Action: "create", Snapshot: txSnap2, ClientTimestamp: time.Now().UTC()},
		{EntityType: "category", EntityID: "cat-1", Action: "create", Snapshot: catSnap, ClientTimestamp: time.Now().UTC()},
	}

	result, err := svc.Sync(ctx, "user-1", "personal", "personal", 0, localChanges)
	require.NoError(t, err)
	require.Len(t, syncRepo.changeLogs, 3)
	require.Len(t, result.RemoteChanges, 3)
}
