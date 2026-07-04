package repository_test

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/repository"
	"github.com/stretchr/testify/require"
)

func TestTransactionRepo_CreateAndFind(t *testing.T) {
	db := setupTestDB(t)
	repo := repository.NewTransactionRepo(db)
	ctx := context.Background()

	user := createTestUser(t, ctx, db)
	cat := createTestCategory(t, ctx, db)

	now := time.Now().UTC().Truncate(time.Microsecond).Format(time.RFC3339Nano)
	desc := "test transaction"
	tx := &domain.Transaction{
		ID:          uuid.New().String(),
		CreatedBy:   user.ID,
		Type:        "expense",
		Amount:      100.50,
		Currency:    "INR",
		CategoryID:  cat.ID,
		Description: &desc,
		Date:        "2026-07-03",
		CreatedAt:   now,
		UpdatedAt:   now,
	}

	err := repo.Create(ctx, tx)
	require.NoError(t, err)

	found, err := repo.FindByID(ctx, tx.ID)
	require.NoError(t, err)
	require.Equal(t, tx.ID, found.ID)
	require.Equal(t, tx.Type, found.Type)
	require.Equal(t, tx.Amount, found.Amount)
	require.Equal(t, tx.Currency, found.Currency)
	require.Equal(t, tx.CategoryID, found.CategoryID)
	require.Equal(t, *tx.Description, *found.Description)
	require.Equal(t, tx.Date, found.Date)
}

func TestTransactionRepo_NotFound(t *testing.T) {
	db := setupTestDB(t)
	repo := repository.NewTransactionRepo(db)

	_, err := repo.FindByID(context.Background(), uuid.New().String())
	require.ErrorIs(t, err, domain.ErrNotFound)
}

func TestTransactionRepo_SoftDelete(t *testing.T) {
	db := setupTestDB(t)
	repo := repository.NewTransactionRepo(db)
	ctx := context.Background()

	user := createTestUser(t, ctx, db)
	cat := createTestCategory(t, ctx, db)

	now := time.Now().UTC().Truncate(time.Microsecond).Format(time.RFC3339Nano)
	tx := &domain.Transaction{
		ID:         uuid.New().String(),
		CreatedBy:  user.ID,
		Type:       "income",
		Amount:     5000,
		Currency:   "INR",
		CategoryID: cat.ID,
		Date:       "2026-07-03",
		CreatedAt:  now,
		UpdatedAt:  now,
	}
	require.NoError(t, repo.Create(ctx, tx))

	err := repo.SoftDelete(ctx, tx.ID)
	require.NoError(t, err)

	_, err = repo.FindByID(ctx, tx.ID)
	require.ErrorIs(t, err, domain.ErrNotFound)
}

func TestTransactionRepo_ListWithFilters(t *testing.T) {
	db := setupTestDB(t)
	repo := repository.NewTransactionRepo(db)
	ctx := context.Background()

	user := createTestUser(t, ctx, db)
	cat := createTestCategory(t, ctx, db)

	now := time.Now().UTC().Truncate(time.Microsecond).Format(time.RFC3339Nano)

	tx1 := &domain.Transaction{
		ID:         uuid.New().String(),
		CreatedBy:  user.ID,
		Type:       "expense",
		Amount:     100,
		Currency:   "INR",
		CategoryID: cat.ID,
		Date:       "2026-07-01",
		CreatedAt:  now,
		UpdatedAt:  now,
	}
	require.NoError(t, repo.Create(ctx, tx1))

	tx2 := &domain.Transaction{
		ID:         uuid.New().String(),
		CreatedBy:  user.ID,
		Type:       "income",
		Amount:     5000,
		Currency:   "INR",
		CategoryID: cat.ID,
		Date:       "2026-07-02",
		CreatedAt:  now,
		UpdatedAt:  now,
	}
	require.NoError(t, repo.Create(ctx, tx2))

	list, total, err := repo.List(ctx, domain.TransactionFilter{})
	require.NoError(t, err)
	require.Len(t, list, 2)
	require.Equal(t, 2, total)

	list, total, err = repo.List(ctx, domain.TransactionFilter{Type: "income"})
	require.NoError(t, err)
	require.Len(t, list, 1)
	require.Equal(t, 1, total)
	require.Equal(t, float64(5000), list[0].Amount)

	list, total, err = repo.List(ctx, domain.TransactionFilter{
		StartDate: "2026-07-02",
		EndDate:   "2026-07-02",
	})
	require.NoError(t, err)
	require.Len(t, list, 1)
	require.Equal(t, 1, total)

	list, total, err = repo.List(ctx, domain.TransactionFilter{Type: "expense", StartDate: "2099-01-01"})
	require.NoError(t, err)
	require.Len(t, list, 0)
	require.Equal(t, 0, total)
}

func TestTransactionRepo_ListPagination(t *testing.T) {
	db := setupTestDB(t)
	repo := repository.NewTransactionRepo(db)
	ctx := context.Background()

	user := createTestUser(t, ctx, db)
	cat := createTestCategory(t, ctx, db)

	now := time.Now().UTC().Truncate(time.Microsecond).Format(time.RFC3339Nano)

	for i := 0; i < 5; i++ {
		tx := &domain.Transaction{
			ID:         uuid.New().String(),
			CreatedBy:  user.ID,
			Type:       "expense",
			Amount:     float64((i + 1) * 100),
			Currency:   "INR",
			CategoryID: cat.ID,
			Date:       "2026-07-03",
			CreatedAt:  now,
			UpdatedAt:  now,
		}
		require.NoError(t, repo.Create(ctx, tx))
	}

	list, total, err := repo.List(ctx, domain.TransactionFilter{PageSize: 2})
	require.NoError(t, err)
	require.Len(t, list, 2)
	require.Equal(t, 5, total)

	list, total, err = repo.List(ctx, domain.TransactionFilter{PageSize: 2, PageToken: 2})
	require.NoError(t, err)
	require.Len(t, list, 2)
	require.Equal(t, 5, total)

	list, total, err = repo.List(ctx, domain.TransactionFilter{PageSize: 2, PageToken: 4})
	require.NoError(t, err)
	require.Len(t, list, 1)
	require.Equal(t, 5, total)
}

func TestTransactionRepo_SoftDeleteNotFound(t *testing.T) {
	db := setupTestDB(t)
	repo := repository.NewTransactionRepo(db)

	err := repo.SoftDelete(context.Background(), uuid.New().String())
	require.ErrorIs(t, err, domain.ErrNotFound)
}

func createTestCategory(t *testing.T, ctx context.Context, db *pgxpool.Pool) *domain.Category {
	t.Helper()
	catRepo := repository.NewCategoryRepo(db)
	now := time.Now().UTC().Truncate(time.Microsecond).Format(time.RFC3339Nano)
	cat := &domain.Category{
		ID:        uuid.New().String(),
		Scope:     "personal",
		Name:      "Test Category",
		Type:      "expense",
		CreatedAt: now,
		UpdatedAt: now,
	}
	require.NoError(t, catRepo.Create(ctx, cat))
	return cat
}
