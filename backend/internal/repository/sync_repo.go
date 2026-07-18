package repository

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/kshku/findiary/backend/internal/domain"
)

type SyncRepo struct {
	pool *pgxpool.Pool
}

func NewSyncRepo(pool *pgxpool.Pool) *SyncRepo {
	return &SyncRepo{pool: pool}
}

func (r *SyncRepo) GetOrCreateCheckpoint(ctx context.Context, userID string, scopeID *string, scopeType string) (*domain.SyncCheckpoint, error) {
	var rawScopeID *uuid.UUID
	if scopeID != nil {
		uid, err := uuid.Parse(*scopeID)
		if err != nil {
			return nil, fmt.Errorf("parse scope_id: %w", err)
		}
		rawScopeID = &uid
	}

	cp := &domain.SyncCheckpoint{}
	err := r.pool.QueryRow(ctx,
		`SELECT id, user_id, scope_id, scope_type, last_checkpoint, updated_at
		 FROM sync_checkpoints
		 WHERE user_id = $1 AND (scope_id = $2 OR (scope_id IS NULL AND $2 IS NULL)) AND scope_type = $3`,
		userID, rawScopeID, scopeType,
	).Scan(&cp.ID, &cp.UserID, &cp.ScopeID, &cp.ScopeType, &cp.LastCheckpoint, &cp.UpdatedAt)

	if err == nil {
		return cp, nil
	}

	if !strings.Contains(err.Error(), "no rows in result set") {
		return nil, fmt.Errorf("query checkpoint: %w", err)
	}

	cp = &domain.SyncCheckpoint{
		UserID:         userID,
		ScopeID:        scopeID,
		ScopeType:      scopeType,
		LastCheckpoint: 0,
		UpdatedAt:      time.Now().UTC(),
	}
	err = r.pool.QueryRow(ctx,
		`INSERT INTO sync_checkpoints (user_id, scope_id, scope_type, last_checkpoint, updated_at)
		 VALUES ($1, $2, $3, 0, $4)
		 RETURNING id, user_id, scope_id, scope_type, last_checkpoint, updated_at`,
		userID, rawScopeID, scopeType, cp.UpdatedAt,
	).Scan(&cp.ID, &cp.UserID, &cp.ScopeID, &cp.ScopeType, &cp.LastCheckpoint, &cp.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("create checkpoint: %w", err)
	}
	return cp, nil
}

func (r *SyncRepo) UpdateCheckpoint(ctx context.Context, userID string, scopeID *string, scopeType string, newCheckpoint int64) error {
	var rawScopeID *uuid.UUID
	if scopeID != nil {
		uid, err := uuid.Parse(*scopeID)
		if err != nil {
			return fmt.Errorf("parse scope_id: %w", err)
		}
		rawScopeID = &uid
	}

	_, err := r.pool.Exec(ctx,
		`UPDATE sync_checkpoints
		 SET last_checkpoint = $1, updated_at = NOW()
		 WHERE user_id = $2 AND (scope_id = $3 OR (scope_id IS NULL AND $3 IS NULL)) AND scope_type = $4`,
		newCheckpoint, userID, rawScopeID, scopeType,
	)
	if err != nil {
		return fmt.Errorf("update checkpoint: %w", err)
	}
	return nil
}

func (r *SyncRepo) GetChangesSince(ctx context.Context, scopeID *string, checkpointID int64) ([]domain.ChangeLogEntry, error) {
	var rawScopeID *uuid.UUID
	if scopeID != nil {
		uid, err := uuid.Parse(*scopeID)
		if err != nil {
			return nil, fmt.Errorf("parse scope_id: %w", err)
		}
		rawScopeID = &uid
	}

	rows, err := r.pool.Query(ctx,
		`SELECT id, family_id, changed_by, entity_type, entity_id, action, snapshot, changed_fields, server_timestamp, client_timestamp
		 FROM change_log
		 WHERE id > $1 AND (family_id = $2 OR (family_id IS NULL AND $2 IS NULL))
		 ORDER BY id ASC`,
		checkpointID, rawScopeID,
	)
	if err != nil {
		return nil, fmt.Errorf("query change_log: %w", err)
	}
	defer rows.Close()

	var entries []domain.ChangeLogEntry
	for rows.Next() {
		var e domain.ChangeLogEntry
		var familyID *uuid.UUID
		err := rows.Scan(&e.ID, &familyID, &e.ChangedBy, &e.EntityType, &e.EntityID, &e.Action, &e.Snapshot, &e.ChangedFields, &e.ServerTimestamp, &e.ClientTimestamp)
		if err != nil {
			return nil, fmt.Errorf("scan change_log row: %w", err)
		}
		if familyID != nil {
			fid := familyID.String()
			e.FamilyID = &fid
		}
		entries = append(entries, e)
	}
	return entries, nil
}

func (r *SyncRepo) AppendChangeLog(ctx context.Context, entry domain.ChangeLogEntry) error {
	var familyID *uuid.UUID
	if entry.FamilyID != nil {
		uid, err := uuid.Parse(*entry.FamilyID)
		if err != nil {
			return fmt.Errorf("parse family_id: %w", err)
		}
		familyID = &uid
	}

	_, err := r.pool.Exec(ctx,
		`INSERT INTO change_log (family_id, changed_by, entity_type, entity_id, action, snapshot, changed_fields, server_timestamp, client_timestamp)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
		familyID, entry.ChangedBy, entry.EntityType, entry.EntityID, entry.Action, entry.Snapshot, entry.ChangedFields, entry.ServerTimestamp, entry.ClientTimestamp,
	)
	if err != nil {
		return fmt.Errorf("append change_log: %w", err)
	}
	return nil
}
