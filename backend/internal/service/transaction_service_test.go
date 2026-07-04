package service_test

import (
	"context"
	"testing"
	"time"

	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/service"
	"github.com/stretchr/testify/require"
)

type mockTxRepo struct {
	Transactions map[string]*domain.Transaction
}

func (m *mockTxRepo) Create(ctx context.Context, tx *domain.Transaction) error {
	if m.Transactions == nil {
		m.Transactions = make(map[string]*domain.Transaction)
	}
	m.Transactions[tx.ID] = tx
	return nil
}

func (m *mockTxRepo) FindByID(ctx context.Context, id string) (*domain.Transaction, error) {
	if m.Transactions == nil {
		return nil, domain.ErrNotFound
	}
	tx, ok := m.Transactions[id]
	if !ok {
		return nil, domain.ErrNotFound
	}
	return tx, nil
}

func (m *mockTxRepo) Update(ctx context.Context, tx *domain.Transaction) error {
	if m.Transactions == nil {
		return domain.ErrNotFound
	}
	m.Transactions[tx.ID] = tx
	return nil
}

func (m *mockTxRepo) SoftDelete(ctx context.Context, id string) error {
	if m.Transactions == nil {
		return domain.ErrNotFound
	}
	tx, ok := m.Transactions[id]
	if !ok {
		return domain.ErrNotFound
	}
	now := time.Now().UTC().Format(time.RFC3339Nano)
	tx.DeletedAt = &now
	return nil
}

func (m *mockTxRepo) List(ctx context.Context, filter domain.TransactionFilter) ([]*domain.Transaction, int, error) {
	var result []*domain.Transaction
	for _, tx := range m.Transactions {
		if tx.DeletedAt != nil {
			continue
		}
		result = append(result, tx)
	}
	return result, len(result), nil
}

type mockTxCatRepo struct {
	Categories map[string]*domain.Category
}

func (m *mockTxCatRepo) Create(ctx context.Context, cat *domain.Category) error {
	return nil
}

func (m *mockTxCatRepo) FindByID(ctx context.Context, id string) (*domain.Category, error) {
	if 	m.Categories == nil {
		return nil, domain.ErrNotFound
	}
	cat, ok := 	m.Categories[id]
	if !ok {
		return nil, domain.ErrNotFound
	}
	return cat, nil
}

func (m *mockTxCatRepo) Update(ctx context.Context, cat *domain.Category) error {
	return nil
}

func (m *mockTxCatRepo) Delete(ctx context.Context, id string) error {
	return nil
}

func (m *mockTxCatRepo) List(ctx context.Context, scope string, familyID *string, catType string) ([]*domain.Category, error) {
	return nil, nil
}

type mockTxFamilyRepo struct {
	Members []*domain.FamilyMember
}

func (m *mockTxFamilyRepo) Create(ctx context.Context, family *domain.Family) error {
	return nil
}

func (m *mockTxFamilyRepo) FindByID(ctx context.Context, id string) (*domain.Family, error) {
	return nil, domain.ErrNotFound
}

func (m *mockTxFamilyRepo) Update(ctx context.Context, family *domain.Family) error {
	return nil
}

func (m *mockTxFamilyRepo) ListByUser(ctx context.Context, userID string) ([]*domain.Family, error) {
	return nil, nil
}

func (m *mockTxFamilyRepo) AddMember(ctx context.Context, member *domain.FamilyMember) error {
	return nil
}

func (m *mockTxFamilyRepo) RemoveMember(ctx context.Context, familyID, userID string) error {
	return nil
}

func (m *mockTxFamilyRepo) ListMembers(ctx context.Context, familyID string) ([]*domain.FamilyMember, error) {
	return nil, nil
}

func (m *mockTxFamilyRepo) IsMember(ctx context.Context, familyID, userID string) (bool, error) {
	for _, mem := range 	m.Members {
		if mem.FamilyID == familyID && mem.UserID == userID {
			return true, nil
		}
	}
	return false, nil
}

func (m *mockTxFamilyRepo) CreateInvitation(ctx context.Context, inv *domain.Invitation) error {
	return nil
}

func (m *mockTxFamilyRepo) FindInvitationByCode(ctx context.Context, code string) (*domain.Invitation, error) {
	return nil, domain.ErrNotFound
}

func (m *mockTxFamilyRepo) UpdateInvitation(ctx context.Context, inv *domain.Invitation) error {
	return nil
}

func (m *mockTxFamilyRepo) ListInvitations(ctx context.Context, familyID string) ([]*domain.Invitation, error) {
	return nil, nil
}

func (m *mockTxFamilyRepo) ListInvitationsByEmail(ctx context.Context, email string) ([]*domain.Invitation, error) {
	return nil, nil
}

func setupTransactionService() (*service.TransactionService, *mockTxRepo, *mockTxCatRepo, *mockTxFamilyRepo) {
	txRepo := &mockTxRepo{}
	catRepo := &mockTxCatRepo{}
	familyRepo := &mockTxFamilyRepo{}
	svc := service.NewTransactionService(txRepo, catRepo, familyRepo)
	return svc, txRepo, catRepo, familyRepo
}

func TestTxCreate(t *testing.T) {
	svc, txRepo, catRepo, _ := setupTransactionService()
	ctx := context.Background()

	catRepo.Categories = map[string]*domain.Category{
		"cat-1": {ID: "cat-1", Name: "Salary", Type: "income"},
	}

	req := domain.CreateTxRequest{
		Type:       "income",
		Amount:     1000,
		Currency:   "USD",
		CategoryID: "cat-1",
		Date:       "2024-01-15",
	}

	tx, err := svc.Create(ctx, "user-1", req)
	require.NoError(t, err)
	require.NotEmpty(t, tx.ID)
	require.Equal(t, 1000.0, tx.Amount)
	require.Equal(t, "income", tx.Type)
	require.Equal(t, "USD", tx.Currency)
	require.Equal(t, "cat-1", tx.CategoryID)
	require.Equal(t, "2024-01-15", tx.Date)
	require.Equal(t, "user-1", tx.CreatedBy)
	require.Nil(t, tx.FamilyID)
	require.Len(t, txRepo.Transactions, 1)
}

func TestCreate_InvalidAmount(t *testing.T) {
	svc, _, catRepo, _ := setupTransactionService()
	ctx := context.Background()

	catRepo.Categories = map[string]*domain.Category{
		"cat-1": {ID: "cat-1", Name: "Salary", Type: "income"},
	}

	req := domain.CreateTxRequest{
		Type:       "income",
		Amount:     0,
		Currency:   "USD",
		CategoryID: "cat-1",
		Date:       "2024-01-15",
	}
	_, err := svc.Create(ctx, "user-1", req)
	require.ErrorIs(t, err, domain.ErrInvalidInput)

	req.Amount = -100
	_, err = svc.Create(ctx, "user-1", req)
	require.ErrorIs(t, err, domain.ErrInvalidInput)
}
