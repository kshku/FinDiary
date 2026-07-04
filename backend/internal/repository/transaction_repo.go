package repository

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/kshku/findiary/backend/internal/domain"
)

type TransactionRepo struct {
	pool *pgxpool.Pool
}

func NewTransactionRepo(pool *pgxpool.Pool) *TransactionRepo {
	return &TransactionRepo{pool: pool}
}

func (r *TransactionRepo) Create(ctx context.Context, tx *domain.Transaction) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO transactions (id, family_id, created_by, type, amount, currency, category_id, description, date, created_at, updated_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
		tx.ID, tx.FamilyID, tx.CreatedBy, tx.Type, tx.Amount, tx.Currency, tx.CategoryID,
		tx.Description, tx.Date, tx.CreatedAt, tx.UpdatedAt,
	)
	if err != nil {
		return fmt.Errorf("create transaction: %w", err)
	}
	return nil
}

func (r *TransactionRepo) FindByID(ctx context.Context, id string) (*domain.Transaction, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT id, family_id, created_by, type, amount, currency, category_id, description, date, created_at, updated_at, deleted_at
		 FROM transactions WHERE id = $1`, id)
	return scanTransaction(row)
}

func (r *TransactionRepo) Update(ctx context.Context, tx *domain.Transaction) error {
	ct, err := r.pool.Exec(ctx,
		`UPDATE transactions SET type = $1, amount = $2, currency = $3, category_id = $4, description = $5, date = $6, updated_at = $7
		 WHERE id = $8 AND deleted_at IS NULL`,
		tx.Type, tx.Amount, tx.Currency, tx.CategoryID, tx.Description, tx.Date, tx.UpdatedAt, tx.ID)
	if err != nil {
		return fmt.Errorf("update transaction: %w", err)
	}
	if ct.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

func (r *TransactionRepo) SoftDelete(ctx context.Context, id string) error {
	now := time.Now()
	ct, err := r.pool.Exec(ctx,
		`UPDATE transactions SET deleted_at = $1, updated_at = $2 WHERE id = $3 AND deleted_at IS NULL`,
		now, now, id)
	if err != nil {
		return fmt.Errorf("soft delete transaction: %w", err)
	}
	if ct.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

func (r *TransactionRepo) List(ctx context.Context, filter domain.TransactionFilter) ([]*domain.Transaction, int, error) {
	whereClause := " WHERE deleted_at IS NULL"
	var whereArgs []any
	argIdx := 1

	if filter.FamilyID != nil {
		whereClause += fmt.Sprintf(" AND family_id = $%d", argIdx)
		whereArgs = append(whereArgs, *filter.FamilyID)
		argIdx++
	}
	if filter.Type != "" {
		whereClause += fmt.Sprintf(" AND type = $%d", argIdx)
		whereArgs = append(whereArgs, filter.Type)
		argIdx++
	}
	if filter.CategoryID != "" {
		whereClause += fmt.Sprintf(" AND category_id = $%d", argIdx)
		whereArgs = append(whereArgs, filter.CategoryID)
		argIdx++
	}
	if filter.StartDate != "" {
		whereClause += fmt.Sprintf(" AND date >= $%d", argIdx)
		whereArgs = append(whereArgs, filter.StartDate)
		argIdx++
	}
	if filter.EndDate != "" {
		whereClause += fmt.Sprintf(" AND date <= $%d", argIdx)
		whereArgs = append(whereArgs, filter.EndDate)
		argIdx++
	}

	countQuery := "SELECT COUNT(*) FROM transactions" + whereClause
	var total int
	err := r.pool.QueryRow(ctx, countQuery, whereArgs...).Scan(&total)
	if err != nil {
		return nil, 0, fmt.Errorf("count transactions: %w", err)
	}

	pageSize := filter.PageSize
	if pageSize <= 0 {
		pageSize = 20
	}
	offset := filter.PageToken
	if offset < 0 {
		offset = 0
	}

	dataQuery := `SELECT id, family_id, created_by, type, amount, currency, category_id, description, date, created_at, updated_at, deleted_at FROM transactions` +
		whereClause + ` ORDER BY date DESC, created_at DESC`
	dataArgs := append(whereArgs, pageSize, offset)
	dataQuery += fmt.Sprintf(" LIMIT $%d OFFSET $%d", argIdx, argIdx+1)

	rows, err := r.pool.Query(ctx, dataQuery, dataArgs...)
	if err != nil {
		return nil, 0, fmt.Errorf("list transactions: %w", err)
	}
	defer rows.Close()

	var transactions []*domain.Transaction
	for rows.Next() {
		t, err := scanTransaction(rows)
		if err != nil {
			return nil, 0, err
		}
		transactions = append(transactions, t)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, fmt.Errorf("list transactions rows: %w", err)
	}
	return transactions, total, nil
}

func scanTransaction(row scannable) (*domain.Transaction, error) {
	var t domain.Transaction
	var amount float64
	var date time.Time
	var createdAt, updatedAt time.Time
	var deletedAt *time.Time
	err := row.Scan(&t.ID, &t.FamilyID, &t.CreatedBy, &t.Type, &amount, &t.Currency, &t.CategoryID,
		&t.Description, &date, &createdAt, &updatedAt, &deletedAt)
	if err != nil {
		if strings.Contains(err.Error(), "no rows in result set") {
			return nil, domain.ErrNotFound
		}
		return nil, fmt.Errorf("scan transaction: %w", err)
	}
	t.Amount = amount
	t.Date = date.Format("2006-01-02")
	t.CreatedAt = createdAt.Format(time.RFC3339Nano)
	t.UpdatedAt = updatedAt.Format(time.RFC3339Nano)
	if deletedAt != nil {
		s := deletedAt.Format(time.RFC3339Nano)
		t.DeletedAt = &s
	}
	return &t, nil
}
