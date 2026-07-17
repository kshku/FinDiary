package service_test

import (
	"context"
	"errors"
	"testing"

	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/repository"
	"github.com/kshku/findiary/backend/internal/service"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockDashboardTxRepo struct {
	totals       []repository.MonthlyTotal
	totalsErr    error
	transactions []*domain.Transaction
	txCount      int
	txErr        error
	monthsCalled int
}

func (m *mockDashboardTxRepo) GetMonthlyTotals(ctx context.Context, userID string, familyID *string, months int) ([]repository.MonthlyTotal, error) {
	m.monthsCalled = months
	return m.totals, m.totalsErr
}

func (m *mockDashboardTxRepo) List(ctx context.Context, filter domain.TransactionFilter) ([]*domain.Transaction, int, error) {
	return m.transactions, m.txCount, m.txErr
}

type mockDashboardFamilyRepo struct {
	isMember bool
	isMemberErr error
}

func (m *mockDashboardFamilyRepo) IsMember(ctx context.Context, familyID, userID string) (bool, error) {
	return m.isMember, m.isMemberErr
}

func (m *mockDashboardFamilyRepo) Create(ctx context.Context, family *domain.Family) error {
	return nil
}
func (m *mockDashboardFamilyRepo) FindByID(ctx context.Context, id string) (*domain.Family, error) {
	return nil, domain.ErrNotFound
}
func (m *mockDashboardFamilyRepo) Update(ctx context.Context, family *domain.Family) error {
	return nil
}
func (m *mockDashboardFamilyRepo) ListByUser(ctx context.Context, userID string) ([]*domain.Family, error) {
	return nil, nil
}
func (m *mockDashboardFamilyRepo) AddMember(ctx context.Context, member *domain.FamilyMember) error {
	return nil
}
func (m *mockDashboardFamilyRepo) RemoveMember(ctx context.Context, familyID, userID string) error {
	return nil
}
func (m *mockDashboardFamilyRepo) ListMembers(ctx context.Context, familyID string) ([]*domain.FamilyMember, error) {
	return nil, nil
}
func (m *mockDashboardFamilyRepo) CreateInvitation(ctx context.Context, inv *domain.Invitation) error {
	return nil
}
func (m *mockDashboardFamilyRepo) FindInvitationByCode(ctx context.Context, code string) (*domain.Invitation, error) {
	return nil, domain.ErrNotFound
}
func (m *mockDashboardFamilyRepo) UpdateInvitation(ctx context.Context, inv *domain.Invitation) error {
	return nil
}
func (m *mockDashboardFamilyRepo) ListInvitations(ctx context.Context, familyID string) ([]*domain.Invitation, error) {
	return nil, nil
}
func (m *mockDashboardFamilyRepo) ListInvitationsByEmail(ctx context.Context, email string) ([]*domain.Invitation, error) {
	return nil, nil
}

func TestGetDashboard_Success(t *testing.T) {
	txRepo := &mockDashboardTxRepo{
		totals: []repository.MonthlyTotal{
			{YearMonth: "2026-07", TotalIncome: 50000, TotalExpense: 30000},
		},
		transactions: []*domain.Transaction{
			{ID: "tx1", Type: "income", Amount: 1000},
		},
		txCount: 1,
	}
	familyRepo := &mockDashboardFamilyRepo{}
	svc := service.NewDashboardService(txRepo, familyRepo)

	data, err := svc.GetDashboard(context.Background(), "user1", nil, 6)
	require.NoError(t, err)
	require.NotNil(t, data)
	assert.Equal(t, 50000.0, data.TotalIncome)
	assert.Equal(t, 30000.0, data.TotalExpense)
	assert.Len(t, data.Monthly, 1)
	assert.Len(t, data.RecentTransactions, 1)
}

func TestGetDashboard_Forbidden(t *testing.T) {
	familyID := "family1"
	txRepo := &mockDashboardTxRepo{}
	familyRepo := &mockDashboardFamilyRepo{isMember: false}
	svc := service.NewDashboardService(txRepo, familyRepo)

	_, err := svc.GetDashboard(context.Background(), "user1", &familyID, 6)
	require.Error(t, err)
	assert.ErrorIs(t, err, domain.ErrForbidden)
}

func TestGetDashboard_FamilyMember(t *testing.T) {
	familyID := "family1"
	txRepo := &mockDashboardTxRepo{
		totals: []repository.MonthlyTotal{
			{YearMonth: "2026-07", TotalIncome: 10000, TotalExpense: 5000},
		},
		transactions: []*domain.Transaction{},
		txCount:      0,
	}
	familyRepo := &mockDashboardFamilyRepo{isMember: true}
	svc := service.NewDashboardService(txRepo, familyRepo)

	data, err := svc.GetDashboard(context.Background(), "user1", &familyID, 6)
	require.NoError(t, err)
	assert.Equal(t, 10000.0, data.TotalIncome)
	assert.Equal(t, 5000.0, data.TotalExpense)
}

func TestGetDashboard_DefaultMonths(t *testing.T) {
	txRepo := &mockDashboardTxRepo{
		totals:       []repository.MonthlyTotal{},
		transactions: []*domain.Transaction{},
	}
	familyRepo := &mockDashboardFamilyRepo{}
	svc := service.NewDashboardService(txRepo, familyRepo)

	data, err := svc.GetDashboard(context.Background(), "user1", nil, 0)
	require.NoError(t, err)
	require.NotNil(t, data)
	assert.Equal(t, 6, txRepo.monthsCalled)
}

func TestGetDashboard_MonthsCapped(t *testing.T) {
	txRepo := &mockDashboardTxRepo{
		totals:       []repository.MonthlyTotal{},
		transactions: []*domain.Transaction{},
	}
	familyRepo := &mockDashboardFamilyRepo{}
	svc := service.NewDashboardService(txRepo, familyRepo)

	data, err := svc.GetDashboard(context.Background(), "user1", nil, 20)
	require.NoError(t, err)
	require.NotNil(t, data)
	assert.Equal(t, 6, txRepo.monthsCalled)
}

func TestGetDashboard_MultipleMonths(t *testing.T) {
	txRepo := &mockDashboardTxRepo{
		totals: []repository.MonthlyTotal{
			{YearMonth: "2026-07", TotalIncome: 50000, TotalExpense: 30000},
			{YearMonth: "2026-06", TotalIncome: 45000, TotalExpense: 25000},
			{YearMonth: "2026-05", TotalIncome: 40000, TotalExpense: 20000},
		},
		transactions: []*domain.Transaction{
			{ID: "tx1", Type: "expense", Amount: 500},
			{ID: "tx2", Type: "income", Amount: 1000},
		},
		txCount: 2,
	}
	familyRepo := &mockDashboardFamilyRepo{}
	svc := service.NewDashboardService(txRepo, familyRepo)

	data, err := svc.GetDashboard(context.Background(), "user1", nil, 3)
	require.NoError(t, err)
	assert.Equal(t, 135000.0, data.TotalIncome)
	assert.Equal(t, 75000.0, data.TotalExpense)
	assert.Len(t, data.Monthly, 3)
	assert.Len(t, data.RecentTransactions, 2)
}

func TestGetDashboard_FamilyMembershipError(t *testing.T) {
	familyID := "family1"
	txRepo := &mockDashboardTxRepo{}
	familyRepo := &mockDashboardFamilyRepo{isMemberErr: errors.New("db error")}
	svc := service.NewDashboardService(txRepo, familyRepo)

	_, err := svc.GetDashboard(context.Background(), "user1", &familyID, 6)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "check membership")
}

func TestGetDashboard_TotalsError(t *testing.T) {
	txRepo := &mockDashboardTxRepo{totalsErr: errors.New("db error")}
	familyRepo := &mockDashboardFamilyRepo{}
	svc := service.NewDashboardService(txRepo, familyRepo)

	_, err := svc.GetDashboard(context.Background(), "user1", nil, 6)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "db error")
}

func TestGetDashboard_ListError(t *testing.T) {
	txRepo := &mockDashboardTxRepo{
		totals:  []repository.MonthlyTotal{},
		txErr:   errors.New("list failed"),
		txCount: 0,
	}
	familyRepo := &mockDashboardFamilyRepo{}
	svc := service.NewDashboardService(txRepo, familyRepo)

	_, err := svc.GetDashboard(context.Background(), "user1", nil, 6)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "list failed")
}
