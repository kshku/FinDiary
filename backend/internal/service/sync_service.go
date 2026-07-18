package service

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/kshku/findiary/backend/internal/domain"
)

type SyncRepo interface {
	GetOrCreateCheckpoint(ctx context.Context, userID string, scopeID *string, scopeType string) (*domain.SyncCheckpoint, error)
	UpdateCheckpoint(ctx context.Context, userID string, scopeID *string, scopeType string, checkpoint int64) error
	AppendChangeLog(ctx context.Context, entry domain.ChangeLogEntry) error
	GetChangesSince(ctx context.Context, scopeID *string, since int64) ([]domain.ChangeLogEntry, error)
}

type SyncService struct {
	syncRepo     SyncRepo
	txRepo       domain.TransactionRepository
	categoryRepo domain.CategoryRepository
	familyRepo   domain.FamilyRepository
	userRepo     domain.UserRepository
}

func NewSyncService(
	syncRepo SyncRepo,
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
	NewCheckpoint int64
	RemoteChanges []domain.ChangeLogEntry
	Conflicts     []domain.ConflictInfo
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
	_ = cp

	var conflicts []domain.ConflictInfo
	now := time.Now().UTC()

	for _, ch := range localChanges {
		switch ch.Action {
		case "create", "update":
			conflict, snapshot, err := s.applyUpsert(ctx, userID, scopePtr, ch)
			if err != nil {
				return nil, fmt.Errorf("apply %s %s: %w", ch.EntityType, ch.EntityID, err)
			}
			if conflict != nil {
				conflicts = append(conflicts, *conflict)
			}

			clEntry := domain.ChangeLogEntry{
				FamilyID:        scopePtr,
				ChangedBy:       userID,
				EntityType:      ch.EntityType,
				EntityID:        ch.EntityID,
				Action:          ch.Action,
				Snapshot:        snapshot,
				ChangedFields:   ch.ChangedFields,
				ServerTimestamp: now,
				ClientTimestamp: ch.ClientTimestamp,
			}
			if err := s.syncRepo.AppendChangeLog(ctx, clEntry); err != nil {
				return nil, fmt.Errorf("append changelog: %w", err)
			}

		case "delete":
			conflict, err := s.applyDelete(ctx, userID, ch)
			if err != nil {
				return nil, fmt.Errorf("apply delete %s: %w", ch.EntityID, err)
			}
			if conflict != nil {
				conflicts = append(conflicts, *conflict)
			}

			clEntry := domain.ChangeLogEntry{
				FamilyID:        scopePtr,
				ChangedBy:       userID,
				EntityType:      ch.EntityType,
				EntityID:        ch.EntityID,
				Action:          ch.Action,
				Snapshot:        string(ch.Snapshot),
				ChangedFields:   ch.ChangedFields,
				ServerTimestamp: now,
				ClientTimestamp: ch.ClientTimestamp,
			}
			if err := s.syncRepo.AppendChangeLog(ctx, clEntry); err != nil {
				return nil, fmt.Errorf("append changelog: %w", err)
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

func (s *SyncService) applyUpsert(ctx context.Context, userID string, scopePtr *string, ch domain.SyncChange) (*domain.ConflictInfo, string, error) {
	switch ch.EntityType {
	case "transaction":
		return s.applyTransactionUpsert(ctx, userID, scopePtr, ch)
	case "category":
		return s.applyCategoryUpsert(ctx, userID, scopePtr, ch)
	default:
		return nil, "", fmt.Errorf("%w: unknown entity type %s", domain.ErrInvalidInput, ch.EntityType)
	}
}

func (s *SyncService) applyTransactionUpsert(ctx context.Context, userID string, scopePtr *string, ch domain.SyncChange) (*domain.ConflictInfo, string, error) {
	tx, err := domain.UnmarshalTransaction(ch.Snapshot)
	if err != nil {
		return nil, "", fmt.Errorf("unmarshal transaction: %w", err)
	}

	existing, err := s.txRepo.FindByID(ctx, ch.EntityID)
	if err != nil && !errors.Is(err, domain.ErrNotFound) {
		return nil, "", err
	}

	if existing != nil && existing.DeletedAt != nil {
		return &domain.ConflictInfo{
			EntityType:  "transaction",
			EntityID:    ch.EntityID,
			Field:       "deleted_at",
			ServerValue: "deleted",
		}, "", nil
	}

	if existing != nil {
		existingUpdatedAt, err := time.Parse(time.RFC3339Nano, existing.UpdatedAt)
		if err != nil {
			return nil, "", fmt.Errorf("parse existing updated_at: %w", err)
		}
		if !ch.ClientTimestamp.After(existingUpdatedAt) {
			return &domain.ConflictInfo{
				EntityType:  "transaction",
				EntityID:    ch.EntityID,
				Field:       "updated_at",
				LocalValue:  ch.ClientTimestamp.Format(time.RFC3339),
				ServerValue: existing.UpdatedAt,
			}, "", nil
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
			return nil, "", err
		}
		snapshot, _ := json.Marshal(existing)
		return nil, string(snapshot), nil
	}

	now := time.Now().UTC().Format(time.RFC3339Nano)
	tx.ID = ch.EntityID
	tx.FamilyID = scopePtr
	tx.CreatedBy = userID
	tx.CreatedAt = now
	tx.UpdatedAt = now
	if err := s.txRepo.Create(ctx, tx); err != nil {
		return nil, "", err
	}
	snapshot, _ := json.Marshal(tx)
	return nil, string(snapshot), nil
}

func (s *SyncService) applyCategoryUpsert(ctx context.Context, userID string, scopePtr *string, ch domain.SyncChange) (*domain.ConflictInfo, string, error) {
	var cat domain.Category
	if err := json.Unmarshal(ch.Snapshot, &cat); err != nil {
		return nil, "", fmt.Errorf("unmarshal category: %w", err)
	}

	existing, err := s.categoryRepo.FindByID(ctx, ch.EntityID)
	if err != nil && !errors.Is(err, domain.ErrNotFound) {
		return nil, "", err
	}

	if existing != nil {
		existingUpdatedAt, err := time.Parse(time.RFC3339Nano, existing.UpdatedAt)
		if err != nil {
			return nil, "", fmt.Errorf("parse existing updated_at: %w", err)
		}
		if !ch.ClientTimestamp.After(existingUpdatedAt) {
			return &domain.ConflictInfo{
				EntityType:  "category",
				EntityID:    ch.EntityID,
				Field:       "updated_at",
				LocalValue:  ch.ClientTimestamp.Format(time.RFC3339),
				ServerValue: existing.UpdatedAt,
			}, "", nil
		}
		now := time.Now().UTC().Format(time.RFC3339Nano)
		existing.Name = cat.Name
		existing.Type = cat.Type
		existing.Icon = cat.Icon
		existing.Color = cat.Color
		existing.UpdatedAt = now
		if err := s.categoryRepo.Update(ctx, existing); err != nil {
			return nil, "", err
		}
		snapshot, _ := json.Marshal(existing)
		return nil, string(snapshot), nil
	}

	now := time.Now().UTC().Format(time.RFC3339Nano)
	cat.ID = ch.EntityID
	cat.FamilyID = scopePtr
	cat.CreatedBy = &userID
	cat.CreatedAt = now
	cat.UpdatedAt = now
	if err := s.categoryRepo.Create(ctx, &cat); err != nil {
		return nil, "", err
	}
	snapshot, _ := json.Marshal(cat)
	return nil, string(snapshot), nil
}

func (s *SyncService) applyDelete(ctx context.Context, userID string, ch domain.SyncChange) (*domain.ConflictInfo, error) {
	switch ch.EntityType {
	case "transaction":
		existing, err := s.txRepo.FindByID(ctx, ch.EntityID)
		if err != nil {
			if errors.Is(err, domain.ErrNotFound) {
				return nil, nil
			}
			return nil, err
		}
		if existing.DeletedAt != nil {
			return nil, nil
		}
		return nil, s.txRepo.SoftDelete(ctx, ch.EntityID)
	case "category":
		existing, err := s.categoryRepo.FindByID(ctx, ch.EntityID)
		if err != nil {
			if errors.Is(err, domain.ErrNotFound) {
				return nil, nil
			}
			return nil, err
		}
		_ = existing
		return nil, s.categoryRepo.Delete(ctx, ch.EntityID)
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
