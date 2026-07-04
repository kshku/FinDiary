package repository

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/kshku/findiary/backend/internal/domain"
)

type FamilyRepo struct {
	pool *pgxpool.Pool
}

func NewFamilyRepo(pool *pgxpool.Pool) *FamilyRepo {
	return &FamilyRepo{pool: pool}
}

func (r *FamilyRepo) Create(ctx context.Context, family *domain.Family) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO families (id, name, owner_id, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5)`,
		family.ID, family.Name, family.OwnerID, family.CreatedAt, family.UpdatedAt,
	)
	if err != nil {
		return fmt.Errorf("create family: %w", err)
	}
	return nil
}

func (r *FamilyRepo) FindByID(ctx context.Context, id string) (*domain.Family, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT id, name, owner_id, created_at, updated_at
		 FROM families WHERE id = $1`, id)
	return scanFamily(row)
}

func (r *FamilyRepo) Update(ctx context.Context, family *domain.Family) error {
	ct, err := r.pool.Exec(ctx,
		`UPDATE families SET name = $1, updated_at = $2 WHERE id = $3`,
		family.Name, family.UpdatedAt, family.ID)
	if err != nil {
		return fmt.Errorf("update family: %w", err)
	}
	if ct.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

func (r *FamilyRepo) ListByUser(ctx context.Context, userID string) ([]*domain.Family, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT DISTINCT f.id, f.name, f.owner_id, f.created_at, f.updated_at
		 FROM families f
		 LEFT JOIN family_members fm ON f.id = fm.family_id
		 WHERE f.owner_id = $1 OR fm.user_id = $1
		 ORDER BY f.created_at DESC`, userID)
	if err != nil {
		return nil, fmt.Errorf("list families by user: %w", err)
	}
	defer rows.Close()

	var families []*domain.Family
	for rows.Next() {
		f, err := scanFamily(rows)
		if err != nil {
			return nil, err
		}
		families = append(families, f)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("list families by user rows: %w", err)
	}
	return families, nil
}

func (r *FamilyRepo) AddMember(ctx context.Context, member *domain.FamilyMember) error {
	var invitedBy *string
	if member.InvitedBy != "" {
		invitedBy = &member.InvitedBy
	}
	_, err := r.pool.Exec(ctx,
		`INSERT INTO family_members (family_id, user_id, role, joined_at, invited_by)
		 VALUES ($1, $2, $3, $4, $5)`,
		member.FamilyID, member.UserID, member.Role, member.JoinedAt, invitedBy)
	if err != nil {
		if strings.Contains(err.Error(), "duplicate key") {
			return fmt.Errorf("%w: user already a member", domain.ErrAlreadyExists)
		}
		return fmt.Errorf("add family member: %w", err)
	}
	return nil
}

func (r *FamilyRepo) RemoveMember(ctx context.Context, familyID, userID string) error {
	ct, err := r.pool.Exec(ctx,
		`DELETE FROM family_members WHERE family_id = $1 AND user_id = $2`,
		familyID, userID)
	if err != nil {
		return fmt.Errorf("remove family member: %w", err)
	}
	if ct.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

func (r *FamilyRepo) ListMembers(ctx context.Context, familyID string) ([]*domain.FamilyMember, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT family_id, user_id, role, joined_at, invited_by
		 FROM family_members WHERE family_id = $1
		 ORDER BY joined_at`, familyID)
	if err != nil {
		return nil, fmt.Errorf("list family members: %w", err)
	}
	defer rows.Close()

	var members []*domain.FamilyMember
	for rows.Next() {
		m, err := scanFamilyMember(rows)
		if err != nil {
			return nil, err
		}
		members = append(members, m)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("list family members rows: %w", err)
	}
	return members, nil
}

