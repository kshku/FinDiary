package api

import (
	"context"

	"github.com/bufbuild/connect-go"
	pb "github.com/kshku/findiary/backend/internal/api/findiary/v1"
	"github.com/kshku/findiary/backend/internal/service"
)

type DashboardHandler struct {
	svc *service.DashboardService
}

func NewDashboardHandler(svc *service.DashboardService) *DashboardHandler {
	return &DashboardHandler{svc: svc}
}

func (h *DashboardHandler) GetDashboard(ctx context.Context, req *connect.Request[pb.GetDashboardRequest]) (*connect.Response[pb.GetDashboardResponse], error) {
	userID := UserIDFromContext(ctx)
	months := int(req.Msg.Months)
	data, err := h.svc.GetDashboard(ctx, userID, req.Msg.FamilyId, months)
	if err != nil {
		return nil, mapError(err)
	}
	monthly := make([]*pb.MonthlySummary, len(data.Monthly))
	for i, m := range data.Monthly {
		monthly[i] = &pb.MonthlySummary{
			YearMonth:    m.YearMonth,
			TotalIncome:  m.TotalIncome,
			TotalExpense: m.TotalExpense,
		}
	}
	txs := make([]*pb.Transaction, len(data.RecentTransactions))
	for i, tx := range data.RecentTransactions {
		txs[i] = domainTransactionToProto(tx)
	}
	return connect.NewResponse(&pb.GetDashboardResponse{
		TotalIncome:        data.TotalIncome,
		TotalExpense:       data.TotalExpense,
		Monthly:            monthly,
		RecentTransactions: txs,
	}), nil
}
