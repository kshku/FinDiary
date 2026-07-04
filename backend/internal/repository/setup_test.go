package repository_test

import (
	"context"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/repository"
	"github.com/stretchr/testify/require"
)

const schema = `
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100) NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

CREATE TABLE IF NOT EXISTS families (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS family_members (
    family_id UUID NOT NULL REFERENCES families(id),
    user_id UUID NOT NULL REFERENCES users(id),
    role VARCHAR(20) NOT NULL DEFAULT 'member',
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    invited_by UUID REFERENCES users(id),
    PRIMARY KEY (family_id, user_id)
);

CREATE TABLE IF NOT EXISTS invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES families(id),
    email VARCHAR(255) NOT NULL,
    code VARCHAR(64) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY,
    scope VARCHAR(20) NOT NULL DEFAULT 'system',
    family_id UUID REFERENCES families(id),
    created_by UUID REFERENCES users(id),
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense')),
    icon VARCHAR(50),
    color VARCHAR(7),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_categories_scope ON categories(scope);
CREATE INDEX IF NOT EXISTS idx_categories_family ON categories(family_id);

CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY,
    family_id UUID REFERENCES families(id),
    created_by UUID NOT NULL REFERENCES users(id),
    type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense')),
    amount NUMERIC(18,2) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    category_id UUID NOT NULL REFERENCES categories(id),
    description TEXT,
    date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_transactions_family ON transactions(family_id);
CREATE INDEX IF NOT EXISTS idx_transactions_created_by ON transactions(created_by);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date);
CREATE INDEX IF NOT EXISTS idx_transactions_deleted_at ON transactions(deleted_at);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
`

func setupTestDB(t *testing.T) *pgxpool.Pool {
	t.Helper()

	dsn := os.Getenv("TEST_DATABASE_URL")
	if dsn == "" {
		dsn = "postgres://findiary:findiary_dev@localhost:5432/findiary_test?sslmode=disable"
	}

	pool, err := pgxpool.New(context.Background(), dsn)
	if err != nil {
		t.Fatalf("connect to test db: %v", err)
	}
	t.Cleanup(pool.Close)

	_, err = pool.Exec(context.Background(), schema)
	if err != nil {
		t.Fatalf("apply schema: %v", err)
	}

	_, err = pool.Exec(context.Background(), "TRUNCATE TABLE transactions, invitations, family_members, categories, families, users CASCADE")
	if err != nil {
		t.Fatalf("truncate tables: %v", err)
	}

	return pool
}

func createTestUser(t *testing.T, ctx context.Context, db *pgxpool.Pool) *domain.User {
	t.Helper()
	userRepo := repository.NewUserRepo(db)
	now := time.Now().UTC().Truncate(time.Millisecond)
	user := &domain.User{
		ID:           uuid.New().String(),
		Email:        fmt.Sprintf("user-%s@example.com", uuid.New().String()[:8]),
		PasswordHash: "hash",
		DisplayName:  "Test User",
		CreatedAt:    now,
		UpdatedAt:    now,
	}
	require.NoError(t, userRepo.Create(ctx, user))
	return user
}
