package domain

import "context"

type Transaction struct {
	ID          string
	FamilyID    *string
	CreatedBy   string
	Type        string
	Amount      float64
	Currency    string
	CategoryID  string
	Description *string
	Date        string
	CreatedAt   string
	UpdatedAt   string
	DeletedAt   *string
}

type TransactionFilter struct {
	FamilyID   *string
	Type       string
	CategoryID string
	StartDate  string
	EndDate    string
	PageSize   int
	PageToken  int
}

type TransactionRepository interface {
	Create(ctx context.Context, tx *Transaction) error
	FindByID(ctx context.Context, id string) (*Transaction, error)
	Update(ctx context.Context, tx *Transaction) error
	SoftDelete(ctx context.Context, id string) error
	List(ctx context.Context, filter TransactionFilter) ([]*Transaction, int, error)
}

type TransactionService interface {
	Create(ctx context.Context, userID string, req CreateTxRequest) (*Transaction, error)
	Get(ctx context.Context, userID, txID string) (*Transaction, error)
	Update(ctx context.Context, userID, txID string, req UpdateTxRequest) (*Transaction, error)
	Delete(ctx context.Context, userID, txID string) error
	List(ctx context.Context, userID string, filter TransactionFilter) ([]*Transaction, int, error)
}

type CreateTxRequest struct {
	FamilyID    *string
	Type        string
	Amount      float64
	Currency    string
	CategoryID  string
	Description *string
	Date        string
}

type UpdateTxRequest struct {
	Type        string
	Amount      float64
	Currency    string
	CategoryID  string
	Description *string
	Date        string
}
