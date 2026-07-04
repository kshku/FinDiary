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

func TestCategoryRepo_CreateAndFind(t *testing.T) {
	db := setupTestDB(t)
	repo := repository.NewCategoryRepo(db)
	ctx := context.Background()

	now := time.Now().UTC().Format(time.RFC3339Nano)
	cat := &domain.Category{
		ID:        uuid.New().String(),
		Scope:     "personal",
		Name:      "Groceries",
		Type:      "expense",
		Icon:      strPtr("shopping-cart"),
		Color:     strPtr("#FF5733"),
		CreatedAt: now,
		UpdatedAt: now,
	}

	err := repo.Create(ctx, cat)
	require.NoError(t, err)

	found, err := repo.FindByID(ctx, cat.ID)
	require.NoError(t, err)
	require.Equal(t, cat.ID, found.ID)
	require.Equal(t, cat.Name, found.Name)
	require.Equal(t, cat.Type, found.Type)
	require.Equal(t, *cat.Icon, *found.Icon)
	require.Equal(t, *cat.Color, *found.Color)
	require.Equal(t, cat.Scope, found.Scope)
}

func TestCategoryRepo_NotFound(t *testing.T) {
	db := setupTestDB(t)
	repo := repository.NewCategoryRepo(db)

	_, err := repo.FindByID(context.Background(), uuid.New().String())
	require.ErrorIs(t, err, domain.ErrNotFound)

	err = repo.Delete(context.Background(), uuid.New().String())
	require.ErrorIs(t, err, domain.ErrNotFound)
}

func TestCategoryRepo_List(t *testing.T) {
	db := setupTestDB(t)
	repo := repository.NewCategoryRepo(db)
	ctx := context.Background()

	now := time.Now().UTC().Format(time.RFC3339Nano)

	cat1 := &domain.Category{
		ID:        uuid.New().String(),
		Scope:     "personal",
		Name:      "Food",
		Type:      "expense",
		CreatedAt: now,
		UpdatedAt: now,
	}
	cat2 := &domain.Category{
		ID:        uuid.New().String(),
		Scope:     "personal",
		Name:      "Salary",
		Type:      "income",
		CreatedAt: now,
		UpdatedAt: now,
	}
	cat3 := &domain.Category{
		ID:        uuid.New().String(),
		Scope:     "system",
		Name:      "System Cat",
		Type:      "expense",
		CreatedAt: now,
		UpdatedAt: now,
	}

	require.NoError(t, repo.Create(ctx, cat1))
	require.NoError(t, repo.Create(ctx, cat2))
	require.NoError(t, repo.Create(ctx, cat3))

	// List all personal
	list, err := repo.List(ctx, "personal", nil, "")
	require.NoError(t, err)
	require.Len(t, list, 2)

	// List by type
	list, err = repo.List(ctx, "personal", nil, "income")
	require.NoError(t, err)
	require.Len(t, list, 1)
	require.Equal(t, "Salary", list[0].Name)

	// List all system
	list, err = repo.List(ctx, "system", nil, "")
	require.NoError(t, err)
	require.Len(t, list, 1)

	// List with no filters
	list, err = repo.List(ctx, "", nil, "")
	require.NoError(t, err)
	require.Len(t, list, 3)
}

func TestCategoryRepo_Delete(t *testing.T) {
	db := setupTestDB(t)
	repo := repository.NewCategoryRepo(db)
	ctx := context.Background()

	now := time.Now().UTC().Format(time.RFC3339Nano)
	cat := &domain.Category{
		ID:        uuid.New().String(),
		Scope:     "personal",
		Name:      "To Delete",
		Type:      "expense",
		CreatedAt: now,
		UpdatedAt: now,
	}
	require.NoError(t, repo.Create(ctx, cat))

	err := repo.Delete(ctx, cat.ID)
	require.NoError(t, err)

	_, err = repo.FindByID(ctx, cat.ID)
	require.ErrorIs(t, err, domain.ErrNotFound)
}

func TestCategoryRepo_Update(t *testing.T) {
	db := setupTestDB(t)
	repo := repository.NewCategoryRepo(db)
	ctx := context.Background()

	now := time.Now().UTC().Format(time.RFC3339Nano)
	cat := &domain.Category{
		ID:        uuid.New().String(),
		Scope:     "personal",
		Name:      "Old Name",
		Type:      "expense",
		Icon:      strPtr("old-icon"),
		Color:     strPtr("#000000"),
		CreatedAt: now,
		UpdatedAt: now,
	}
	require.NoError(t, repo.Create(ctx, cat))

	cat.Name = "New Name"
	cat.Icon = strPtr("new-icon")
	cat.Color = nil
	cat.UpdatedAt = time.Now().UTC().Format(time.RFC3339Nano)
	err := repo.Update(ctx, cat)
	require.NoError(t, err)

	found, err := repo.FindByID(ctx, cat.ID)
	require.NoError(t, err)
	require.Equal(t, "New Name", found.Name)
	require.Equal(t, "new-icon", *found.Icon)
	require.Nil(t, found.Color)
}

func strPtr(s string) *string {
	return &s
}
