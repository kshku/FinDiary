package service

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/kshku/findiary/backend/internal/domain"
)

type TransactionService struct {
	txRepo      domain.TransactionRepository
	categoryRepo domain.CategoryRepository
	familyRepo  domain.FamilyRepository
}

func NewTransactionService(txRepo domain.TransactionRepository, categoryRepo domain.CategoryRepository, familyRepo domain.FamilyRepository) *TransactionService {
	return &TransactionService{txRepo: txRepo, categoryRepo: categoryRepo, familyRepo: familyRepo}
}

func (s *TransactionService) Create(ctx context.Context, userID string, req domain.CreateTxRequest) (*domain.Transaction, error) {
	if req.Type != "income" && req.Type != "expense" {
		return nil, fmt.Errorf("%w: type must be income or expense", domain.ErrInvalidInput)
	}
	if req.Amount <= 0 {
		return nil, fmt.Errorf("%w: amount must be positive", domain.ErrInvalidInput)
	}

	if _, err := s.categoryRepo.FindByID(ctx, req.CategoryID); err != nil {
		return nil, fmt.Errorf("%w: category not found", domain.ErrInvalidInput)
	}

	if req.FamilyID != nil {
		isMember, err := s.familyRepo.IsMember(ctx, *req.FamilyID, userID)
		if err != nil {
			return nil, fmt.Errorf("check membership: %w", err)
		}
		if !isMember {
			return nil, fmt.Errorf("%w: not a family member", domain.ErrForbidden)
		}
	}

	now := time.Now().UTC().Format(time.RFC3339Nano)
	tx := &domain.Transaction{
		ID:          uuid.New().String(),
		FamilyID:    req.FamilyID,
		CreatedBy:   userID,
		Type:        req.Type,
		Amount:      req.Amount,
		Currency:    req.Currency,
		CategoryID:  req.CategoryID,
		Description: req.Description,
		Date:        req.Date,
		CreatedAt:   now,
		UpdatedAt:   now,
	}

	if err := s.txRepo.Create(ctx, tx); err != nil {
		return nil, err
	}
	return tx, nil
}

func (s *TransactionService) Get(ctx context.Context, userID, txID string) (*domain.Transaction, error) {
	tx, err := s.txRepo.FindByID(ctx, txID)
	if err != nil {
		return nil, err
	}
	if tx.DeletedAt != nil {
		return nil, fmt.Errorf("%w: transaction not found", domain.ErrNotFound)
	}
	if err := s.canAccess(ctx, userID, tx); err != nil {
		return nil, err
	}
	return tx, nil
}

func (s *TransactionService) Update(ctx context.Context, userID, txID string, req domain.UpdateTxRequest) (*domain.Transaction, error) {
	tx, err := s.txRepo.FindByID(ctx, txID)
	if err != nil {
		return nil, err
	}
	if tx.DeletedAt != nil {
		return nil, fmt.Errorf("%w: transaction not found", domain.ErrNotFound)
	}
	if req.Type != "" && req.Type != "income" && req.Type != "expense" {
		return nil, fmt.Errorf("%w: type must be income or expense", domain.ErrInvalidInput)
	}
	if req.Amount <= 0 {
		return nil, fmt.Errorf("%w: amount must be positive", domain.ErrInvalidInput)
	}
	if err := s.canModify(ctx, userID, tx); err != nil {
		return nil, err
	}

	now := time.Now().UTC().Format(time.RFC3339Nano)
	tx.Type = req.Type
	tx.Amount = req.Amount
	tx.Currency = req.Currency
	tx.CategoryID = req.CategoryID
	tx.Description = req.Description
	tx.Date = req.Date
	tx.UpdatedAt = now

	if err := s.txRepo.Update(ctx, tx); err != nil {
		return nil, err
	}
	return tx, nil
}

func (s *TransactionService) Delete(ctx context.Context, userID, txID string) error {
	tx, err := s.txRepo.FindByID(ctx, txID)
	if err != nil {
		return err
	}
	if tx.DeletedAt != nil {
		return fmt.Errorf("%w: transaction not found", domain.ErrNotFound)
	}
	if err := s.canModify(ctx, userID, tx); err != nil {
		return err
	}
	return s.txRepo.SoftDelete(ctx, txID)
}

func (s *TransactionService) List(ctx context.Context, userID string, filter domain.TransactionFilter) ([]*domain.Transaction, int, error) {
	if filter.FamilyID != nil {
		isMember, err := s.familyRepo.IsMember(ctx, *filter.FamilyID, userID)
		if err != nil {
			return nil, 0, fmt.Errorf("check membership: %w", err)
		}
		if !isMember {
			return nil, 0, fmt.Errorf("%w: not a family member", domain.ErrForbidden)
		}
	}
	return s.txRepo.List(ctx, filter)
}

func (s *TransactionService) canAccess(ctx context.Context, userID string, tx *domain.Transaction) error {
	if tx.FamilyID != nil {
		isMember, err := s.familyRepo.IsMember(ctx, *tx.FamilyID, userID)
		if err != nil {
			return fmt.Errorf("check membership: %w", err)
		}
		if !isMember {
			return fmt.Errorf("%w: access denied", domain.ErrForbidden)
		}
		return nil
	}
	if tx.CreatedBy != userID {
		return fmt.Errorf("%w: access denied", domain.ErrForbidden)
	}
	return nil
}

func (s *TransactionService) canModify(ctx context.Context, userID string, tx *domain.Transaction) error {
	if tx.FamilyID != nil {
		isMember, err := s.familyRepo.IsMember(ctx, *tx.FamilyID, userID)
		if err != nil {
			return fmt.Errorf("check membership: %w", err)
		}
		if !isMember {
			return fmt.Errorf("%w: access denied", domain.ErrForbidden)
		}
		if tx.CreatedBy != userID {
			ok, err := isAdminOrOwner(ctx, s.familyRepo, *tx.FamilyID, userID)
			if err != nil {
				return err
			}
			if !ok {
				return fmt.Errorf("%w: only the creator or admin can modify", domain.ErrForbidden)
			}
		}
		return nil
	}
	if tx.CreatedBy != userID {
		return fmt.Errorf("%w: access denied", domain.ErrForbidden)
	}
	return nil
}
