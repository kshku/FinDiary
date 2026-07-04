package repository

import (
	"context"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/kshku/findiary/backend/internal/domain"
)

type UserRepo struct {
	pool *pgxpool.Pool
}

func NewUserRepo(pool *pgxpool.Pool) *UserRepo {
	return &UserRepo{pool: pool}
}

func (r *UserRepo) Create(ctx context.Context, user *domain.User) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO users (id, email, password_hash, display_name, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6)`,
		user.ID, user.Email, user.PasswordHash, user.DisplayName,
		user.CreatedAt, user.UpdatedAt,
	)
	if err != nil {
		if isUniqueViolation(err) {
			return fmt.Errorf("%w: email already registered", domain.ErrAlreadyExists)
		}
		return fmt.Errorf("create user: %w", err)
	}
	return nil
}

func (r *UserRepo) FindByID(ctx context.Context, id string) (*domain.User, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT id, email, password_hash, display_name, created_at, updated_at
		 FROM users WHERE id = $1`, id)
	return scanUser(row)
}

func (r *UserRepo) FindByEmail(ctx context.Context, email string) (*domain.User, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT id, email, password_hash, display_name, created_at, updated_at
		 FROM users WHERE email = $1`, email)
	return scanUser(row)
}

type scannable interface {
	Scan(dest ...any) error
}

func scanUser(row scannable) (*domain.User, error) {
	u := &domain.User{}
	err := row.Scan(&u.ID, &u.Email, &u.PasswordHash, &u.DisplayName,
		&u.CreatedAt, &u.UpdatedAt)
	if err != nil {
		if strings.Contains(err.Error(), "no rows in result set") {
			return nil, domain.ErrNotFound
		}
		return nil, fmt.Errorf("scan user: %w", err)
	}
	return u, nil
}

func isUniqueViolation(err error) bool {
	return err != nil && (strings.Contains(err.Error(), "duplicate key") ||
		strings.Contains(err.Error(), "23505"))
}
