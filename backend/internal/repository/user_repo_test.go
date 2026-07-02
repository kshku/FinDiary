package repository_test

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/repository"
	"github.com/stretchr/testify/require"
)

func TestUserRepo_CreateAndFind(t *testing.T) {
	db := setupTestDB(t)
	repo := repository.NewUserRepo(db)

	ctx := context.Background()
	now := time.Now().UTC().Truncate(time.Millisecond)

	user := &domain.User{
		ID:           uuid.New().String(),
		Email:        "test@example.com",
		PasswordHash: "hash",
		DisplayName:  "Test User",
		CreatedAt:    now,
		UpdatedAt:    now,
	}

	err := repo.Create(ctx, user)
	require.NoError(t, err)

	found, err := repo.FindByEmail(ctx, "test@example.com")
	require.NoError(t, err)
	require.Equal(t, user.ID, found.ID)
	require.Equal(t, user.Email, found.Email)
	require.Equal(t, user.DisplayName, found.DisplayName)

	found2, err := repo.FindByID(ctx, user.ID)
	require.NoError(t, err)
	require.Equal(t, user.Email, found2.Email)
}

func TestUserRepo_CreateDuplicateEmail(t *testing.T) {
	db := setupTestDB(t)
	repo := repository.NewUserRepo(db)

	ctx := context.Background()
	now := time.Now().UTC().Truncate(time.Millisecond)

	user1 := &domain.User{
		ID:           uuid.New().String(),
		Email:        "dupe@example.com",
		PasswordHash: "hash1",
		DisplayName:  "User 1",
		CreatedAt:    now,
		UpdatedAt:    now,
	}
	user2 := &domain.User{
		ID:           uuid.New().String(),
		Email:        "dupe@example.com",
		PasswordHash: "hash2",
		DisplayName:  "User 2",
		CreatedAt:    now,
		UpdatedAt:    now,
	}

	require.NoError(t, repo.Create(ctx, user1))
	err := repo.Create(ctx, user2)
	require.ErrorIs(t, err, domain.ErrAlreadyExists)
}

func TestUserRepo_NotFound(t *testing.T) {
	db := setupTestDB(t)
	repo := repository.NewUserRepo(db)

	_, err := repo.FindByEmail(context.Background(), "nobody@example.com")
	require.ErrorIs(t, err, domain.ErrNotFound)

	_, err = repo.FindByID(context.Background(), uuid.New().String())
	require.ErrorIs(t, err, domain.ErrNotFound)
}
