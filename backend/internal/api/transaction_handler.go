package api

import (
	"context"

	"github.com/bufbuild/connect-go"
	pb "github.com/kshku/findiary/backend/internal/api/findiary/v1"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/service"
)

type TransactionHandler struct {
	svc *service.TransactionService
}

func NewTransactionHandler(svc *service.TransactionService) *TransactionHandler {
	return &TransactionHandler{svc: svc}
}

func (h *TransactionHandler) CreateTransaction(ctx context.Context, req *connect.Request[pb.CreateTransactionRequest]) (*connect.Response[pb.CreateTransactionResponse], error) {
	userID := UserIDFromContext(ctx)
	tx, err := h.svc.Create(ctx, userID, domain.CreateTxRequest{
		FamilyID:    req.Msg.FamilyId,
		Type:        req.Msg.Type,
		Amount:      req.Msg.Amount,
		Currency:    req.Msg.Currency,
		CategoryID:  req.Msg.CategoryId,
		Description: req.Msg.Description,
		Date:        req.Msg.Date,
	})
	if err != nil {
		return nil, mapError(err)
	}
	return connect.NewResponse(&pb.CreateTransactionResponse{
		Transaction: domainTransactionToProto(tx),
	}), nil
}

func (h *TransactionHandler) GetTransaction(ctx context.Context, req *connect.Request[pb.GetTransactionRequest]) (*connect.Response[pb.GetTransactionResponse], error) {
	userID := UserIDFromContext(ctx)
	tx, err := h.svc.Get(ctx, userID, req.Msg.Id)
	if err != nil {
		return nil, mapError(err)
	}
	return connect.NewResponse(&pb.GetTransactionResponse{
		Transaction: domainTransactionToProto(tx),
	}), nil
}

func (h *TransactionHandler) UpdateTransaction(ctx context.Context, req *connect.Request[pb.UpdateTransactionRequest]) (*connect.Response[pb.UpdateTransactionResponse], error) {
	userID := UserIDFromContext(ctx)
	tx, err := h.svc.Update(ctx, userID, req.Msg.Id, domain.UpdateTxRequest{
		Type:        req.Msg.Type,
		Amount:      req.Msg.Amount,
		Currency:    req.Msg.Currency,
		CategoryID:  req.Msg.CategoryId,
		Description: req.Msg.Description,
		Date:        req.Msg.Date,
	})
	if err != nil {
		return nil, mapError(err)
	}
	return connect.NewResponse(&pb.UpdateTransactionResponse{
		Transaction: domainTransactionToProto(tx),
	}), nil
}

func (h *TransactionHandler) DeleteTransaction(ctx context.Context, req *connect.Request[pb.DeleteTransactionRequest]) (*connect.Response[pb.DeleteTransactionResponse], error) {
	userID := UserIDFromContext(ctx)
	err := h.svc.Delete(ctx, userID, req.Msg.Id)
	if err != nil {
		return nil, mapError(err)
	}
	return connect.NewResponse(&pb.DeleteTransactionResponse{}), nil
}

func (h *TransactionHandler) ListTransactions(ctx context.Context, req *connect.Request[pb.ListTransactionsRequest]) (*connect.Response[pb.ListTransactionsResponse], error) {
	userID := UserIDFromContext(ctx)
	offset := int(req.Msg.PageToken)
	transactions, total, err := h.svc.List(ctx, userID, domain.TransactionFilter{
		FamilyID:   req.Msg.FamilyId,
		Type:       req.Msg.Type,
		CategoryID: req.Msg.CategoryId,
		StartDate:  req.Msg.StartDate,
		EndDate:    req.Msg.EndDate,
		PageSize:   int(req.Msg.PageSize),
		PageToken:  offset,
	})
	if err != nil {
		return nil, mapError(err)
	}
	protoTxs := make([]*pb.Transaction, len(transactions))
	for i, tx := range transactions {
		protoTxs[i] = domainTransactionToProto(tx)
	}
	var nextPageToken int32
	if offset+len(transactions) < total {
		nextPageToken = int32(offset + len(transactions))
	}
	return connect.NewResponse(&pb.ListTransactionsResponse{
		Transactions:  protoTxs,
		Total:         int32(total),
		NextPageToken: nextPageToken,
	}), nil
}

func domainTransactionToProto(tx *domain.Transaction) *pb.Transaction {
	return &pb.Transaction{
		Id:          tx.ID,
		FamilyId:    tx.FamilyID,
		CreatedBy:   tx.CreatedBy,
		Type:        tx.Type,
		Amount:      tx.Amount,
		Currency:    tx.Currency,
		CategoryId:  tx.CategoryID,
		Description: tx.Description,
		Date:        tx.Date,
		CreatedAt:   parseTimeToProto(tx.CreatedAt),
		UpdatedAt:   parseTimeToProto(tx.UpdatedAt),
	}
}
