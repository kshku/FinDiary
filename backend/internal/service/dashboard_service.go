package service

import (
	"context"
	"fmt"

	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/repository"
)

type DashboardTxRepo interface {
	GetMonthlyTotals(ctx context.Context, userID string, familyID *string, months int) ([]repository.MonthlyTotal, error)
	List(ctx context.Context, filter domain.TransactionFilter) ([]*domain.Transaction, int, error)
}

type DashboardService struct {
	txRepo     DashboardTxRepo
	familyRepo domain.FamilyRepository
}

func NewDashboardService(txRepo DashboardTxRepo, familyRepo domain.FamilyRepository) *DashboardService {
	return &DashboardService{txRepo: txRepo, familyRepo: familyRepo}
}

type DashboardData struct {
	TotalIncome       float64
	TotalExpense      float64
	Monthly           []repository.MonthlyTotal
	RecentTransactions []*domain.Transaction
}

func (s *DashboardService) GetDashboard(ctx context.Context, userID string, familyID *string, months int) (*DashboardData, error) {
	if months <= 0 || months > 12 {
		months = 6
	}
	if familyID != nil {
		isMember, err := s.familyRepo.IsMember(ctx, *familyID, userID)
		if err != nil {
			return nil, fmt.Errorf("check membership: %w", err)
		}
		if !isMember {
			return nil, fmt.Errorf("%w: not a family member", domain.ErrForbidden)
		}
	}
	totals, err := s.txRepo.GetMonthlyTotals(ctx, userID, familyID, months)
	if err != nil {
		return nil, err
	}
	var totalIncome, totalExpense float64
	for _, m := range totals {
		totalIncome += m.TotalIncome
		totalExpense += m.TotalExpense
	}
	recent, _, err := s.txRepo.List(ctx, domain.TransactionFilter{
		FamilyID:  familyID,
		PageSize:  5,
		PageToken: 0,
	})
	if err != nil {
		return nil, err
	}
	return &DashboardData{
		TotalIncome:       totalIncome,
		TotalExpense:      totalExpense,
		Monthly:           totals,
		RecentTransactions: recent,
	}, nil
}
