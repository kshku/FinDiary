package api_test

import (
	"context"
	"testing"

	"github.com/bufbuild/connect-go"
	pb "github.com/kshku/findiary/backend/internal/api/findiary/v1"
	"github.com/kshku/findiary/backend/internal/api"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/repository"
	"github.com/kshku/findiary/backend/internal/service"
	"github.com/stretchr/testify/assert"
)

type mockHandlerTxRepo struct {
	totals       []repository.MonthlyTotal
	transactions []*domain.Transaction
	txCount      int
}

func (m *mockHandlerTxRepo) GetMonthlyTotals(ctx context.Context, userID string, familyID *string, months int) ([]repository.MonthlyTotal, error) {
	return m.totals, nil
}

func (m *mockHandlerTxRepo) List(ctx context.Context, filter domain.TransactionFilter) ([]*domain.Transaction, int, error) {
	return m.transactions, m.txCount, nil
}

type mockHandlerFamilyRepo struct{}

func (m *mockHandlerFamilyRepo) IsMember(ctx context.Context, familyID, userID string) (bool, error) {
	return false, nil
}
func (m *mockHandlerFamilyRepo) Create(ctx context.Context, family *domain.Family) error {
	return nil
}
func (m *mockHandlerFamilyRepo) FindByID(ctx context.Context, id string) (*domain.Family, error) {
	return nil, domain.ErrNotFound
}
func (m *mockHandlerFamilyRepo) Update(ctx context.Context, family *domain.Family) error {
	return nil
}
func (m *mockHandlerFamilyRepo) ListByUser(ctx context.Context, userID string) ([]*domain.Family, error) {
	return nil, nil
}
func (m *mockHandlerFamilyRepo) AddMember(ctx context.Context, member *domain.FamilyMember) error {
	return nil
}
func (m *mockHandlerFamilyRepo) RemoveMember(ctx context.Context, familyID, userID string) error {
	return nil
}
func (m *mockHandlerFamilyRepo) ListMembers(ctx context.Context, familyID string) ([]*domain.FamilyMember, error) {
	return nil, nil
}
func (m *mockHandlerFamilyRepo) CreateInvitation(ctx context.Context, inv *domain.Invitation) error {
	return nil
}
func (m *mockHandlerFamilyRepo) FindInvitationByCode(ctx context.Context, code string) (*domain.Invitation, error) {
	return nil, domain.ErrNotFound
}
func (m *mockHandlerFamilyRepo) UpdateInvitation(ctx context.Context, inv *domain.Invitation) error {
	return nil
}
func (m *mockHandlerFamilyRepo) ListInvitations(ctx context.Context, familyID string) ([]*domain.Invitation, error) {
	return nil, nil
}
func (m *mockHandlerFamilyRepo) ListInvitationsByEmail(ctx context.Context, email string) ([]*domain.Invitation, error) {
	return nil, nil
}

func TestDashboardHandler_GetDashboard(t *testing.T) {
	txRepo := &mockHandlerTxRepo{
		totals: []repository.MonthlyTotal{
			{YearMonth: "2026-07", TotalIncome: 50000, TotalExpense: 30000},
		},
		transactions: []*domain.Transaction{},
	}
	familyRepo := &mockHandlerFamilyRepo{}
	svc := service.NewDashboardService(txRepo, familyRepo)
	handler := api.NewDashboardHandler(svc)

	ctx := context.WithValue(context.Background(), api.UserIDContextKey, "user1")
	req := connect.NewRequest(&pb.GetDashboardRequest{Months: 6})
	resp, err := handler.GetDashboard(ctx, req)

	assert.NoError(t, err)
	assert.Equal(t, 50000.0, resp.Msg.TotalIncome)
	assert.Equal(t, 30000.0, resp.Msg.TotalExpense)
	assert.Len(t, resp.Msg.Monthly, 1)
	assert.Equal(t, "2026-07", resp.Msg.Monthly[0].YearMonth)
}

func TestDashboardHandler_GetDashboard_EmptyData(t *testing.T) {
	txRepo := &mockHandlerTxRepo{
		totals:       []repository.MonthlyTotal{},
		transactions: []*domain.Transaction{},
	}
	familyRepo := &mockHandlerFamilyRepo{}
	svc := service.NewDashboardService(txRepo, familyRepo)
	handler := api.NewDashboardHandler(svc)

	ctx := context.WithValue(context.Background(), api.UserIDContextKey, "user1")
	req := connect.NewRequest(&pb.GetDashboardRequest{Months: 6})
	resp, err := handler.GetDashboard(ctx, req)

	assert.NoError(t, err)
	assert.Equal(t, 0.0, resp.Msg.TotalIncome)
	assert.Equal(t, 0.0, resp.Msg.TotalExpense)
	assert.Empty(t, resp.Msg.Monthly)
	assert.Empty(t, resp.Msg.RecentTransactions)
}

func TestDashboardHandler_GetDashboard_DefaultMonths(t *testing.T) {
	txRepo := &mockHandlerTxRepo{
		totals:       []repository.MonthlyTotal{},
		transactions: []*domain.Transaction{},
	}
	familyRepo := &mockHandlerFamilyRepo{}
	svc := service.NewDashboardService(txRepo, familyRepo)
	handler := api.NewDashboardHandler(svc)

	ctx := context.WithValue(context.Background(), api.UserIDContextKey, "user1")
	req := connect.NewRequest(&pb.GetDashboardRequest{Months: 0})
	resp, err := handler.GetDashboard(ctx, req)

	assert.NoError(t, err)
	assert.NotNil(t, resp)
}

func TestDashboardHandler_GetDashboard_WithRecentTransactions(t *testing.T) {
	txRepo := &mockHandlerTxRepo{
		totals: []repository.MonthlyTotal{
			{YearMonth: "2026-07", TotalIncome: 10000, TotalExpense: 5000},
		},
		transactions: []*domain.Transaction{
			{ID: "tx1", Type: "income", Amount: 1000, Currency: "JPY"},
			{ID: "tx2", Type: "expense", Amount: 500, Currency: "JPY"},
		},
		txCount: 2,
	}
	familyRepo := &mockHandlerFamilyRepo{}
	svc := service.NewDashboardService(txRepo, familyRepo)
	handler := api.NewDashboardHandler(svc)

	ctx := context.WithValue(context.Background(), api.UserIDContextKey, "user1")
	req := connect.NewRequest(&pb.GetDashboardRequest{Months: 6})
	resp, err := handler.GetDashboard(ctx, req)

	assert.NoError(t, err)
	assert.Len(t, resp.Msg.RecentTransactions, 2)
	assert.Equal(t, "tx1", resp.Msg.RecentTransactions[0].Id)
	assert.Equal(t, "tx2", resp.Msg.RecentTransactions[1].Id)
}
