package repository

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/kshku/findiary/backend/internal/domain"
)

type CategoryRepo struct {
	pool *pgxpool.Pool
}

func NewCategoryRepo(pool *pgxpool.Pool) *CategoryRepo {
	return &CategoryRepo{pool: pool}
}

func (r *CategoryRepo) Create(ctx context.Context, cat *domain.Category) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO categories (id, scope, family_id, created_by, name, type, icon, color, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
		cat.ID, cat.Scope, cat.FamilyID, cat.CreatedBy, cat.Name, cat.Type, cat.Icon, cat.Color,
		cat.CreatedAt, cat.UpdatedAt,
	)
	if err != nil {
		if isUniqueViolation(err) {
			return fmt.Errorf("%w: category", domain.ErrAlreadyExists)
		}
		return fmt.Errorf("create category: %w", err)
	}
	return nil
}

func (r *CategoryRepo) FindByID(ctx context.Context, id string) (*domain.Category, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT id, scope, family_id, created_by, name, type, icon, color, created_at, updated_at
		 FROM categories WHERE id = $1`, id)
	return scanCategory(row)
}

func (r *CategoryRepo) Update(ctx context.Context, cat *domain.Category) error {
	ct, err := r.pool.Exec(ctx,
		`UPDATE categories SET name = $1, icon = $2, color = $3, updated_at = $4 WHERE id = $5`,
		cat.Name, cat.Icon, cat.Color, cat.UpdatedAt, cat.ID)
	if err != nil {
		return fmt.Errorf("update category: %w", err)
	}
	if ct.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

func (r *CategoryRepo) Delete(ctx context.Context, id string) error {
	ct, err := r.pool.Exec(ctx,
		`DELETE FROM categories WHERE id = $1`, id)
	if err != nil {
		return fmt.Errorf("delete category: %w", err)
	}
	if ct.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

func (r *CategoryRepo) List(ctx context.Context, scope string, familyID *string, catType string) ([]*domain.Category, error) {
	query := `SELECT id, scope, family_id, created_by, name, type, icon, color, created_at, updated_at FROM categories WHERE 1=1`
	var args []any
	argIdx := 1

	if scope != "" {
		query += fmt.Sprintf(" AND scope = $%d", argIdx)
		args = append(args, scope)
		argIdx++
	}
	if familyID != nil {
		query += fmt.Sprintf(" AND family_id = $%d", argIdx)
		args = append(args, *familyID)
		argIdx++
	}
	if catType != "" {
		query += fmt.Sprintf(" AND type = $%d", argIdx)
		args = append(args, catType)
		argIdx++
	}

	query += " ORDER BY name"

	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("list categories: %w", err)
	}
	defer rows.Close()

	var categories []*domain.Category
	for rows.Next() {
		c, err := scanCategory(rows)
		if err != nil {
			return nil, err
		}
		categories = append(categories, c)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("list categories rows: %w", err)
	}
	return categories, nil
}

func scanCategory(row scannable) (*domain.Category, error) {
	var c domain.Category
	var createdAt, updatedAt time.Time
	err := row.Scan(&c.ID, &c.Scope, &c.FamilyID, &c.CreatedBy, &c.Name, &c.Type, &c.Icon, &c.Color,
		&createdAt, &updatedAt)
	if err != nil {
		if strings.Contains(err.Error(), "no rows in result set") {
			return nil, domain.ErrNotFound
		}
		return nil, fmt.Errorf("scan category: %w", err)
	}
	c.CreatedAt = createdAt.Format(time.RFC3339Nano)
	c.UpdatedAt = updatedAt.Format(time.RFC3339Nano)
	return &c, nil
}