func (r *FamilyRepo) IsMember(ctx context.Context, familyID, userID string) (bool, error) {
	var exists bool
	err := r.pool.QueryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM family_members WHERE family_id = $1 AND user_id = $2)`,
		familyID, userID).Scan(&exists)
	if err != nil {
		return false, fmt.Errorf("is member: %w", err)
	}
	return exists, nil
}

func (r *FamilyRepo) CreateInvitation(ctx context.Context, inv *domain.Invitation) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO invitations (id, family_id, email, code, status, created_by, created_at, expires_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
		inv.ID, inv.FamilyID, inv.Email, inv.Code, inv.Status, inv.CreatedBy, inv.CreatedAt, inv.ExpiresAt)
	if err != nil {
		if strings.Contains(err.Error(), "duplicate key") {
			return fmt.Errorf("%w: invitation code already exists", domain.ErrAlreadyExists)
		}
		return fmt.Errorf("create invitation: %w", err)
	}
	return nil
}

func (r *FamilyRepo) FindInvitationByCode(ctx context.Context, code string) (*domain.Invitation, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT id, family_id, email, code, status, created_by, created_at, expires_at
		 FROM invitations WHERE code = $1`, code)
	return scanInvitation(row)
}

func (r *FamilyRepo) UpdateInvitation(ctx context.Context, inv *domain.Invitation) error {
	ct, err := r.pool.Exec(ctx,
		`UPDATE invitations SET status = $1 WHERE id = $2`,
		inv.Status, inv.ID)
	if err != nil {
		return fmt.Errorf("update invitation: %w", err)
	}
	if ct.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

func (r *FamilyRepo) ListInvitations(ctx context.Context, familyID string) ([]*domain.Invitation, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, family_id, email, code, status, created_by, created_at, expires_at
		 FROM invitations WHERE family_id = $1
		 ORDER BY created_at DESC`, familyID)
	if err != nil {
		return nil, fmt.Errorf("list invitations: %w", err)
	}
	defer rows.Close()

	var invitations []*domain.Invitation
	for rows.Next() {
		inv, err := scanInvitation(rows)
		if err != nil {
			return nil, err
		}
		invitations = append(invitations, inv)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("list invitations rows: %w", err)
	}
	return invitations, nil
}

func (r *FamilyRepo) ListInvitationsByEmail(ctx context.Context, email string) ([]*domain.Invitation, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, family_id, email, code, status, created_by, created_at, expires_at
		 FROM invitations WHERE email = $1 AND status = 'pending'
		 ORDER BY created_at DESC`, email)
	if err != nil {
		return nil, fmt.Errorf("list invitations by email: %w", err)
	}
	defer rows.Close()

	var invitations []*domain.Invitation
	for rows.Next() {
		inv, err := scanInvitation(rows)
		if err != nil {
			return nil, err
		}
		invitations = append(invitations, inv)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("list invitations by email rows: %w", err)
	}
	return invitations, nil
}

func scanFamily(row scannable) (*domain.Family, error) {
	var f domain.Family
	var createdAt, updatedAt time.Time
	err := row.Scan(&f.ID, &f.Name, &f.OwnerID, &createdAt, &updatedAt)
	if err != nil {
		if strings.Contains(err.Error(), "no rows in result set") {
			return nil, domain.ErrNotFound
		}
		return nil, fmt.Errorf("scan family: %w", err)
	}
	f.CreatedAt = createdAt.Format(time.RFC3339Nano)
	f.UpdatedAt = updatedAt.Format(time.RFC3339Nano)
	return &f, nil
}

func scanFamilyMember(row scannable) (*domain.FamilyMember, error) {
	var fm domain.FamilyMember
	var joinedAt time.Time
	var invitedBy *string
	err := row.Scan(&fm.FamilyID, &fm.UserID, &fm.Role, &joinedAt, &invitedBy)
	if err != nil {
		if strings.Contains(err.Error(), "no rows in result set") {
			return nil, domain.ErrNotFound
		}
		return nil, fmt.Errorf("scan family member: %w", err)
	}
	fm.JoinedAt = joinedAt.Format(time.RFC3339Nano)
	if invitedBy != nil {
		fm.InvitedBy = *invitedBy
	}
	return &fm, nil
}

func scanInvitation(row scannable) (*domain.Invitation, error) {
	var inv domain.Invitation
	var createdAt, expiresAt time.Time
	err := row.Scan(&inv.ID, &inv.FamilyID, &inv.Email, &inv.Code, &inv.Status, &inv.CreatedBy, &createdAt, &expiresAt)
	if err != nil {
		if strings.Contains(err.Error(), "no rows in result set") {
			return nil, domain.ErrNotFound
		}
		return nil, fmt.Errorf("scan invitation: %w", err)
	}
	inv.CreatedAt = createdAt.Format(time.RFC3339Nano)
	inv.ExpiresAt = expiresAt.Format(time.RFC3339Nano)
	return &inv, nil
}
