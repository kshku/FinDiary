# FinDiary Phase 2: Core Domain CRUD + Local Database

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement backend CRUD for Family, Category, Transaction entities with PostgreSQL repositories, business logic services, gRPC handlers, plus Flutter local Drift database and data layer.

**Architecture:** Clean layering — proto → domain → repository → service → handler. Backend uses pgx for PostgreSQL. Flutter uses drift for local SQLite. All new endpoints require JWT auth (except public procedures in Phase 1).

**Tech Stack:** Go 1.26, connect-go, pgx/v5, golang-migrate. Flutter 3.x, drift, get_it.

---

### Task 1: Proto Service Definitions for Family, Transaction, Category

**Files:**
- Create: `proto/findiary/v1/family_service.proto`
- Create: `proto/findiary/v1/transaction_service.proto`
- Create: `proto/findiary/v1/category_service.proto`
- Modify: `proto/buf.gen.yaml` (no change needed)
- Generated Go: `backend/internal/api/findiary/v1/` (via buf generate)

- [ ] **Step 1: Create family_service.proto**

```protobuf
syntax = "proto3";

package findiary.v1;

option go_package = "github.com/kshku/findiary/backend/internal/api/findiary/v1";

import "findiary/v1/common.proto";
import "google/protobuf/timestamp.proto";

message CreateFamilyRequest {
  string name = 1;
}

message CreateFamilyResponse {
  Family family = 1;
}

message GetFamilyRequest {
  string id = 1;
}

message GetFamilyResponse {
  Family family = 1;
}

message UpdateFamilyRequest {
  string id = 1;
  string name = 2;
}

message UpdateFamilyResponse {
  Family family = 1;
}

message ListMyFamiliesResponse {
  repeated Family families = 1;
}

message AddMemberRequest {
  string family_id = 1;
  string user_id = 2;
  string role = 3;
}

message AddMemberResponse {
  FamilyMember member = 1;
}

message RemoveMemberRequest {
  string family_id = 1;
  string user_id = 2;
}

message RemoveMemberResponse {}

message InviteMemberRequest {
  string family_id = 1;
  string email = 2;
}

message InviteMemberResponse {
  Invitation invitation = 1;
}

message AcceptInvitationRequest {
  string code = 1;
}

message AcceptInvitationResponse {
  FamilyMember member = 1;
}

message RevokeInvitationRequest {
  string id = 1;
}

message RevokeInvitationResponse {
  Invitation invitation = 1;
}

message ListInvitationsRequest {
  string family_id = 1;
}

message ListInvitationsResponse {
  repeated Invitation invitations = 1;
}

message ListMembersRequest {
  string family_id = 1;
}

message ListMembersResponse {
  repeated FamilyMember members = 1;
}

service FamilyService {
  rpc CreateFamily(CreateFamilyRequest) returns (CreateFamilyResponse);
  rpc GetFamily(GetFamilyRequest) returns (GetFamilyResponse);
  rpc UpdateFamily(UpdateFamilyRequest) returns (UpdateFamilyResponse);
  rpc ListMyFamilies(google.protobuf.Empty) returns (ListMyFamiliesResponse);
  rpc AddMember(AddMemberRequest) returns (AddMemberResponse);
  rpc RemoveMember(RemoveMemberRequest) returns (RemoveMemberResponse);
  rpc InviteMember(InviteMemberRequest) returns (InviteMemberResponse);
  rpc AcceptInvitation(AcceptInvitationRequest) returns (AcceptInvitationResponse);
  rpc RevokeInvitation(RevokeInvitationRequest) returns (RevokeInvitationResponse);
  rpc ListInvitations(ListInvitationsRequest) returns (ListInvitationsResponse);
  rpc ListMembers(ListMembersRequest) returns (ListMembersResponse);
}
```

- [ ] **Step 2: Create transaction_service.proto**

```protobuf
syntax = "proto3";

package findiary.v1;

option go_package = "github.com/kshku/findiary/backend/internal/api/findiary/v1";

import "findiary/v1/common.proto";
import "google/protobuf/timestamp.proto";
import "google/protobuf/empty.proto";

message CreateTransactionRequest {
  optional string family_id = 1;
  string type = 2;
  double amount = 3;
  string currency = 4;
  string category_id = 5;
  optional string description = 6;
  string date = 7;
}

message CreateTransactionResponse {
  Transaction transaction = 1;
}

message GetTransactionRequest {
  string id = 1;
}

message GetTransactionResponse {
  Transaction transaction = 1;
}

message UpdateTransactionRequest {
  string id = 1;
  string type = 2;
  double amount = 3;
  string currency = 4;
  string category_id = 5;
  optional string description = 6;
  string date = 7;
}

message UpdateTransactionResponse {
  Transaction transaction = 1;
}

message DeleteTransactionRequest {
  string id = 1;
}

message DeleteTransactionResponse {}

message ListTransactionsRequest {
  optional string family_id = 1;
  string type = 2;
  string category_id = 3;
  string start_date = 4;
  string end_date = 5;
  int32 page_size = 6;
  int32 page_token = 7;
}

message ListTransactionsResponse {
  repeated Transaction transactions = 1;
  int32 total = 2;
  int32 next_page_token = 3;
}

service TransactionService {
  rpc CreateTransaction(CreateTransactionRequest) returns (CreateTransactionResponse);
  rpc GetTransaction(GetTransactionRequest) returns (GetTransactionResponse);
  rpc UpdateTransaction(UpdateTransactionRequest) returns (UpdateTransactionResponse);
  rpc DeleteTransaction(DeleteTransactionRequest) returns (DeleteTransactionResponse);
  rpc ListTransactions(ListTransactionsRequest) returns (ListTransactionsResponse);
}
```

- [ ] **Step 3: Create category_service.proto**

```protobuf
syntax = "proto3";

package findiary.v1;

option go_package = "github.com/kshku/findiary/backend/internal/api/findiary/v1";

import "findiary/v1/common.proto";
import "google/protobuf/empty.proto";

message CreateCategoryRequest {
  string name = 1;
  string type = 2;
  string scope = 3;
  optional string family_id = 4;
  optional string icon = 5;
  optional string color = 6;
}

message CreateCategoryResponse {
  Category category = 1;
}

message GetCategoryRequest {
  string id = 1;
}

message GetCategoryResponse {
  Category category = 1;
}

message UpdateCategoryRequest {
  string id = 1;
  string name = 2;
  optional string icon = 3;
  optional string color = 4;
}

message UpdateCategoryResponse {
  Category category = 1;
}

message DeleteCategoryRequest {
  string id = 1;
}

message DeleteCategoryResponse {}

message ListCategoriesRequest {
  string scope = 1;
  optional string family_id = 2;
  string type = 3;
}

message ListCategoriesResponse {
  repeated Category categories = 1;
}

service CategoryService {
  rpc CreateCategory(CreateCategoryRequest) returns (CreateCategoryResponse);
  rpc GetCategory(GetCategoryRequest) returns (GetCategoryResponse);
  rpc UpdateCategory(UpdateCategoryRequest) returns (UpdateCategoryResponse);
  rpc DeleteCategory(DeleteCategoryRequest) returns (DeleteCategoryResponse);
  rpc ListCategories(ListCategoriesRequest) returns (ListCategoriesResponse);
}
```

- [ ] **Step 4: Generate Go protobuf code**

```bash
cd proto && buf generate
```

- [ ] **Step 5: Verify compilation**

```bash
cd backend && go build ./...
```

- [ ] **Step 6: Commit**

```bash
git add proto/findiary/v1/family_service.proto proto/findiary/v1/transaction_service.proto proto/findiary/v1/category_service.proto backend/internal/api/
git commit -m "feat(proto): add family, transaction, category service definitions"
```

---

### Task 2: Database Migrations for Transactions, Categories, ChangeLog

**Files:**
- Create: `backend/migrations/000003_create_categories.up.sql`
- Create: `backend/migrations/000003_create_categories.down.sql`
- Create: `backend/migrations/000004_create_transactions.up.sql`
- Create: `backend/migrations/000004_create_transactions.down.sql`
- Create: `backend/migrations/000005_create_change_log.up.sql`
- Create: `backend/migrations/000005_create_change_log.down.sql`
- Create: `backend/migrations/000006_seed_default_categories.up.sql`
- Create: `backend/migrations/000006_seed_default_categories.down.sql`

- [ ] **Step 1: Create categories migration (up)**

```sql
-- backend/migrations/000003_create_categories.up.sql
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

CREATE INDEX idx_categories_scope ON categories(scope);
CREATE INDEX idx_categories_family ON categories(family_id);
```

- [ ] **Step 2: Create categories migration (down)**

```sql
-- backend/migrations/000003_create_categories.down.sql
DROP TABLE IF EXISTS categories;
```

- [ ] **Step 3: Create transactions migration (up)**

```sql
-- backend/migrations/000004_create_transactions.up.sql
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

CREATE INDEX idx_transactions_family ON transactions(family_id);
CREATE INDEX idx_transactions_created_by ON transactions(created_by);
CREATE INDEX idx_transactions_date ON transactions(date);
CREATE INDEX idx_transactions_deleted_at ON transactions(deleted_at);
CREATE INDEX idx_transactions_type ON transactions(type);
```

- [ ] **Step 4: Create transactions migration (down)**

```sql
-- backend/migrations/000004_create_transactions.down.sql
DROP TABLE IF EXISTS transactions;
```

- [ ] **Step 5: Create change_log migration (up)**

```sql
-- backend/migrations/000005_create_change_log.up.sql
CREATE TABLE IF NOT EXISTS change_log (
    id BIGSERIAL PRIMARY KEY,
    family_id UUID REFERENCES families(id),
    changed_by UUID NOT NULL REFERENCES users(id),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('create', 'update', 'delete')),
    snapshot JSONB NOT NULL DEFAULT '{}',
    changed_fields TEXT[],
    server_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    client_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_change_log_family ON change_log(family_id);
CREATE INDEX idx_change_log_entity ON change_log(entity_type, entity_id);
CREATE INDEX idx_change_log_server_timestamp ON change_log(server_timestamp);
```

- [ ] **Step 6: Create change_log migration (down)**

```sql
-- backend/migrations/000005_create_change_log.down.sql
DROP TABLE IF EXISTS change_log;
```

- [ ] **Step 7: Create seed default categories migration (up)**

```sql
-- backend/migrations/000006_seed_default_categories.up.sql
INSERT INTO categories (id, scope, name, type, icon, color) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'system', 'Salary', 'income', 'salary', '#4CAF50'),
  ('a0000000-0000-0000-0000-000000000002', 'system', 'Freelance', 'income', 'freelance', '#8BC34A'),
  ('a0000000-0000-0000-0000-000000000003', 'system', 'Business', 'income', 'business', '#009688'),
  ('a0000000-0000-0000-0000-000000000004', 'system', 'Investment', 'income', 'investment', '#2196F3'),
  ('a0000000-0000-0000-0000-000000000005', 'system', 'Gift', 'income', 'gift', '#E91E63'),
  ('a0000000-0000-0000-0000-000000000006', 'system', 'Refund', 'income', 'refund', '#9C27B0'),
  ('a0000000-0000-0000-0000-000000000007', 'system', 'Other Income', 'income', 'other', '#607D8B'),
  ('b0000000-0000-0000-0000-000000000001', 'system', 'Food & Dining', 'expense', 'food', '#FF5722'),
  ('b0000000-0000-0000-0000-000000000002', 'system', 'Transport', 'expense', 'transport', '#FF9800'),
  ('b0000000-0000-0000-0000-000000000003', 'system', 'Utilities', 'expense', 'utilities', '#FFC107'),
  ('b0000000-0000-0000-0000-000000000004', 'system', 'Rent', 'expense', 'rent', '#795548'),
  ('b0000000-0000-0000-0000-000000000005', 'system', 'Shopping', 'expense', 'shopping', '#F44336'),
  ('b0000000-0000-0000-0000-000000000006', 'system', 'Healthcare', 'expense', 'healthcare', '#00BCD4'),
  ('b0000000-0000-0000-0000-000000000007', 'system', 'Entertainment', 'expense', 'entertainment', '#9C27B0'),
  ('b0000000-0000-0000-0000-000000000008', 'system', 'Education', 'expense', 'education', '#3F51B5'),
  ('b0000000-0000-0000-0000-000000000009', 'system', 'Insurance', 'expense', 'insurance', '#673AB7'),
  ('b0000000-0000-0000-0000-00000000000a', 'system', 'Subscription', 'expense', 'subscription', '#607D8B'),
  ('b0000000-0000-0000-0000-00000000000b', 'system', 'Other Expense', 'expense', 'other', '#9E9E9E')
ON CONFLICT (id) DO NOTHING;
```

- [ ] **Step 8: Create seed down migration**

```sql
-- backend/migrations/000006_seed_default_categories.down.sql
DELETE FROM categories WHERE scope = 'system';
```

- [ ] **Step 9: Commit**

```bash
git add backend/migrations/
git commit -m "feat(db): add categories, transactions, change_log tables and seed default categories"
```

---

### Task 3: Backend Domain Types for Family, Transaction, Category, ChangeLog

**Files:**
- Create: `backend/internal/domain/family.go`
- Create: `backend/internal/domain/transaction.go`
- Create: `backend/internal/domain/category.go`
- Modify: `backend/internal/domain/errors.go`
- Modify: `backend/internal/server/interceptor.go` (add UserID/UserEmail context helpers)

- [ ] **Step 1: Create domain/family.go**

```go
package domain

import "context"

type Family struct {
	ID        string
	Name      string
	OwnerID   string
	CreatedAt string
	UpdatedAt string
}

type FamilyMember struct {
	FamilyID string
	UserID   string
	Role     string
	JoinedAt string
	InvitedBy string
}

type Invitation struct {
	ID        string
	FamilyID  string
	Email     string
	Code      string
	Status    string
	CreatedBy string
	CreatedAt string
	ExpiresAt string
}

type FamilyRepository interface {
	Create(ctx context.Context, family *Family) error
	FindByID(ctx context.Context, id string) (*Family, error)
	Update(ctx context.Context, family *Family) error
	ListByUser(ctx context.Context, userID string) ([]*Family, error)
	AddMember(ctx context.Context, member *FamilyMember) error
	RemoveMember(ctx context.Context, familyID, userID string) error
	ListMembers(ctx context.Context, familyID string) ([]*FamilyMember, error)
	IsMember(ctx context.Context, familyID, userID string) (bool, error)
	CreateInvitation(ctx context.Context, inv *Invitation) error
	FindInvitationByCode(ctx context.Context, code string) (*Invitation, error)
	UpdateInvitation(ctx context.Context, inv *Invitation) error
	ListInvitations(ctx context.Context, familyID string) ([]*Invitation, error)
	ListInvitationsByEmail(ctx context.Context, email string) ([]*Invitation, error)
}

type FamilyService interface {
	Create(ctx context.Context, userID, name string) (*Family, error)
	Get(ctx context.Context, userID, familyID string) (*Family, error)
	Update(ctx context.Context, userID, familyID, name string) (*Family, error)
	ListMy(ctx context.Context, userID string) ([]*Family, error)
	AddMember(ctx context.Context, userID, familyID, targetUserID, role string) (*FamilyMember, error)
	RemoveMember(ctx context.Context, userID, familyID, targetUserID string) error
	Invite(ctx context.Context, userID, familyID, email string) (*Invitation, error)
	AcceptInvitation(ctx context.Context, userID, code string) (*FamilyMember, error)
	RevokeInvitation(ctx context.Context, userID, invitationID string) (*Invitation, error)
	ListInvitations(ctx context.Context, userID, familyID string) ([]*Invitation, error)
	ListMembers(ctx context.Context, userID, familyID string) ([]*FamilyMember, error)
}
```

- [ ] **Step 2: Create domain/transaction.go**

```go
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
```

- [ ] **Step 3: Create domain/category.go**

```go
package domain

import "context"

type Category struct {
	ID        string
	Scope     string
	FamilyID  *string
	CreatedBy *string
	Name      string
	Type      string
	Icon      *string
	Color     *string
	CreatedAt string
	UpdatedAt string
}

type CategoryRepository interface {
	Create(ctx context.Context, cat *Category) error
	FindByID(ctx context.Context, id string) (*Category, error)
	Update(ctx context.Context, cat *Category) error
	Delete(ctx context.Context, id string) error
	List(ctx context.Context, scope string, familyID *string, catType string) ([]*Category, error)
}

type CategoryService interface {
	CreatePersonal(ctx context.Context, userID, name, catType string, icon, color *string) (*Category, error)
	CreateFamily(ctx context.Context, userID, familyID, name, catType string, icon, color *string) (*Category, error)
	Get(ctx context.Context, id string) (*Category, error)
	Update(ctx context.Context, id, name string, icon, color *string) (*Category, error)
	Delete(ctx context.Context, id string) error
	List(ctx context.Context, userID string, scope string, familyID *string, catType string) ([]*Category, error)
}
```

- [ ] **Step 4: Add permission error to domain/errors.go**

Edit `backend/internal/domain/errors.go` — add `ErrForbidden`:

```go
package domain

import "errors"

var (
	ErrNotFound      = errors.New("not found")
	ErrAlreadyExists = errors.New("already exists")
	ErrInvalidInput  = errors.New("invalid input")
	ErrUnauthorized  = errors.New("unauthorized")
	ErrForbidden     = errors.New("forbidden")
)
```

- [ ] **Step 5: Add context helpers to server/interceptor.go**

Add these exports to `backend/internal/server/interceptor.go`:

```go
func UserIDFromContext(ctx context.Context) string {
	if v, ok := ctx.Value(userIDKey).(string); ok {
		return v
	}
	return ""
}

func UserEmailFromContext(ctx context.Context) string {
	if v, ok := ctx.Value(userEmailKey).(string); ok {
		return v
	}
	return ""
}
```

- [ ] **Step 6: Verify compilation**

```bash
cd backend && go build ./...
```

- [ ] **Step 7: Commit**

```bash
git add backend/internal/domain/ backend/internal/server/interceptor.go
git commit -m "feat(domain): add family, transaction, category domain types and context helpers"
```

---

### Task 4: Backend Family Repository

**Files:**
- Create: `backend/internal/repository/family_repo.go`
- Create: `backend/internal/repository/family_repo_test.go`
- Modify: `backend/internal/repository/setup_test.go` (extend schema)

- [ ] **Step 1: Create family_repo.go**

```go
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
		family.ID, family.Name, family.OwnerID, family.CreatedAt, family.UpdatedAt)
	if err != nil {
		return fmt.Errorf("create family: %w", err)
	}
	return nil
}

func (r *FamilyRepo) FindByID(ctx context.Context, id string) (*domain.Family, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT id, name, owner_id, created_at, updated_at FROM families WHERE id = $1`, id)
	return scanFamily(row)
}

func (r *FamilyRepo) Update(ctx context.Context, family *domain.Family) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE families SET name = $1, updated_at = $2 WHERE id = $3`,
		family.Name, family.UpdatedAt, family.ID)
	if err != nil {
		return fmt.Errorf("update family: %w", err)
	}
	return nil
}

func (r *FamilyRepo) ListByUser(ctx context.Context, userID string) ([]*domain.Family, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT f.id, f.name, f.owner_id, f.created_at, f.updated_at
		 FROM families f
		 JOIN family_members fm ON fm.family_id = f.id
		 WHERE fm.user_id = $1
		 ORDER BY f.name`, userID)
	if err != nil {
		return nil, fmt.Errorf("list families: %w", err)
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
	if families == nil {
		families = []*domain.Family{}
	}
	return families, nil
}

func (r *FamilyRepo) AddMember(ctx context.Context, member *domain.FamilyMember) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO family_members (family_id, user_id, role, joined_at, invited_by)
		 VALUES ($1, $2, $3, $4, $5)`,
		member.FamilyID, member.UserID, member.Role, member.JoinedAt, member.InvitedBy)
	if err != nil {
		if strings.Contains(err.Error(), "duplicate key") || strings.Contains(err.Error(), "23505") {
			return fmt.Errorf("%w: user is already a member", domain.ErrAlreadyExists)
		}
		return fmt.Errorf("add member: %w", err)
	}
	return nil
}

func (r *FamilyRepo) RemoveMember(ctx context.Context, familyID, userID string) error {
	_, err := r.pool.Exec(ctx,
		`DELETE FROM family_members WHERE family_id = $1 AND user_id = $2`,
		familyID, userID)
	if err != nil {
		return fmt.Errorf("remove member: %w", err)
	}
	return nil
}

func (r *FamilyRepo) ListMembers(ctx context.Context, familyID string) ([]*domain.FamilyMember, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT family_id, user_id, role, joined_at, invited_by
		 FROM family_members WHERE family_id = $1`, familyID)
	if err != nil {
		return nil, fmt.Errorf("list members: %w", err)
	}
	defer rows.Close()

	var members []*domain.FamilyMember
	for rows.Next() {
		m := &domain.FamilyMember{}
		err := rows.Scan(&m.FamilyID, &m.UserID, &m.Role, &m.JoinedAt, &m.InvitedBy)
		if err != nil {
			return nil, fmt.Errorf("scan member: %w", err)
		}
		members = append(members, m)
	}
	if members == nil {
		members = []*domain.FamilyMember{}
	}
	return members, nil
}

func (r *FamilyRepo) IsMember(ctx context.Context, familyID, userID string) (bool, error) {
	var count int
	err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM family_members WHERE family_id = $1 AND user_id = $2`,
		familyID, userID).Scan(&count)
	if err != nil {
		return false, fmt.Errorf("check member: %w", err)
	}
	return count > 0, nil
}

func (r *FamilyRepo) CreateInvitation(ctx context.Context, inv *domain.Invitation) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO invitations (id, family_id, email, code, status, created_by, created_at, expires_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
		inv.ID, inv.FamilyID, inv.Email, inv.Code, inv.Status, inv.CreatedBy, inv.CreatedAt, inv.ExpiresAt)
	if err != nil {
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
	_, err := r.pool.Exec(ctx,
		`UPDATE invitations SET status = $1 WHERE id = $2`,
		inv.Status, inv.ID)
	if err != nil {
		return fmt.Errorf("update invitation: %w", err)
	}
	return nil
}

func (r *FamilyRepo) ListInvitations(ctx context.Context, familyID string) ([]*domain.Invitation, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, family_id, email, code, status, created_by, created_at, expires_at
		 FROM invitations WHERE family_id = $1 ORDER BY created_at DESC`, familyID)
	if err != nil {
		return nil, fmt.Errorf("list invitations: %w", err)
	}
	defer rows.Close()

	var invs []*domain.Invitation
	for rows.Next() {
		inv, err := scanInvitation(rows)
		if err != nil {
			return nil, err
		}
		invs = append(invs, inv)
	}
	if invs == nil {
		invs = []*domain.Invitation{}
	}
	return invs, nil
}

func (r *FamilyRepo) ListInvitationsByEmail(ctx context.Context, email string) ([]*domain.Invitation, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, family_id, email, code, status, created_by, created_at, expires_at
		 FROM invitations WHERE email = $1 AND status = 'pending' ORDER BY created_at DESC`, email)
	if err != nil {
		return nil, fmt.Errorf("list invitations by email: %w", err)
	}
	defer rows.Close()

	var invs []*domain.Invitation
	for rows.Next() {
		inv, err := scanInvitation(rows)
		if err != nil {
			return nil, err
		}
		invs = append(invs, inv)
	}
	if invs == nil {
		invs = []*domain.Invitation{}
	}
	return invs, nil
}

type scannableFamily interface {
	Scan(dest ...any) error
}

func scanFamily(row scannableFamily) (*domain.Family, error) {
	f := &domain.Family{}
	err := row.Scan(&f.ID, &f.Name, &f.OwnerID, &f.CreatedAt, &f.UpdatedAt)
	if err != nil {
		if strings.Contains(err.Error(), "no rows in result set") {
			return nil, domain.ErrNotFound
		}
		return nil, fmt.Errorf("scan family: %w", err)
	}
	return f, nil
}

func scanInvitation(row scannableFamily) (*domain.Invitation, error) {
	inv := &domain.Invitation{}
	err := row.Scan(&inv.ID, &inv.FamilyID, &inv.Email, &inv.Code, &inv.Status,
		&inv.CreatedBy, &inv.CreatedAt, &inv.ExpiresAt)
	if err != nil {
		if strings.Contains(err.Error(), "no rows in result set") {
			return nil, domain.ErrNotFound
		}
		return nil, fmt.Errorf("scan invitation: %w", err)
	}
	return inv, nil
}
```

- [ ] **Step 2: Extend repository/setup_test.go schema**

Add categories, transactions, change_log, and extended families schema:

```go
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
`
```

- [ ] **Step 3: Create family_repo_test.go**

```go
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

func TestFamilyRepo_CreateAndFind(t *testing.T) {
	db := setupTestDB(t)
	familyRepo := repository.NewFamilyRepo(db)
	userRepo := repository.NewUserRepo(db)

	ctx := context.Background()
	user := createTestUser(ctx, t, userRepo)
	now := time.Now().UTC()

	family := &domain.Family{
		ID:        uuid.New().String(),
		Name:      "Test Family",
		OwnerID:   user.ID,
		CreatedAt: now.Format(time.RFC3339Nano),
		UpdatedAt: now.Format(time.RFC3339Nano),
	}

	err := familyRepo.Create(ctx, family)
	require.NoError(t, err)

	found, err := familyRepo.FindByID(ctx, family.ID)
	require.NoError(t, err)
	require.Equal(t, family.ID, found.ID)
	require.Equal(t, "Test Family", found.Name)
}

func TestFamilyRepo_AddAndListMembers(t *testing.T) {
	db := setupTestDB(t)
	familyRepo := repository.NewFamilyRepo(db)
	userRepo := repository.NewUserRepo(db)

	ctx := context.Background()
	owner := createTestUser(ctx, t, userRepo)
	member := createTestUser(ctx, t, userRepo)
	now := time.Now().UTC()

	family := &domain.Family{
		ID:        uuid.New().String(),
		Name:      "Family",
		OwnerID:   owner.ID,
		CreatedAt: now.Format(time.RFC3339Nano),
		UpdatedAt: now.Format(time.RFC3339Nano),
	}
	require.NoError(t, familyRepo.Create(ctx, family))

	err := familyRepo.AddMember(ctx, &domain.FamilyMember{
		FamilyID: family.ID,
		UserID:   member.ID,
		Role:     "member",
		JoinedAt: now.Format(time.RFC3339Nano),
	})
	require.NoError(t, err)

	members, err := familyRepo.ListMembers(ctx, family.ID)
	require.NoError(t, err)
	require.Len(t, members, 1)
	require.Equal(t, member.ID, members[0].UserID)
}

func createTestUser(ctx context.Context, t *testing.T, userRepo *domain.UserRepository) *domain.User {
	t.Helper()

	fakeRepo := userRepo.(*repository.UserRepo)
	now := time.Now().UTC()
	user := &domain.User{
		ID:           uuid.New().String(),
		Email:        uuid.New().String() + "@test.com",
		PasswordHash: "hash",
		DisplayName:  "Test User",
		CreatedAt:    now,
		UpdatedAt:    now,
	}
	err := fakeRepo.Create(ctx, user)
	require.NoError(t, err)
	return user
}
```

Wait — `createTestUser` can't call `userRepo.(*repository.UserRepo)` if the type is `domain.UserRepository` interface. Let me fix: pass `*repository.UserRepo` directly. Actually, the simpler approach is to inline the user creation in the test.

Simplify the test:

```go
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

func createTestUser(t *testing.T, ctx context.Context, repo *repository.UserRepo) *domain.User {
	t.Helper()
	now := time.Now().UTC()
	user := &domain.User{
		ID:           uuid.New().String(),
		Email:        uuid.New().String() + "@test.com",
		PasswordHash: "hash",
		DisplayName:  "Test User",
		CreatedAt:    now,
		UpdatedAt:    now,
	}
	require.NoError(t, repo.Create(ctx, user))
	return user
}

func TestFamilyRepo_CreateAndFind(t *testing.T) {
	db := setupTestDB(t)
	familyRepo := repository.NewFamilyRepo(db)
	userRepo := repository.NewUserRepo(db)

	ctx := context.Background()
	user := createTestUser(t, ctx, userRepo)
	now := time.Now().UTC()

	family := &domain.Family{
		ID:        uuid.New().String(),
		Name:      "Test Family",
		OwnerID:   user.ID,
		CreatedAt: now.Format(time.RFC3339Nano),
		UpdatedAt: now.Format(time.RFC3339Nano),
	}

	err := familyRepo.Create(ctx, family)
	require.NoError(t, err)

	found, err := familyRepo.FindByID(ctx, family.ID)
	require.NoError(t, err)
	require.Equal(t, family.ID, found.ID)
	require.Equal(t, "Test Family", found.Name)
}

func TestFamilyRepo_AddAndListMembers(t *testing.T) {
	db := setupTestDB(t)
	familyRepo := repository.NewFamilyRepo(db)
	userRepo := repository.NewUserRepo(db)

	ctx := context.Background()
	owner := createTestUser(t, ctx, userRepo)
	member := createTestUser(t, ctx, userRepo)
	now := time.Now().UTC()

	family := &domain.Family{
		ID:        uuid.New().String(),
		Name:      "Family",
		OwnerID:   owner.ID,
		CreatedAt: now.Format(time.RFC3339Nano),
		UpdatedAt: now.Format(time.RFC3339Nano),
	}
	require.NoError(t, familyRepo.Create(ctx, family))

	err := familyRepo.AddMember(ctx, &domain.FamilyMember{
		FamilyID: family.ID,
		UserID:   member.ID,
		Role:     "member",
		JoinedAt: now.Format(time.RFC3339Nano),
	})
	require.NoError(t, err)

	members, err := familyRepo.ListMembers(ctx, family.ID)
	require.NoError(t, err)
	require.Len(t, members, 1)
	require.Equal(t, member.ID, members[0].UserID)

	isMember, err := familyRepo.IsMember(ctx, family.ID, member.ID)
	require.NoError(t, err)
	require.True(t, isMember)
}

func TestFamilyRepo_ListByUser(t *testing.T) {
	db := setupTestDB(t)
	familyRepo := repository.NewFamilyRepo(db)
	userRepo := repository.NewUserRepo(db)

	ctx := context.Background()
	user := createTestUser(t, ctx, userRepo)
	now := time.Now().UTC()

	family := &domain.Family{
		ID:        uuid.New().String(),
		Name:      "My Family",
		OwnerID:   user.ID,
		CreatedAt: now.Format(time.RFC3339Nano),
		UpdatedAt: now.Format(time.RFC3339Nano),
	}
	require.NoError(t, familyRepo.Create(ctx, family))

	// Add owner as member too
	require.NoError(t, familyRepo.AddMember(ctx, &domain.FamilyMember{
		FamilyID: family.ID,
		UserID:   user.ID,
		Role:     "owner",
		JoinedAt: now.Format(time.RFC3339Nano),
	}))

	families, err := familyRepo.ListByUser(ctx, user.ID)
	require.NoError(t, err)
	require.Len(t, families, 1)
	require.Equal(t, "My Family", families[0].Name)
}
```

- [ ] **Step 4: Run tests**

```bash
cd backend && go test ./internal/repository/... -v -count=1 -run TestFamilyRepo
```

- [ ] **Step 5: Commit**

```bash
git add backend/internal/repository/family_repo.go backend/internal/repository/family_repo_test.go backend/internal/repository/setup_test.go
git commit -m "feat(repo): add family repository with tests"
```

---

### Task 5: Backend Category and Transaction Repositories

**Files:**
- Create: `backend/internal/repository/category_repo.go`
- Create: `backend/internal/repository/category_repo_test.go`
- Create: `backend/internal/repository/transaction_repo.go`
- Create: `backend/internal/repository/transaction_repo_test.go`

- [ ] **Step 1: Create category_repo.go**

```go
package repository

import (
	"context"
	"fmt"
	"strings"

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
		cat.ID, cat.Scope, cat.FamilyID, cat.CreatedBy, cat.Name, cat.Type,
		cat.Icon, cat.Color, cat.CreatedAt, cat.UpdatedAt)
	if err != nil {
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
	_, err := r.pool.Exec(ctx,
		`UPDATE categories SET name = $1, icon = $2, color = $3, updated_at = $4 WHERE id = $5`,
		cat.Name, cat.Icon, cat.Color, cat.UpdatedAt, cat.ID)
	if err != nil {
		return fmt.Errorf("update category: %w", err)
	}
	return nil
}

func (r *CategoryRepo) Delete(ctx context.Context, id string) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM categories WHERE id = $1`, id)
	if err != nil {
		return fmt.Errorf("delete category: %w", err)
	}
	return nil
}

func (r *CategoryRepo) List(ctx context.Context, scope string, familyID *string, catType string) ([]*domain.Category, error) {
	query := `SELECT id, scope, family_id, created_by, name, type, icon, color, created_at, updated_at
		 FROM categories WHERE 1=1`
	var args []interface{}
	argIdx := 1

	if scope != "" {
		query += fmt.Sprintf(" AND scope = $%d", argIdx)
		args = append(args, scope)
		argIdx++
	}
	if familyID != nil {
		query += fmt.Sprintf(" AND (family_id = $%d OR scope = 'system')", argIdx)
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

	var cats []*domain.Category
	for rows.Next() {
		cat, err := scanCategory(rows)
		if err != nil {
			return nil, err
		}
		cats = append(cats, cat)
	}
	if cats == nil {
		cats = []*domain.Category{}
	}
	return cats, nil
}

type scannableCategory interface {
	Scan(dest ...any) error
}

func scanCategory(row scannableCategory) (*domain.Category, error) {
	cat := &domain.Category{}
	err := row.Scan(&cat.ID, &cat.Scope, &cat.FamilyID, &cat.CreatedBy,
		&cat.Name, &cat.Type, &cat.Icon, &cat.Color, &cat.CreatedAt, &cat.UpdatedAt)
	if err != nil {
		if strings.Contains(err.Error(), "no rows in result set") {
			return nil, domain.ErrNotFound
		}
		return nil, fmt.Errorf("scan category: %w", err)
	}
	return cat, nil
}
```

- [ ] **Step 2: Create category_repo_test.go**

```go
package repository_test

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/repository"
	"github.com/stretchr/testify/require"
)

func TestCategoryRepo_CreateAndFind(t *testing.T) {
	db := setupTestDB(t)
	catRepo := repository.NewCategoryRepo(db)

	ctx := context.Background()
	cat := &domain.Category{
		ID:   uuid.New().String(),
		Scope: "personal",
		CreatedBy: strPtr(uuid.New().String()),
		Name: "Groceries",
		Type: "expense",
		Icon: strPtr("food"),
		Color: strPtr("#FF5722"),
	}

	err := catRepo.Create(ctx, cat)
	require.NoError(t, err)

	found, err := catRepo.FindByID(ctx, cat.ID)
	require.NoError(t, err)
	require.Equal(t, "Groceries", found.Name)
}

func TestCategoryRepo_List(t *testing.T) {
	db := setupTestDB(t)
	catRepo := repository.NewCategoryRepo(db)

	ctx := context.Background()
	for i, name := range []string{"Food", "Transport", "Shopping"} {
		err := catRepo.Create(ctx, &domain.Category{
			ID:   uuid.New().String(),
			Scope: "system",
			Name: name,
			Type: "expense",
		})
		require.NoError(t, err, "create category %d", i)
	}

	cats, err := catRepo.List(ctx, "system", nil, "")
	require.NoError(t, err)
	require.Len(t, cats, 3)
}

func TestCategoryRepo_NotFound(t *testing.T) {
	db := setupTestDB(t)
	catRepo := repository.NewCategoryRepo(db)

	_, err := catRepo.FindByID(context.Background(), uuid.New().String())
	require.ErrorIs(t, err, domain.ErrNotFound)
}

func strPtr(s string) *string { return &s }
```

- [ ] **Step 3: Create transaction_repo.go**

```go
package repository

import (
	"context"
	"fmt"
	"strings"

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
		tx.ID, tx.FamilyID, tx.CreatedBy, tx.Type, tx.Amount, tx.Currency,
		tx.CategoryID, tx.Description, tx.Date, tx.CreatedAt, tx.UpdatedAt)
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
	_, err := r.pool.Exec(ctx,
		`UPDATE transactions SET type = $1, amount = $2, currency = $3, category_id = $4, description = $5, date = $6, updated_at = $7
		 WHERE id = $8`,
		tx.Type, tx.Amount, tx.Currency, tx.CategoryID, tx.Description, tx.Date, tx.UpdatedAt, tx.ID)
	if err != nil {
		return fmt.Errorf("update transaction: %w", err)
	}
	return nil
}

func (r *TransactionRepo) SoftDelete(ctx context.Context, id string) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE transactions SET deleted_at = NOW(), updated_at = NOW() WHERE id = $1`, id)
	if err != nil {
		return fmt.Errorf("soft delete transaction: %w", err)
	}
	return nil
}

func (r *TransactionRepo) List(ctx context.Context, filter domain.TransactionFilter) ([]*domain.Transaction, int, error) {
	where := " WHERE deleted_at IS NULL"
	var args []interface{}
	argIdx := 1

	if filter.FamilyID != nil {
		where += fmt.Sprintf(" AND family_id = $%d", argIdx)
		args = append(args, *filter.FamilyID)
		argIdx++
	} else {
		where += " AND family_id IS NULL"
	}
	if filter.Type != "" {
		where += fmt.Sprintf(" AND type = $%d", argIdx)
		args = append(args, filter.Type)
		argIdx++
	}
	if filter.CategoryID != "" {
		where += fmt.Sprintf(" AND category_id = $%d", argIdx)
		args = append(args, filter.CategoryID)
		argIdx++
	}
	if filter.StartDate != "" {
		where += fmt.Sprintf(" AND date >= $%d", argIdx)
		args = append(args, filter.StartDate)
		argIdx++
	}
	if filter.EndDate != "" {
		where += fmt.Sprintf(" AND date <= $%d", argIdx)
		args = append(args, filter.EndDate)
		argIdx++
	}

	// Count
	var total int
	countQuery := "SELECT COUNT(*) FROM transactions" + where
	err := r.pool.QueryRow(ctx, countQuery, args...).Scan(&total)
	if err != nil {
		return nil, 0, fmt.Errorf("count transactions: %w", err)
	}

	// Offset/limit
	pageSize := filter.PageSize
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 50
	}
	offset := filter.PageToken * pageSize

	query := `SELECT id, family_id, created_by, type, amount, currency, category_id, description, date, created_at, updated_at, deleted_at
		FROM transactions` + where + ` ORDER BY date DESC, created_at DESC`
	query += fmt.Sprintf(" LIMIT $%d OFFSET $%d", argIdx, argIdx+1)
	args = append(args, pageSize, offset)

	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, fmt.Errorf("list transactions: %w", err)
	}
	defer rows.Close()

	var txs []*domain.Transaction
	for rows.Next() {
		t, err := scanTransaction(rows)
		if err != nil {
			return nil, 0, err
		}
		txs = append(txs, t)
	}
	if txs == nil {
		txs = []*domain.Transaction{}
	}
	return txs, total, nil
}

type scannableTransaction interface {
	Scan(dest ...any) error
}

func scanTransaction(row scannableTransaction) (*domain.Transaction, error) {
	t := &domain.Transaction{}
	err := row.Scan(&t.ID, &t.FamilyID, &t.CreatedBy, &t.Type, &t.Amount, &t.Currency,
		&t.CategoryID, &t.Description, &t.Date, &t.CreatedAt, &t.UpdatedAt, &t.DeletedAt)
	if err != nil {
		if strings.Contains(err.Error(), "no rows in result set") {
			return nil, domain.ErrNotFound
		}
		return nil, fmt.Errorf("scan transaction: %w", err)
	}
	return t, nil
}
```

- [ ] **Step 4: Create transaction_repo_test.go**

```go
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

func TestTransactionRepo_CreateAndFind(t *testing.T) {
	db := setupTestDB(t)
	txRepo := repository.NewTransactionRepo(db)
	catRepo := repository.NewCategoryRepo(db)
	userRepo := repository.NewUserRepo(db)

	ctx := context.Background()
	user := createTestUser(t, ctx, userRepo)
	cat := createTestCategory(t, ctx, catRepo)
	now := time.Now()

	tx := &domain.Transaction{
		ID:         uuid.New().String(),
		CreatedBy:  user.ID,
		Type:       "expense",
		Amount:     100.50,
		Currency:   "INR",
		CategoryID: cat.ID,
		Description: strPtr("Test transaction"),
		Date:       now.Format("2006-01-02"),
	}

	err := txRepo.Create(ctx, tx)
	require.NoError(t, err)

	found, err := txRepo.FindByID(ctx, tx.ID)
	require.NoError(t, err)
	require.Equal(t, tx.ID, found.ID)
	require.Equal(t, 100.50, found.Amount)
}

func TestTransactionRepo_SoftDelete(t *testing.T) {
	db := setupTestDB(t)
	txRepo := repository.NewTransactionRepo(db)
	catRepo := repository.NewCategoryRepo(db)
	userRepo := repository.NewUserRepo(db)

	ctx := context.Background()
	user := createTestUser(t, ctx, userRepo)
	cat := createTestCategory(t, ctx, catRepo)

	tx := &domain.Transaction{
		ID:         uuid.New().String(),
		CreatedBy:  user.ID,
		Type:       "income",
		Amount:     1000,
		Currency:   "INR",
		CategoryID: cat.ID,
		Date:       time.Now().Format("2006-01-02"),
	}
	require.NoError(t, txRepo.Create(ctx, tx))
	require.NoError(t, txRepo.SoftDelete(ctx, tx.ID))

	// Should not be found in list
	txs, total, err := txRepo.List(ctx, domain.TransactionFilter{})
	require.NoError(t, err)
	require.Equal(t, 0, total)
	require.Empty(t, txs)
}

func TestTransactionRepo_ListWithFilter(t *testing.T) {
	db := setupTestDB(t)
	txRepo := repository.NewTransactionRepo(db)
	catRepo := repository.NewCategoryRepo(db)
	userRepo := repository.NewUserRepo(db)

	ctx := context.Background()
	user := createTestUser(t, ctx, userRepo)
	cat1 := createTestCategory(t, ctx, catRepo)
	cat2 := createTestCategory(t, ctx, catRepo)
	cat2.Name = "Transport"
	cat2.Type = "expense"
	cat2.ID = uuid.New().String()
	require.NoError(t, catRepo.Create(ctx, cat2))

	for i := 0; i < 3; i++ {
		require.NoError(t, txRepo.Create(ctx, &domain.Transaction{
			ID:         uuid.New().String(),
			CreatedBy:  user.ID,
			Type:       "expense",
			Amount:     50,
			Currency:   "INR",
			CategoryID: cat1.ID,
			Date:       "2026-07-01",
		}))
	}
	require.NoError(t, txRepo.Create(ctx, &domain.Transaction{
		ID:         uuid.New().String(),
		CreatedBy:  user.ID,
		Type:       "income",
		Amount:     500,
		Currency:   "INR",
		CategoryID: cat2.ID,
		Date:       "2026-07-02",
	}))

	txs, total, err := txRepo.List(ctx, domain.TransactionFilter{Type: "expense"})
	require.NoError(t, err)
	require.Equal(t, 3, total)
	require.Len(t, txs, 3)

	txs, total, err = txRepo.List(ctx, domain.TransactionFilter{Type: "income"})
	require.NoError(t, err)
	require.Equal(t, 1, total)
	require.Len(t, txs, 1)
}

func createTestCategory(t *testing.T, ctx context.Context, catRepo *repository.CategoryRepo) *domain.Category {
	t.Helper()
	cat := &domain.Category{
		ID:    uuid.New().String(),
		Scope: "system",
		Name:  "Test Category",
		Type:  "expense",
	}
	require.NoError(t, catRepo.Create(ctx, cat))
	return cat
}
```

- [ ] **Step 5: Run tests**

```bash
cd backend && go test ./internal/repository/... -v -count=1
```

- [ ] **Step 6: Commit**

```bash
git add backend/internal/repository/category_repo.go backend/internal/repository/category_repo_test.go backend/internal/repository/transaction_repo.go backend/internal/repository/transaction_repo_test.go
git commit -m "feat(repo): add category and transaction repositories with tests"
```

---

### Task 6: Backend Services for Family, Category, Transaction

**Files:**
- Create: `backend/internal/service/family_service.go`
- Create: `backend/internal/service/family_service_test.go`
- Create: `backend/internal/service/category_service.go`
- Create: `backend/internal/service/category_service_test.go`
- Create: `backend/internal/service/transaction_service.go`
- Create: `backend/internal/service/transaction_service_test.go`

- [ ] **Step 1: Create family_service.go**

```go
package service

import (
	"context"
	"fmt"
	"math/rand"
	"time"

	"github.com/google/uuid"
	"github.com/kshku/findiary/backend/internal/domain"
)

type FamilyService struct {
	familyRepo domain.FamilyRepository
	userRepo   domain.UserRepository
}

func NewFamilyService(familyRepo domain.FamilyRepository, userRepo domain.UserRepository) *FamilyService {
	return &FamilyService{familyRepo: familyRepo, userRepo: userRepo}
}

func (s *FamilyService) Create(ctx context.Context, userID, name string) (*domain.Family, error) {
	if name == "" {
		return nil, fmt.Errorf("%w: family name is required", domain.ErrInvalidInput)
	}

	now := time.Now().UTC()
	family := &domain.Family{
		ID:        uuid.New().String(),
		Name:      name,
		OwnerID:   userID,
		CreatedAt: now.Format(time.RFC3339Nano),
		UpdatedAt: now.Format(time.RFC3339Nano),
	}

	if err := s.familyRepo.Create(ctx, family); err != nil {
		return nil, err
	}

	// Add creator as owner member
	err := s.familyRepo.AddMember(ctx, &domain.FamilyMember{
		FamilyID:  family.ID,
		UserID:    userID,
		Role:      "owner",
		JoinedAt:  now.Format(time.RFC3339Nano),
		InvitedBy: userID,
	})
	if err != nil {
		return nil, err
	}

	return family, nil
}

func (s *FamilyService) Get(ctx context.Context, userID, familyID string) (*domain.Family, error) {
	isMember, err := s.familyRepo.IsMember(ctx, familyID, userID)
	if err != nil {
		return nil, err
	}
	if !isMember {
		return nil, fmt.Errorf("%w: not a member of this family", domain.ErrForbidden)
	}
	return s.familyRepo.FindByID(ctx, familyID)
}

func (s *FamilyService) Update(ctx context.Context, userID, familyID, name string) (*domain.Family, error) {
	family, err := s.familyRepo.FindByID(ctx, familyID)
	if err != nil {
		return nil, err
	}
	if family.OwnerID != userID {
		return nil, fmt.Errorf("%w: only the owner can update the family", domain.ErrForbidden)
	}
	if name == "" {
		return nil, fmt.Errorf("%w: family name is required", domain.ErrInvalidInput)
	}

	family.Name = name
	family.UpdatedAt = time.Now().UTC().Format(time.RFC3339Nano)
	if err := s.familyRepo.Update(ctx, family); err != nil {
		return nil, err
	}
	return family, nil
}

func (s *FamilyService) ListMy(ctx context.Context, userID string) ([]*domain.Family, error) {
	return s.familyRepo.ListByUser(ctx, userID)
}

func (s *FamilyService) AddMember(ctx context.Context, userID, familyID, targetUserID, role string) (*domain.FamilyMember, error) {
	// Verify requester is admin or owner
	members, err := s.familyRepo.ListMembers(ctx, familyID)
	if err != nil {
		return nil, err
	}
	requester := findMember(members, userID)
	if requester == nil || (requester.Role != "owner" && requester.Role != "admin") {
		return nil, fmt.Errorf("%w: only owner or admin can add members", domain.ErrForbidden)
	}
	if role == "" {
		role = "member"
	}

	member := &domain.FamilyMember{
		FamilyID:  familyID,
		UserID:    targetUserID,
		Role:      role,
		JoinedAt:  time.Now().UTC().Format(time.RFC3339Nano),
		InvitedBy: userID,
	}
	if err := s.familyRepo.AddMember(ctx, member); err != nil {
		return nil, err
	}
	return member, nil
}

func (s *FamilyService) RemoveMember(ctx context.Context, userID, familyID, targetUserID string) error {
	family, err := s.familyRepo.FindByID(ctx, familyID)
	if err != nil {
		return err
	}
	if family.OwnerID != userID {
		return fmt.Errorf("%w: only the owner can remove members", domain.ErrForbidden)
	}
	if targetUserID == family.OwnerID {
		return fmt.Errorf("%w: cannot remove the owner", domain.ErrInvalidInput)
	}
	return s.familyRepo.RemoveMember(ctx, familyID, targetUserID)
}

func (s *FamilyService) Invite(ctx context.Context, userID, familyID, email string) (*domain.Invitation, error) {
	if email == "" {
		return nil, fmt.Errorf("%w: email is required", domain.ErrInvalidInput)
	}

	members, err := s.familyRepo.ListMembers(ctx, familyID)
	if err != nil {
		return nil, err
	}
	requester := findMember(members, userID)
	if requester == nil || (requester.Role != "owner" && requester.Role != "admin") {
		return nil, fmt.Errorf("%w: only owner or admin can invite", domain.ErrForbidden)
	}

	now := time.Now().UTC()
	code := generateInviteCode()
	inv := &domain.Invitation{
		ID:        uuid.New().String(),
		FamilyID:  familyID,
		Email:     email,
		Code:      code,
		Status:    "pending",
		CreatedBy: userID,
		CreatedAt: now.Format(time.RFC3339Nano),
		ExpiresAt: now.Add(7 * 24 * time.Hour).Format(time.RFC3339Nano),
	}

	if err := s.familyRepo.CreateInvitation(ctx, inv); err != nil {
		return nil, err
	}
	return inv, nil
}

func (s *FamilyService) AcceptInvitation(ctx context.Context, userID, code string) (*domain.FamilyMember, error) {
	inv, err := s.familyRepo.FindInvitationByCode(ctx, code)
	if err != nil {
		return nil, fmt.Errorf("%w: invalid invitation code", domain.ErrNotFound)
	}

	now := time.Now().UTC()
	if inv.Status != "pending" || inv.ExpiresAt < now.Format(time.RFC3339Nano) {
		inv.Status = "expired"
		_ = s.familyRepo.UpdateInvitation(ctx, inv)
		return nil, fmt.Errorf("%w: invitation has expired", domain.ErrInvalidInput)
	}

	// Verify email matches
	user, err := s.userRepo.FindByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if user.Email != inv.Email {
		return nil, fmt.Errorf("%w: invitation was sent to a different email", domain.ErrForbidden)
	}

	member := &domain.FamilyMember{
		FamilyID:  inv.FamilyID,
		UserID:    userID,
		Role:      "member",
		JoinedAt:  now.Format(time.RFC3339Nano),
		InvitedBy: inv.CreatedBy,
	}
	if err := s.familyRepo.AddMember(ctx, member); err != nil {
		return nil, err
	}

	inv.Status = "accepted"
	_ = s.familyRepo.UpdateInvitation(ctx, inv)

	return member, nil
}

func (s *FamilyService) RevokeInvitation(ctx context.Context, userID, invitationID string) (*domain.Invitation, error) {
	// Find the invitation to get family_id
	inv, err := s.familyRepo.FindInvitationByCode(ctx, invitationID)
	if err != nil {
		// Try finding by ID
		invitations, err := s.familyRepo.ListInvitations(ctx, "")
		if err != nil {
			return nil, fmt.Errorf("%w: invitation not found", domain.ErrNotFound)
		}
		return nil, fmt.Errorf("%w: invitation not found", domain.ErrNotFound)
	}

	members, err := s.familyRepo.ListMembers(ctx, inv.FamilyID)
	if err != nil {
		return nil, err
	}
	requester := findMember(members, userID)
	if requester == nil || (requester.Role != "owner" && requester.Role != "admin") {
		return nil, fmt.Errorf("%w: only owner or admin can revoke invitations", domain.ErrForbidden)
	}

	inv.Status = "revoked"
	if err := s.familyRepo.UpdateInvitation(ctx, inv); err != nil {
		return nil, err
	}
	return inv, nil
}

func (s *FamilyService) ListInvitations(ctx context.Context, userID, familyID string) ([]*domain.Invitation, error) {
	members, err := s.familyRepo.ListMembers(ctx, familyID)
	if err != nil {
		return nil, err
	}
	requester := findMember(members, userID)
	if requester == nil {
		return nil, fmt.Errorf("%w: not a member of this family", domain.ErrForbidden)
	}
	return s.familyRepo.ListInvitations(ctx, familyID)
}

func (s *FamilyService) ListMembers(ctx context.Context, userID, familyID string) ([]*domain.FamilyMember, error) {
	isMember, err := s.familyRepo.IsMember(ctx, familyID, userID)
	if err != nil {
		return nil, err
	}
	if !isMember {
		return nil, fmt.Errorf("%w: not a member of this family", domain.ErrForbidden)
	}
	return s.familyRepo.ListMembers(ctx, familyID)
}

func findMember(members []*domain.FamilyMember, userID string) *domain.FamilyMember {
	for _, m := range members {
		if m.UserID == userID {
			return m
		}
	}
	return nil
}

func generateInviteCode() string {
	const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	b := make([]byte, 8)
	for i := range b {
		b[i] = chars[rand.Intn(len(chars))]
	}
	return string(b)
}
```

- [ ] **Step 2: Create family_service_test.go**

```go
package service_test

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/service"
	"github.com/stretchr/testify/require"
)

type mockFamilyRepo struct {
	families    map[string]*domain.Family
	members     map[string][]*domain.FamilyMember
	invitations map[string]*domain.Invitation
}

func newMockFamilyRepo() *mockFamilyRepo {
	return &mockFamilyRepo{
		families:    make(map[string]*domain.Family),
		members:     make(map[string][]*domain.FamilyMember),
		invitations: make(map[string]*domain.Invitation),
	}
}

func (m *mockFamilyRepo) Create(ctx context.Context, family *domain.Family) error {
	m.families[family.ID] = family
	return nil
}

func (m *mockFamilyRepo) FindByID(ctx context.Context, id string) (*domain.Family, error) {
	f, ok := m.families[id]
	if !ok {
		return nil, domain.ErrNotFound
	}
	return f, nil
}

func (m *mockFamilyRepo) Update(ctx context.Context, family *domain.Family) error {
	m.families[family.ID] = family
	return nil
}

func (m *mockFamilyRepo) ListByUser(ctx context.Context, userID string) ([]*domain.Family, error) {
	var result []*domain.Family
	for _, f := range m.families {
		for _, mem := range m.members[f.ID] {
			if mem.UserID == userID {
				result = append(result, f)
				break
			}
		}
	}
	if result == nil {
		result = []*domain.Family{}
	}
	return result, nil
}

func (m *mockFamilyRepo) AddMember(ctx context.Context, member *domain.FamilyMember) error {
	m.members[member.FamilyID] = append(m.members[member.FamilyID], member)
	return nil
}

func (m *mockFamilyRepo) RemoveMember(ctx context.Context, familyID, userID string) error {
	members := m.members[familyID]
	var filtered []*domain.FamilyMember
	for _, mem := range members {
		if mem.UserID != userID {
			filtered = append(filtered, mem)
		}
	}
	m.members[familyID] = filtered
	return nil
}

func (m *mockFamilyRepo) ListMembers(ctx context.Context, familyID string) ([]*domain.FamilyMember, error) {
	members := m.members[familyID]
	if members == nil {
		return []*domain.FamilyMember{}, nil
	}
	return members, nil
}

func (m *mockFamilyRepo) IsMember(ctx context.Context, familyID, userID string) (bool, error) {
	for _, mem := range m.members[familyID] {
		if mem.UserID == userID {
			return true, nil
		}
	}
	return false, nil
}

func (m *mockFamilyRepo) CreateInvitation(ctx context.Context, inv *domain.Invitation) error {
	m.invitations[inv.ID] = inv
	return nil
}

func (m *mockFamilyRepo) FindInvitationByCode(ctx context.Context, code string) (*domain.Invitation, error) {
	for _, inv := range m.invitations {
		if inv.Code == code {
			return inv, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (m *mockFamilyRepo) UpdateInvitation(ctx context.Context, inv *domain.Invitation) error {
	m.invitations[inv.ID] = inv
	return nil
}

func (m *mockFamilyRepo) ListInvitations(ctx context.Context, familyID string) ([]*domain.Invitation, error) {
	var result []*domain.Invitation
	for _, inv := range m.invitations {
		if inv.FamilyID == familyID {
			result = append(result, inv)
		}
	}
	if result == nil {
		result = []*domain.Invitation{}
	}
	return result, nil
}

func (m *mockFamilyRepo) ListInvitationsByEmail(ctx context.Context, email string) ([]*domain.Invitation, error) {
	var result []*domain.Invitation
	for _, inv := range m.invitations {
		if inv.Email == email {
			result = append(result, inv)
		}
	}
	if result == nil {
		result = []*domain.Invitation{}
	}
	return result, nil
}

func setupFamilyService() *service.FamilyService {
	return service.NewFamilyService(newMockFamilyRepo(), &mockUserRepo{})
}

func TestFamilyService_Create(t *testing.T) {
	svc := setupFamilyService()
	userID := uuid.New().String()

	family, err := svc.Create(context.Background(), userID, "My Family")
	require.NoError(t, err)
	require.NotEmpty(t, family.ID)
	require.Equal(t, "My Family", family.Name)
	require.Equal(t, userID, family.OwnerID)
}

func TestFamilyService_Create_EmptyName(t *testing.T) {
	svc := setupFamilyService()
	_, err := svc.Create(context.Background(), uuid.New().String(), "")
	require.ErrorIs(t, err, domain.ErrInvalidInput)
}

func TestFamilyService_Get_NotMember(t *testing.T) {
	svc := setupFamilyService()
	userID := uuid.New().String()
	family, err := svc.Create(context.Background(), userID, "Fam")
	require.NoError(t, err)

	otherUser := uuid.New().String()
	_, err = svc.Get(context.Background(), otherUser, family.ID)
	require.ErrorIs(t, err, domain.ErrForbidden)
}
```

- [ ] **Step 3: Create category_service.go**

```go
package service

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/kshku/findiary/backend/internal/domain"
)

type CategoryService struct {
	catRepo    domain.CategoryRepository
	familyRepo domain.FamilyRepository
}

func NewCategoryService(catRepo domain.CategoryRepository, familyRepo domain.FamilyRepository) *CategoryService {
	return &CategoryService{catRepo: catRepo, familyRepo: familyRepo}
}

func (s *CategoryService) CreatePersonal(ctx context.Context, userID, name, catType string, icon, color *string) (*domain.Category, error) {
	if name == "" || catType == "" {
		return nil, fmt.Errorf("%w: name and type are required", domain.ErrInvalidInput)
	}
	now := time.Now().UTC().Format(time.RFC3339Nano)
	cat := &domain.Category{
		ID:        uuid.New().String(),
		Scope:     "personal",
		CreatedBy: &userID,
		Name:      name,
		Type:      catType,
		Icon:      icon,
		Color:     color,
		CreatedAt: now,
		UpdatedAt: now,
	}
	if err := s.catRepo.Create(ctx, cat); err != nil {
		return nil, err
	}
	return cat, nil
}

func (s *CategoryService) CreateFamily(ctx context.Context, userID, familyID, name, catType string, icon, color *string) (*domain.Category, error) {
	if name == "" || catType == "" {
		return nil, fmt.Errorf("%w: name and type are required", domain.ErrInvalidInput)
	}
	isMember, err := s.familyRepo.IsMember(ctx, familyID, userID)
	if err != nil {
		return nil, err
	}
	if !isMember {
		return nil, fmt.Errorf("%w: not a member of this family", domain.ErrForbidden)
	}

	now := time.Now().UTC().Format(time.RFC3339Nano)
	cat := &domain.Category{
		ID:        uuid.New().String(),
		Scope:     "family",
		FamilyID:  &familyID,
		CreatedBy: &userID,
		Name:      name,
		Type:      catType,
		Icon:      icon,
		Color:     color,
		CreatedAt: now,
		UpdatedAt: now,
	}
	if err := s.catRepo.Create(ctx, cat); err != nil {
		return nil, err
	}
	return cat, nil
}

func (s *CategoryService) Get(ctx context.Context, id string) (*domain.Category, error) {
	return s.catRepo.FindByID(ctx, id)
}

func (s *CategoryService) Update(ctx context.Context, id, name string, icon, color *string) (*domain.Category, error) {
	cat, err := s.catRepo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if cat.Scope == "system" {
		return nil, fmt.Errorf("%w: system categories cannot be modified", domain.ErrForbidden)
	}
	if name != "" {
		cat.Name = name
	}
	cat.Icon = icon
	cat.Color = color
	cat.UpdatedAt = time.Now().UTC().Format(time.RFC3339Nano)
	if err := s.catRepo.Update(ctx, cat); err != nil {
		return nil, err
	}
	return cat, nil
}

func (s *CategoryService) Delete(ctx context.Context, id string) error {
	cat, err := s.catRepo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if cat.Scope == "system" {
		return fmt.Errorf("%w: system categories cannot be deleted", domain.ErrForbidden)
	}
	return s.catRepo.Delete(ctx, id)
}

func (s *CategoryService) List(ctx context.Context, userID string, scope string, familyID *string, catType string) ([]*domain.Category, error) {
	return s.catRepo.List(ctx, scope, familyID, catType)
}
```

- [ ] **Step 4: Create category_service_test.go**

```go
package service_test

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/service"
	"github.com/stretchr/testify/require"
)

type mockCategoryRepo struct {
	categories map[string]*domain.Category
}

func newMockCategoryRepo() *mockCategoryRepo {
	return &mockCategoryRepo{
		categories: make(map[string]*domain.Category),
	}
}

func (m *mockCategoryRepo) Create(ctx context.Context, cat *domain.Category) error {
	m.categories[cat.ID] = cat
	return nil
}

func (m *mockCategoryRepo) FindByID(ctx context.Context, id string) (*domain.Category, error) {
	cat, ok := m.categories[id]
	if !ok {
		return nil, domain.ErrNotFound
	}
	return cat, nil
}

func (m *mockCategoryRepo) Update(ctx context.Context, cat *domain.Category) error {
	m.categories[cat.ID] = cat
	return nil
}

func (m *mockCategoryRepo) Delete(ctx context.Context, id string) error {
	delete(m.categories, id)
	return nil
}

func (m *mockCategoryRepo) List(ctx context.Context, scope string, familyID *string, catType string) ([]*domain.Category, error) {
	var result []*domain.Category
	for _, cat := range m.categories {
		if scope != "" && cat.Scope != scope {
			continue
		}
		if catType != "" && cat.Type != catType {
			continue
		}
		result = append(result, cat)
	}
	if result == nil {
		result = []*domain.Category{}
	}
	return result, nil
}

func TestCategoryService_CreatePersonal(t *testing.T) {
	svc := service.NewCategoryService(newMockCategoryRepo(), newMockFamilyRepo())
	userID := uuid.New().String()

	cat, err := svc.CreatePersonal(context.Background(), userID, "Groceries", "expense", strPtr("food"), strPtr("#FF5722"))
	require.NoError(t, err)
	require.Equal(t, "Groceries", cat.Name)
	require.Equal(t, "personal", cat.Scope)
}

func TestCategoryService_DeleteSystem(t *testing.T) {
	catRepo := newMockCategoryRepo()
	svc := service.NewCategoryService(catRepo, newMockFamilyRepo())

	systemCat := &domain.Category{
		ID:    uuid.New().String(),
		Scope: "system",
		Name:  "Salary",
		Type:  "income",
	}
	require.NoError(t, catRepo.Create(context.Background(), systemCat))

	err := svc.Delete(context.Background(), systemCat.ID)
	require.ErrorIs(t, err, domain.ErrForbidden)
}
```

- [ ] **Step 5: Create transaction_service.go**

```go
package service

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/kshku/findiary/backend/internal/domain"
)

type TransactionService struct {
	txRepo     domain.TransactionRepository
	catRepo    domain.CategoryRepository
	familyRepo domain.FamilyRepository
}

func NewTransactionService(txRepo domain.TransactionRepository, catRepo domain.CategoryRepository, familyRepo domain.FamilyRepository) *TransactionService {
	return &TransactionService{txRepo: txRepo, catRepo: catRepo, familyRepo: familyRepo}
}

func (s *TransactionService) Create(ctx context.Context, userID string, req domain.CreateTxRequest) (*domain.Transaction, error) {
	if req.Type != "income" && req.Type != "expense" {
		return nil, fmt.Errorf("%w: type must be 'income' or 'expense'", domain.ErrInvalidInput)
	}
	if req.Amount <= 0 {
		return nil, fmt.Errorf("%w: amount must be positive", domain.ErrInvalidInput)
	}
	if req.Date == "" {
		return nil, fmt.Errorf("%w: date is required", domain.ErrInvalidInput)
	}

	// Validate category exists
	if _, err := s.catRepo.FindByID(ctx, req.CategoryID); err != nil {
		return nil, fmt.Errorf("%w: invalid category", domain.ErrInvalidInput)
	}

	// If family transaction, verify membership
	if req.FamilyID != nil {
		isMember, err := s.familyRepo.IsMember(ctx, *req.FamilyID, userID)
		if err != nil {
			return nil, err
		}
		if !isMember {
			return nil, fmt.Errorf("%w: not a member of this family", domain.ErrForbidden)
		}
	}

	currency := req.Currency
	if currency == "" {
		currency = "INR"
	}

	now := time.Now().UTC()
	tx := &domain.Transaction{
		ID:          uuid.New().String(),
		FamilyID:    req.FamilyID,
		CreatedBy:   userID,
		Type:        req.Type,
		Amount:      req.Amount,
		Currency:    currency,
		CategoryID:  req.CategoryID,
		Description: req.Description,
		Date:        req.Date,
		CreatedAt:   now.Format(time.RFC3339Nano),
		UpdatedAt:   now.Format(time.RFC3339Nano),
	}

	if err := s.txRepo.Create(ctx, tx); err != nil {
		return nil, err
	}
	return tx, nil
}

func (s *TransactionService) Get(ctx context.Context, userID, txID string) (*domain.Transaction, error) {
	tx, err := s.txRepo.FindByID(ctx, txID)
	if err != nil {
		return nil, err
	}
	// Verify access
	if err := s.checkAccess(ctx, userID, tx); err != nil {
		return nil, err
	}
	return tx, nil
}

func (s *TransactionService) Update(ctx context.Context, userID, txID string, req domain.UpdateTxRequest) (*domain.Transaction, error) {
	tx, err := s.txRepo.FindByID(ctx, txID)
	if err != nil {
		return nil, err
	}
	if err := s.checkAccess(ctx, userID, tx); err != nil {
		return nil, err
	}
	if tx.CreatedBy != userID {
		// Check if user is family admin/owner
		if tx.FamilyID != nil {
			members, err := s.familyRepo.ListMembers(ctx, *tx.FamilyID)
			if err != nil {
				return nil, err
			}
			m := findMember(members, userID)
			if m == nil || (m.Role != "owner" && m.Role != "admin") {
				return nil, fmt.Errorf("%w: only owner or admin can edit others' transactions", domain.ErrForbidden)
			}
		} else {
			return nil, fmt.Errorf("%w: cannot edit another user's transaction", domain.ErrForbidden)
		}
	}

	tx.Type = req.Type
	tx.Amount = req.Amount
	tx.Currency = req.Currency
	tx.CategoryID = req.CategoryID
	tx.Description = req.Description
	tx.Date = req.Date
	tx.UpdatedAt = time.Now().UTC().Format(time.RFC3339Nano)

	if err := s.txRepo.Update(ctx, tx); err != nil {
		return nil, err
	}
	return tx, nil
}

func (s *TransactionService) Delete(ctx context.Context, userID, txID string) error {
	tx, err := s.txRepo.FindByID(ctx, txID)
	if err != nil {
		return err
	}
	if err := s.checkAccess(ctx, userID, tx); err != nil {
		return err
	}
	return s.txRepo.SoftDelete(ctx, txID)
}

func (s *TransactionService) List(ctx context.Context, userID string, filter domain.TransactionFilter) ([]*domain.Transaction, int, error) {
	// If family filter, verify membership
	if filter.FamilyID != nil {
		isMember, err := s.familyRepo.IsMember(ctx, *filter.FamilyID, userID)
		if err != nil {
			return nil, 0, err
		}
		if !isMember {
			return nil, 0, fmt.Errorf("%w: not a member of this family", domain.ErrForbidden)
		}
	}
	return s.txRepo.List(ctx, filter)
}

func (s *TransactionService) checkAccess(ctx context.Context, userID string, tx *domain.Transaction) error {
	if tx.FamilyID != nil {
		isMember, err := s.familyRepo.IsMember(ctx, *tx.FamilyID, userID)
		if err != nil {
			return err
		}
		if !isMember {
			return fmt.Errorf("%w: no access to this transaction", domain.ErrForbidden)
		}
		return nil
	}
	if tx.CreatedBy != userID {
		return fmt.Errorf("%w: no access to this transaction", domain.ErrForbidden)
	}
	return nil
}
```

- [ ] **Step 6: Create transaction_service_test.go**

```go
package service_test

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/service"
	"github.com/stretchr/testify/require"
)

type mockTransactionRepo struct {
	transactions map[string]*domain.Transaction
}

func newMockTransactionRepo() *mockTransactionRepo {
	return &mockTransactionRepo{
		transactions: make(map[string]*domain.Transaction),
	}
}

func (m *mockTransactionRepo) Create(ctx context.Context, tx *domain.Transaction) error {
	m.transactions[tx.ID] = tx
	return nil
}

func (m *mockTransactionRepo) FindByID(ctx context.Context, id string) (*domain.Transaction, error) {
	tx, ok := m.transactions[id]
	if !ok {
		return nil, domain.ErrNotFound
	}
	return tx, nil
}

func (m *mockTransactionRepo) Update(ctx context.Context, tx *domain.Transaction) error {
	m.transactions[tx.ID] = tx
	return nil
}

func (m *mockTransactionRepo) SoftDelete(ctx context.Context, id string) error {
	delete(m.transactions, id)
	return nil
}

func (m *mockTransactionRepo) List(ctx context.Context, filter domain.TransactionFilter) ([]*domain.Transaction, int, error) {
	var result []*domain.Transaction
	for _, tx := range m.transactions {
		if filter.Type != "" && tx.Type != filter.Type {
			continue
		}
		result = append(result, tx)
	}
	if result == nil {
		result = []*domain.Transaction{}
	}
	return result, len(result), nil
}

func TestTransactionService_Create(t *testing.T) {
	catRepo := newMockCategoryRepo()
	txRepo := newMockTransactionRepo()
	svc := service.NewTransactionService(txRepo, catRepo, newMockFamilyRepo())

	userID := uuid.New().String()
	cat := &domain.Category{ID: uuid.New().String(), Name: "Food", Type: "expense"}
	require.NoError(t, catRepo.Create(context.Background(), cat))

	tx, err := svc.Create(context.Background(), userID, domain.CreateTxRequest{
		Type:       "expense",
		Amount:     100,
		Currency:   "INR",
		CategoryID: cat.ID,
		Date:       "2026-07-03",
	})
	require.NoError(t, err)
	require.NotEmpty(t, tx.ID)
	require.Equal(t, 100.0, tx.Amount)
}

func TestTransactionService_Create_InvalidAmount(t *testing.T) {
	svc := service.NewTransactionService(newMockTransactionRepo(), newMockCategoryRepo(), newMockFamilyRepo())
	_, err := svc.Create(context.Background(), uuid.New().String(), domain.CreateTxRequest{
		Type:       "expense",
		Amount:     -50,
		CategoryID: uuid.New().String(),
		Date:       "2026-07-03",
	})
	require.ErrorIs(t, err, domain.ErrInvalidInput)
}
```

- [ ] **Step 7: Run tests**

```bash
cd backend && go test ./internal/service/... -v -count=1
```

- [ ] **Step 8: Commit**

```bash
git add backend/internal/service/
git commit -m "feat(service): add family, category, transaction services with tests"
```

---

### Task 7: Backend gRPC Handlers for Family, Category, Transaction

**Files:**
- Create: `backend/internal/api/family_handler.go`
- Create: `backend/internal/api/category_handler.go`
- Create: `backend/internal/api/transaction_handler.go`
- Modify: `backend/internal/server/server.go` (register new handlers)

- [ ] **Step 1: Create family_handler.go**

```go
package api

import (
	"context"
	"errors"

	"github.com/bufbuild/connect-go"
	pb "github.com/kshku/findiary/backend/internal/api/findiary/v1"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/server"
	"github.com/kshku/findiary/backend/internal/service"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type FamilyHandler struct {
	svc *service.FamilyService
}

func NewFamilyHandler(svc *service.FamilyService) *FamilyHandler {
	return &FamilyHandler{svc: svc}
}

func (h *FamilyHandler) CreateFamily(ctx context.Context, req *connect.Request[pb.CreateFamilyRequest]) (*connect.Response[pb.CreateFamilyResponse], error) {
	userID := server.UserIDFromContext(ctx)
	family, err := h.svc.Create(ctx, userID, req.Msg.Name)
	if err != nil {
		return nil, asFamilyConnectError(err)
	}
	return connect.NewResponse(&pb.CreateFamilyResponse{
		Family: domainFamilyToProto(family),
	}), nil
}

func (h *FamilyHandler) GetFamily(ctx context.Context, req *connect.Request[pb.GetFamilyRequest]) (*connect.Response[pb.GetFamilyResponse], error) {
	userID := server.UserIDFromContext(ctx)
	family, err := h.svc.Get(ctx, userID, req.Msg.Id)
	if err != nil {
		return nil, asFamilyConnectError(err)
	}
	return connect.NewResponse(&pb.GetFamilyResponse{
		Family: domainFamilyToProto(family),
	}), nil
}

func (h *FamilyHandler) UpdateFamily(ctx context.Context, req *connect.Request[pb.UpdateFamilyRequest]) (*connect.Response[pb.UpdateFamilyResponse], error) {
	userID := server.UserIDFromContext(ctx)
	family, err := h.svc.Update(ctx, userID, req.Msg.Id, req.Msg.Name)
	if err != nil {
		return nil, asFamilyConnectError(err)
	}
	return connect.NewResponse(&pb.UpdateFamilyResponse{
		Family: domainFamilyToProto(family),
	}), nil
}

func (h *FamilyHandler) ListMyFamilies(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[pb.ListMyFamiliesResponse], error) {
	userID := server.UserIDFromContext(ctx)
	families, err := h.svc.ListMy(ctx, userID)
	if err != nil {
		return nil, asFamilyConnectError(err)
	}
	pbFamilies := make([]*pb.Family, len(families))
	for i, f := range families {
		pbFamilies[i] = domainFamilyToProto(f)
	}
	return connect.NewResponse(&pb.ListMyFamiliesResponse{Families: pbFamilies}), nil
}

func (h *FamilyHandler) AddMember(ctx context.Context, req *connect.Request[pb.AddMemberRequest]) (*connect.Response[pb.AddMemberResponse], error) {
	userID := server.UserIDFromContext(ctx)
	member, err := h.svc.AddMember(ctx, userID, req.Msg.FamilyId, req.Msg.UserId, req.Msg.Role)
	if err != nil {
		return nil, asFamilyConnectError(err)
	}
	return connect.NewResponse(&pb.AddMemberResponse{
		Member: domainMemberToProto(member),
	}), nil
}

func (h *FamilyHandler) RemoveMember(ctx context.Context, req *connect.Request[pb.RemoveMemberRequest]) (*connect.Response[pb.RemoveMemberResponse], error) {
	userID := server.UserIDFromContext(ctx)
	err := h.svc.RemoveMember(ctx, userID, req.Msg.FamilyId, req.Msg.UserId)
	if err != nil {
		return nil, asFamilyConnectError(err)
	}
	return connect.NewResponse(&pb.RemoveMemberResponse{}), nil
}

func (h *FamilyHandler) InviteMember(ctx context.Context, req *connect.Request[pb.InviteMemberRequest]) (*connect.Response[pb.InviteMemberResponse], error) {
	userID := server.UserIDFromContext(ctx)
	inv, err := h.svc.Invite(ctx, userID, req.Msg.FamilyId, req.Msg.Email)
	if err != nil {
		return nil, asFamilyConnectError(err)
	}
	return connect.NewResponse(&pb.InviteMemberResponse{
		Invitation: domainInvitationToProto(inv),
	}), nil
}

func (h *FamilyHandler) AcceptInvitation(ctx context.Context, req *connect.Request[pb.AcceptInvitationRequest]) (*connect.Response[pb.AcceptInvitationResponse], error) {
	userID := server.UserIDFromContext(ctx)
	member, err := h.svc.AcceptInvitation(ctx, userID, req.Msg.Code)
	if err != nil {
		return nil, asFamilyConnectError(err)
	}
	return connect.NewResponse(&pb.AcceptInvitationResponse{
		Member: domainMemberToProto(member),
	}), nil
}

func (h *FamilyHandler) RevokeInvitation(ctx context.Context, req *connect.Request[pb.RevokeInvitationRequest]) (*connect.Response[pb.RevokeInvitationResponse], error) {
	userID := server.UserIDFromContext(ctx)
	inv, err := h.svc.RevokeInvitation(ctx, userID, req.Msg.Id)
	if err != nil {
		return nil, asFamilyConnectError(err)
	}
	return connect.NewResponse(&pb.RevokeInvitationResponse{
		Invitation: domainInvitationToProto(inv),
	}), nil
}

func (h *FamilyHandler) ListInvitations(ctx context.Context, req *connect.Request[pb.ListInvitationsRequest]) (*connect.Response[pb.ListInvitationsResponse], error) {
	userID := server.UserIDFromContext(ctx)
	invs, err := h.svc.ListInvitations(ctx, userID, req.Msg.FamilyId)
	if err != nil {
		return nil, asFamilyConnectError(err)
	}
	pbInvs := make([]*pb.Invitation, len(invs))
	for i, inv := range invs {
		pbInvs[i] = domainInvitationToProto(inv)
	}
	return connect.NewResponse(&pb.ListInvitationsResponse{Invitations: pbInvs}), nil
}

func (h *FamilyHandler) ListMembers(ctx context.Context, req *connect.Request[pb.ListMembersRequest]) (*connect.Response[pb.ListMembersResponse], error) {
	userID := server.UserIDFromContext(ctx)
	members, err := h.svc.ListMembers(ctx, userID, req.Msg.FamilyId)
	if err != nil {
		return nil, asFamilyConnectError(err)
	}
	pbMembers := make([]*pb.FamilyMember, len(members))
	for i, m := range members {
		pbMembers[i] = domainMemberToProto(m)
	}
	return connect.NewResponse(&pb.ListMembersResponse{Members: pbMembers}), nil
}

func domainFamilyToProto(f *domain.Family) *pb.Family {
	return &pb.Family{
		Id:        f.ID,
		Name:      f.Name,
		OwnerId:   f.OwnerID,
		CreatedAt: parseTimeToProto(f.CreatedAt),
		UpdatedAt: parseTimeToProto(f.UpdatedAt),
	}
}

func domainMemberToProto(m *domain.FamilyMember) *pb.FamilyMember {
	return &pb.FamilyMember{
		FamilyId: m.FamilyID,
		UserId:   m.UserID,
		Role:     m.Role,
		JoinedAt: parseTimeToProto(m.JoinedAt),
	}
}

func domainInvitationToProto(inv *domain.Invitation) *pb.Invitation {
	return &pb.Invitation{
		Id:        inv.ID,
		FamilyId:  inv.FamilyID,
		Email:     inv.Email,
		Status:    inv.Status,
		CreatedBy: inv.CreatedBy,
		CreatedAt: parseTimeToProto(inv.CreatedAt),
		ExpiresAt: parseTimeToProto(inv.ExpiresAt),
	}
}

func parseTimeToProto(t string) *timestamppb.Timestamp {
	parsed, err := parseTime(t)
	if err != nil {
		return timestamppb.Now()
	}
	return timestamppb.New(parsed)
}

func parseTime(t string) (parsedTime, error) {
	tm, err := time.Parse(time.RFC3339Nano, t)
	if err != nil {
		return time.Time{}, err
	}
	return tm, nil
}

func asFamilyConnectError(err error) error {
	code := connect.CodeInternal
	switch {
	case errors.Is(err, domain.ErrNotFound):
		code = connect.CodeNotFound
	case errors.Is(err, domain.ErrAlreadyExists):
		code = connect.CodeAlreadyExists
	case errors.Is(err, domain.ErrInvalidInput):
		code = connect.CodeInvalidArgument
	case errors.Is(err, domain.ErrForbidden):
		code = connect.CodePermissionDenied
	case errors.Is(err, domain.ErrUnauthorized):
		code = connect.CodeUnauthenticated
	}
	return connect.NewError(code, err)
}
```

Note: I need to import `time` in this file. Let me fix:

```go
package api

import (
	"context"
	"errors"
	"time"

	"github.com/bufbuild/connect-go"
	pb "github.com/kshku/findiary/backend/internal/api/findiary/v1"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/server"
	"github.com/kshku/findiary/backend/internal/service"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)
```

- [ ] **Step 2: Create category_handler.go**

```go
package api

import (
	"context"
	"errors"

	"github.com/bufbuild/connect-go"
	pb "github.com/kshku/findiary/backend/internal/api/findiary/v1"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/server"
	"github.com/kshku/findiary/backend/internal/service"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type CategoryHandler struct {
	svc *service.CategoryService
}

func NewCategoryHandler(svc *service.CategoryService) *CategoryHandler {
	return &CategoryHandler{svc: svc}
}

func (h *CategoryHandler) CreateCategory(ctx context.Context, req *connect.Request[pb.CreateCategoryRequest]) (*connect.Response[pb.CreateCategoryResponse], error) {
	userID := server.UserIDFromContext(ctx)
	m := req.Msg

	var cat *domain.Category
	var err error
	switch m.Scope {
	case "personal":
		cat, err = h.svc.CreatePersonal(ctx, userID, m.Name, m.Type, m.Icon, m.Color)
	case "family":
		if m.FamilyId == nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, domain.ErrInvalidInput)
		}
		cat, err = h.svc.CreateFamily(ctx, userID, *m.FamilyId, m.Name, m.Type, m.Icon, m.Color)
	default:
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("scope must be 'personal' or 'family'"))
	}
	if err != nil {
		return nil, asCategoryConnectError(err)
	}
	return connect.NewResponse(&pb.CreateCategoryResponse{
		Category: domainCategoryToProto(cat),
	}), nil
}

func (h *CategoryHandler) GetCategory(ctx context.Context, req *connect.Request[pb.GetCategoryRequest]) (*connect.Response[pb.GetCategoryResponse], error) {
	cat, err := h.svc.Get(ctx, req.Msg.Id)
	if err != nil {
		return nil, asCategoryConnectError(err)
	}
	return connect.NewResponse(&pb.GetCategoryResponse{
		Category: domainCategoryToProto(cat),
	}), nil
}

func (h *CategoryHandler) UpdateCategory(ctx context.Context, req *connect.Request[pb.UpdateCategoryRequest]) (*connect.Response[pb.UpdateCategoryResponse], error) {
	cat, err := h.svc.Update(ctx, req.Msg.Id, req.Msg.Name, req.Msg.Icon, req.Msg.Color)
	if err != nil {
		return nil, asCategoryConnectError(err)
	}
	return connect.NewResponse(&pb.UpdateCategoryResponse{
		Category: domainCategoryToProto(cat),
	}), nil
}

func (h *CategoryHandler) DeleteCategory(ctx context.Context, req *connect.Request[pb.DeleteCategoryRequest]) (*connect.Response[pb.DeleteCategoryResponse], error) {
	err := h.svc.Delete(ctx, req.Msg.Id)
	if err != nil {
		return nil, asCategoryConnectError(err)
	}
	return connect.NewResponse(&pb.DeleteCategoryResponse{}), nil
}

func (h *CategoryHandler) ListCategories(ctx context.Context, req *connect.Request[pb.ListCategoriesRequest]) (*connect.Response[pb.ListCategoriesResponse], error) {
	userID := server.UserIDFromContext(ctx)
	m := req.Msg
	cats, err := h.svc.List(ctx, userID, m.Scope, m.FamilyId, m.Type)
	if err != nil {
		return nil, asCategoryConnectError(err)
	}
	pbCats := make([]*pb.Category, len(cats))
	for i, cat := range cats {
		pbCats[i] = domainCategoryToProto(cat)
	}
	return connect.NewResponse(&pb.ListCategoriesResponse{Categories: pbCats}), nil
}

func domainCategoryToProto(cat *domain.Category) *pb.Category {
	return &pb.Category{
		Id:        cat.ID,
		Scope:     cat.Scope,
		FamilyId:  cat.FamilyID,
		CreatedBy: cat.CreatedBy,
		Name:      cat.Name,
		Type:      cat.Type,
		Icon:      cat.Icon,
		Color:     cat.Color,
		CreatedAt: parseTimeToProto(cat.CreatedAt),
		UpdatedAt: parseTimeToProto(cat.UpdatedAt),
	}
}

func asCategoryConnectError(err error) error {
	code := connect.CodeInternal
	switch {
	case errors.Is(err, domain.ErrNotFound):
		code = connect.CodeNotFound
	case errors.Is(err, domain.ErrInvalidInput):
		code = connect.CodeInvalidArgument
	case errors.Is(err, domain.ErrForbidden):
		code = connect.CodePermissionDenied
	}
	return connect.NewError(code, err)
}
```

- [ ] **Step 3: Create transaction_handler.go**

```go
package api

import (
	"context"
	"errors"

	"github.com/bufbuild/connect-go"
	pb "github.com/kshku/findiary/backend/internal/api/findiary/v1"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/server"
	"github.com/kshku/findiary/backend/internal/service"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type TransactionHandler struct {
	svc *service.TransactionService
}

func NewTransactionHandler(svc *service.TransactionService) *TransactionHandler {
	return &TransactionHandler{svc: svc}
}

func (h *TransactionHandler) CreateTransaction(ctx context.Context, req *connect.Request[pb.CreateTransactionRequest]) (*connect.Response[pb.CreateTransactionResponse], error) {
	userID := server.UserIDFromContext(ctx)
	m := req.Msg

	tx, err := h.svc.Create(ctx, userID, domain.CreateTxRequest{
		FamilyID:    m.FamilyId,
		Type:        m.Type,
		Amount:      m.Amount,
		Currency:    m.Currency,
		CategoryID:  m.CategoryId,
		Description: m.Description,
		Date:        m.Date,
	})
	if err != nil {
		return nil, asTxConnectError(err)
	}
	return connect.NewResponse(&pb.CreateTransactionResponse{
		Transaction: domainTransactionToProto(tx),
	}), nil
}

func (h *TransactionHandler) GetTransaction(ctx context.Context, req *connect.Request[pb.GetTransactionRequest]) (*connect.Response[pb.GetTransactionResponse], error) {
	userID := server.UserIDFromContext(ctx)
	tx, err := h.svc.Get(ctx, userID, req.Msg.Id)
	if err != nil {
		return nil, asTxConnectError(err)
	}
	return connect.NewResponse(&pb.GetTransactionResponse{
		Transaction: domainTransactionToProto(tx),
	}), nil
}

func (h *TransactionHandler) UpdateTransaction(ctx context.Context, req *connect.Request[pb.UpdateTransactionRequest]) (*connect.Response[pb.UpdateTransactionResponse], error) {
	userID := server.UserIDFromContext(ctx)
	m := req.Msg

	tx, err := h.svc.Update(ctx, userID, m.Id, domain.UpdateTxRequest{
		Type:        m.Type,
		Amount:      m.Amount,
		Currency:    m.Currency,
		CategoryID:  m.CategoryId,
		Description: m.Description,
		Date:        m.Date,
	})
	if err != nil {
		return nil, asTxConnectError(err)
	}
	return connect.NewResponse(&pb.UpdateTransactionResponse{
		Transaction: domainTransactionToProto(tx),
	}), nil
}

func (h *TransactionHandler) DeleteTransaction(ctx context.Context, req *connect.Request[pb.DeleteTransactionRequest]) (*connect.Response[pb.DeleteTransactionResponse], error) {
	userID := server.UserIDFromContext(ctx)
	err := h.svc.Delete(ctx, userID, req.Msg.Id)
	if err != nil {
		return nil, asTxConnectError(err)
	}
	return connect.NewResponse(&pb.DeleteTransactionResponse{}), nil
}

func (h *TransactionHandler) ListTransactions(ctx context.Context, req *connect.Request[pb.ListTransactionsRequest]) (*connect.Response[pb.ListTransactionsResponse], error) {
	userID := server.UserIDFromContext(ctx)
	m := req.Msg

	filter := domain.TransactionFilter{
		FamilyID:   m.FamilyId,
		Type:       m.Type,
		CategoryID: m.CategoryId,
		StartDate:  m.StartDate,
		EndDate:    m.EndDate,
		PageSize:   int(m.PageSize),
		PageToken:  int(m.PageToken),
	}

	txs, total, err := h.svc.List(ctx, userID, filter)
	if err != nil {
		return nil, asTxConnectError(err)
	}

	pbTxs := make([]*pb.Transaction, len(txs))
	for i, tx := range txs {
		pbTxs[i] = domainTransactionToProto(tx)
	}

	nextToken := int32(filter.PageToken + 1)
	if len(pbTxs) == 0 {
		nextToken = 0
	}

	return connect.NewResponse(&pb.ListTransactionsResponse{
		Transactions:  pbTxs,
		Total:         int32(total),
		NextPageToken: nextToken,
	}), nil
}

func domainTransactionToProto(tx *domain.Transaction) *pb.Transaction {
	pbTx := &pb.Transaction{
		Id:          tx.ID,
		FamilyId:    tx.FamilyID,
		CreatedBy:   tx.CreatedBy,
		Type:        tx.Type,
		Amount:      tx.Amount,
		Currency:    tx.Currency,
		CategoryId:  tx.CategoryID,
		Description: tx.Description,
		Date:        tx.Date,
		CreatedAt:   parseTimeToProto(tx.CreatedAt),
		UpdatedAt:   parseTimeToProto(tx.UpdatedAt),
	}
	if tx.DeletedAt != nil {
		pbTx.DeletedAt = parseTimeToProto(*tx.DeletedAt)
	}
	return pbTx
}

func asTxConnectError(err error) error {
	code := connect.CodeInternal
	switch {
	case errors.Is(err, domain.ErrNotFound):
		code = connect.CodeNotFound
	case errors.Is(err, domain.ErrInvalidInput):
		code = connect.CodeInvalidArgument
	case errors.Is(err, domain.ErrForbidden):
		code = connect.CodePermissionDenied
	}
	return connect.NewError(code, err)
}
```

- [ ] **Step 4: Update server.go to register new handlers**

```go
package server

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"

	"github.com/bufbuild/connect-go"
	"github.com/jackc/pgx/v5/pgxpool"
	pbv1connect "github.com/kshku/findiary/backend/internal/api/findiary/v1/v1connect"
	"github.com/kshku/findiary/backend/internal/api"
	"github.com/kshku/findiary/backend/internal/config"
	"github.com/kshku/findiary/backend/internal/repository"
	"github.com/kshku/findiary/backend/internal/service"
	"github.com/kshku/findiary/backend/pkg/jwt"
)

type Server struct {
	cfg    *config.Config
	logger *slog.Logger
	db     *pgxpool.Pool
	jwtMgr *jwt.Manager
	mux    *http.ServeMux
}

func New(cfg *config.Config, logger *slog.Logger) (*Server, error) {
	db, err := pgxpool.New(context.Background(), cfg.Database.DSN())
	if err != nil {
		return nil, fmt.Errorf("connect to database: %w", err)
	}

	mgr := jwt.NewManager(cfg.JWT.Secret, cfg.JWT.AccessTTL, cfg.JWT.RefreshTTL)

	// Repositories
	userRepo := repository.NewUserRepo(db)
	familyRepo := repository.NewFamilyRepo(db)
	catRepo := repository.NewCategoryRepo(db)
	txRepo := repository.NewTransactionRepo(db)

	// Services
	authSvc := service.NewAuthService(userRepo, mgr)
	familySvc := service.NewFamilyService(familyRepo, userRepo)
	catSvc := service.NewCategoryService(catRepo, familyRepo)
	txSvc := service.NewTransactionService(txRepo, catRepo, familyRepo)

	// Handlers
	authHandler := api.NewAuthHandler(authSvc)
	familyHandler := api.NewFamilyHandler(familySvc)
	catHandler := api.NewCategoryHandler(catSvc)
	txHandler := api.NewTransactionHandler(txSvc)

	mux := http.NewServeMux()
	interceptors := connect.WithInterceptors(LoggingInterceptor(logger), AuthInterceptor(mgr))

	pattern, handler := pbv1connect.NewAuthServiceHandler(authHandler, interceptors)
	mux.Handle(pattern, handler)

	pattern, handler = pbv1connect.NewFamilyServiceHandler(familyHandler, interceptors)
	mux.Handle(pattern, handler)

	pattern, handler = pbv1connect.NewCategoryServiceHandler(catHandler, interceptors)
	mux.Handle(pattern, handler)

	pattern, handler = pbv1connect.NewTransactionServiceHandler(txHandler, interceptors)
	mux.Handle(pattern, handler)

	return &Server{
		cfg:    cfg,
		logger: logger,
		db:     db,
		jwtMgr: mgr,
		mux:    mux,
	}, nil
}

func (s *Server) Start() error {
	addr := s.cfg.Server.Address()
	s.logger.Info("starting server", "address", addr)
	return http.ListenAndServe(addr, s.mux)
}

func (s *Server) Shutdown(ctx context.Context) error {
	s.db.Close()
	return nil
}
```

- [ ] **Step 5: Verify compilation**

```bash
cd backend && go build ./...
```

- [ ] **Step 6: Commit**

```bash
git add backend/internal/api/family_handler.go backend/internal/api/category_handler.go backend/internal/api/transaction_handler.go backend/internal/server/server.go
git commit -m "feat(api): add family, category, transaction gRPC handlers and server wiring"
```

---

### Task 8: Flutter Drift Local Database

**Files:**
- Create: `frontend/lib/core/database/tables.dart`
- Create: `frontend/lib/core/database/database.dart`
- Create: `frontend/lib/core/database/daos/transaction_dao.dart`
- Create: `frontend/lib/core/database/daos/category_dao.dart`
- Create: `frontend/lib/core/database/daos/sync_meta_dao.dart`

- [ ] **Step 1: Create tables.dart**

```dart
import 'package:drift/drift.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get scope => text()();
  TextColumn? get familyId => text().nullable()();
  TextColumn? get createdBy => text().nullable()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn? get icon => text().nullable()();
  TextColumn? get color => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn? get familyId => text().nullable()();
  TextColumn get createdBy => text()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  TextColumn get currency => text()();
  TextColumn get categoryId => text()();
  TextColumn? get description => text().nullable()();
  TextColumn get date => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn? get deletedAt => text().nullable()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))(); // 0=synced, 1=pending, 2=conflict

  @override
  Set<Column> get primaryKey => {id};
}

class Families extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get ownerId => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class FamilyMembers extends Table {
  TextColumn get familyId => text()();
  TextColumn get userId => text()();
  TextColumn get role => text()();
  TextColumn get joinedAt => text()();
  TextColumn? get invitedBy => text().nullable()();

  @override
  Set<Column> get primaryKey => {familyId, userId};
}

class SyncMeta extends Table {
  TextColumn get scopeId => text()();
  TextColumn get scopeType => text()();
  IntColumn get lastCheckpoint => integer().withDefault(const Constant(0))();
  TextColumn get lastSyncedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {scopeId, scopeType};
}

class PendingChanges extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get payload => text()(); // JSON encoded
  TextColumn get createdAt => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}
```

- [ ] **Step 2: Create database.dart**

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Transactions,
    Families,
    FamilyMembers,
    SyncMeta,
    PendingChanges,
  ],
  daos: [],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'findiary.db'));
    return NativeDatabase(file);
  });
}
```

- [ ] **Step 3: Create transaction_dao.dart**

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

class TransactionDao extends DatabaseAccessor<AppDatabase> {
  TransactionDao(super.db);

  Future<void> upsertTransaction(TransactionsCompanion entry) {
    return into(db.transactions).insertOnConflictUpdate(entry);
  }

  Future<Transaction?> getTransaction(String id) {
    return (select(db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<Transaction>> listTransactions({
    String? familyId,
    String? type,
    String? categoryId,
    String? startDate,
    String? endDate,
    int limit = 50,
    int offset = 0,
  }) {
    var query = select(db.transactions)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.date)])
      ..limit(limit, offset: offset);

    if (familyId != null) {
      query.where((t) => t.familyId.equals(familyId));
    } else {
      query.where((t) => t.familyId.isNull());
    }
    if (type != null && type.isNotEmpty) {
      query.where((t) => t.type.equals(type));
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      query.where((t) => t.categoryId.equals(categoryId));
    }
    if (startDate != null && startDate.isNotEmpty) {
      query.where((t) => t.date >= startDate);
    }
    if (endDate != null && endDate.isNotEmpty) {
      query.where((t) => t.date <= endDate);
    }

    return query.get();
  }

  Future<int> countTransactions({String? familyId, String? type}) {
    var query = select(db.transactions)
      ..where((t) => t.deletedAt.isNull());

    if (familyId != null) {
      query.where((t) => t.familyId.equals(familyId));
    } else {
      query.where((t) => t.familyId.isNull());
    }
    if (type != null && type.isNotEmpty) {
      query.where((t) => t.type.equals(type));
    }

    return query.map((_) => null).get().then((rows) => rows.length);
  }

  Future<void> softDeleteTransaction(String id) {
    return (update(db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(deletedAt: Value(DateTime.now().toIso8601String())),
    );
  }

  Future<void> markPendingSync(String id) {
    return (update(db.transactions)..where((t) => t.id.equals(id))).write(
      const TransactionsCompanion(syncStatus: Value(1)),
    );
  }
}
```

- [ ] **Step 4: Create category_dao.dart**

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

class CategoryDao extends DatabaseAccessor<AppDatabase> {
  CategoryDao(super.db);

  Future<void> upsertCategory(CategoriesCompanion entry) {
    return into(db.categories).insertOnConflictUpdate(entry);
  }

  Future<Category?> getCategory(String id) {
    return (select(db.categories)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<List<Category>> listCategories({
    String? scope,
    String? familyId,
    String? type,
  }) {
    var query = select(db.categories)..orderBy([(c) => OrderingTerm.asc(c.name)]);

    if (scope != null && scope.isNotEmpty) {
      query.where((c) => c.scope.equals(scope));
    }
    if (familyId != null && familyId.isNotEmpty) {
      query.where((c) => c.familyId.equals(familyId) | c.scope.equals('system'));
    } else {
      query.where((c) => c.familyId.isNull());
    }
    if (type != null && type.isNotEmpty) {
      query.where((c) => c.type.equals(type));
    }

    return query.get();
  }

  Future<void> deleteCategory(String id) {
    return (delete(db.categories)..where((c) => c.id.equals(id))).go();
  }
}
```

- [ ] **Step 5: Create sync_meta_dao.dart**

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

class SyncMetaDao extends DatabaseAccessor<AppDatabase> {
  SyncMetaDao(super.db);

  Future<SyncMetum?> getMeta(String scopeId, String scopeType) {
    return (select(db.syncMeta)
      ..where((m) => m.scopeId.equals(scopeId) & m.scopeType.equals(scopeType)))
      .getSingleOrNull();
  }

  Future<void> upsertMeta(SyncMetaCompanion entry) {
    return into(db.syncMeta).insertOnConflictUpdate(entry);
  }

  Future<List<SyncMetum>> getAllMeta() {
    return select(db.syncMeta).get();
  }

  Future<void> addPendingChange(PendingChange entry) {
    return into(db.pendingChanges).insert(entry);
  }

  Future<List<PendingChange>> getPendingChanges() {
    return select(db.pendingChanges)
      ..orderBy([(p) => OrderingTerm.asc(p.id)])
      ..get();
  }

  Future<void> removePendingChange(int id) {
    return (delete(db.pendingChanges)..where((p) => p.id.equals(id))).go();
  }
}
```

- [ ] **Step 6: Run build_runner to generate drift code**

```bash
cd frontend && dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 7: Run analyzer**

```bash
cd frontend && flutter analyze --no-fatal-infos
```

- [ ] **Step 8: Commit**

```bash
git add frontend/lib/core/database/
git commit -m "feat(db): add Flutter drift database with tables and DAOs"
```

---

### Task 9: Flutter Core Services (gRPC Clients)

**Files:**
- Create: `frontend/lib/core/family/family_service.dart`
- Create: `frontend/lib/core/category/category_service.dart`
- Create: `frontend/lib/core/transaction/transaction_service.dart`
- Modify: `frontend/lib/core/client/grpc_client.dart` (if needed)

- [ ] **Step 1: Create family_service.dart**

```dart
import 'package:grpc/grpc.dart';
import '../../generated/findiary/v1/family_service.pbgrpc.dart';
import '../../generated/findiary/v1/family_service.pb.dart';
import '../../generated/findiary/v1/common.pb.dart';
import '../client/grpc_client.dart';

class FamilyService {
  final FamilyServiceClient _stub;

  FamilyService(GrpcClient grpcClient)
      : _stub = FamilyServiceClient(grpcClient.channel);

  Future<Family> createFamily(String name) async {
    final request = CreateFamilyRequest()..name = name;
    final response = await _stub.createFamily(request);
    return response.family;
  }

  Future<Family> getFamily(String id) async {
    final request = GetFamilyRequest()..id = id;
    final response = await _stub.getFamily(request);
    return response.family;
  }

  Future<Family> updateFamily(String id, String name) async {
    final request = UpdateFamilyRequest()
      ..id = id
      ..name = name;
    final response = await _stub.updateFamily(request);
    return response.family;
  }

  Future<List<Family>> listMyFamilies() async {
    final response = await _stub.listMyFamilies(Empty());
    return response.families;
  }

  Future<FamilyMember> addMember(String familyId, String userId, String role) async {
    final request = AddMemberRequest()
      ..familyId = familyId
      ..userId = userId
      ..role = role;
    final response = await _stub.addMember(request);
    return response.member;
  }

  Future<Invitation> inviteMember(String familyId, String email) async {
    final request = InviteMemberRequest()
      ..familyId = familyId
      ..email = email;
    final response = await _stub.inviteMember(request);
    return response.invitation;
  }

  Future<FamilyMember> acceptInvitation(String code) async {
    final request = AcceptInvitationRequest()..code = code;
    final response = await _stub.acceptInvitation(request);
    return response.member;
  }

  Future<List<Invitation>> listInvitations(String familyId) async {
    final request = ListInvitationsRequest()..familyId = familyId;
    final response = await _stub.listInvitations(request);
    return response.invitations;
  }

  Future<List<FamilyMember>> listMembers(String familyId) async {
    final request = ListMembersRequest()..familyId = familyId;
    final response = await _stub.listMembers(request);
    return response.members;
  }
}
```

- [ ] **Step 2: Create category_service.dart**

```dart
import '../../generated/findiary/v1/category_service.pbgrpc.dart';
import '../../generated/findiary/v1/category_service.pb.dart';
import '../../generated/findiary/v1/common.pb.dart';
import '../client/grpc_client.dart';

class CategoryService {
  final CategoryServiceClient _stub;

  CategoryService(GrpcClient grpcClient)
      : _stub = CategoryServiceClient(grpcClient.channel);

  Future<Category> createPersonalCategory(String name, String type, {String? icon, String? color}) async {
    final request = CreateCategoryRequest()
      ..name = name
      ..type = type
      ..scope = 'personal'
      ..icon = icon
      ..color = color;
    final response = await _stub.createCategory(request);
    return response.category;
  }

  Future<Category> createFamilyCategory(String familyId, String name, String type, {String? icon, String? color}) async {
    final request = CreateCategoryRequest()
      ..name = name
      ..type = type
      ..scope = 'family'
      ..familyId = familyId
      ..icon = icon
      ..color = color;
    final response = await _stub.createCategory(request);
    return response.category;
  }

  Future<Category> getCategory(String id) async {
    final request = GetCategoryRequest()..id = id;
    final response = await _stub.getCategory(request);
    return response.category;
  }

  Future<List<Category>> listCategories({String? scope, String? familyId, String? type}) async {
    final request = ListCategoriesRequest()
      ..scope = scope ?? ''
      ..type = type ?? ''
      ..familyId = familyId;
    final response = await _stub.listCategories(request);
    return response.categories;
  }

  Future<void> deleteCategory(String id) async {
    final request = DeleteCategoryRequest()..id = id;
    await _stub.deleteCategory(request);
  }
}
```

- [ ] **Step 3: Create transaction_service.dart**

```dart
import '../../generated/findiary/v1/transaction_service.pbgrpc.dart';
import '../../generated/findiary/v1/transaction_service.pb.dart';
import '../../generated/findiary/v1/common.pb.dart';
import '../client/grpc_client.dart';

class TransactionService {
  final TransactionServiceClient _stub;

  TransactionService(GrpcClient grpcClient)
      : _stub = TransactionServiceClient(grpcClient.channel);

  Future<Transaction> createTransaction({
    String? familyId,
    required String type,
    required double amount,
    String currency = 'INR',
    required String categoryId,
    String? description,
    required String date,
  }) async {
    final request = CreateTransactionRequest()
      ..type = type
      ..amount = amount
      ..currency = currency
      ..categoryId = categoryId
      ..description = description
      ..date = date;
    if (familyId != null) {
      request.familyId = familyId;
    }
    final response = await _stub.createTransaction(request);
    return response.transaction;
  }

  Future<Transaction> getTransaction(String id) async {
    final request = GetTransactionRequest()..id = id;
    final response = await _stub.getTransaction(request);
    return response.transaction;
  }

  Future<Transaction> updateTransaction({
    required String id,
    required String type,
    required double amount,
    String currency = 'INR',
    required String categoryId,
    String? description,
    required String date,
  }) async {
    final request = UpdateTransactionRequest()
      ..id = id
      ..type = type
      ..amount = amount
      ..currency = currency
      ..categoryId = categoryId
      ..description = description
      ..date = date;
    final response = await _stub.updateTransaction(request);
    return response.transaction;
  }

  Future<void> deleteTransaction(String id) async {
    final request = DeleteTransactionRequest()..id = id;
    await _stub.deleteTransaction(request);
  }

  Future<({List<Transaction> transactions, int total, int nextPageToken})> listTransactions({
    String? familyId,
    String? type,
    String? categoryId,
    String? startDate,
    String? endDate,
    int pageSize = 50,
    int pageToken = 0,
  }) async {
    final request = ListTransactionsRequest()
      ..type = type ?? ''
      ..categoryId = categoryId ?? ''
      ..startDate = startDate ?? ''
      ..endDate = endDate ?? ''
      ..pageSize = pageSize
      ..pageToken = pageToken;
    if (familyId != null) {
      request.familyId = familyId;
    }
    final response = await _stub.listTransactions(request);
    return (
      transactions: response.transactions,
      total: response.total,
      nextPageToken: response.nextPageToken,
    );
  }
}
```

- [ ] **Step 4: Build verification**

```bash
cd frontend && flutter analyze --no-fatal-infos
```

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/core/family/ frontend/lib/core/category/ frontend/lib/core/transaction/
git commit -m "feat(core): add Flutter gRPC client services for family, category, transaction"
```

---

### Task 10: Wire Everything Together + PR

**Files:**
- Modify: `.github/workflows/ci.yml` (if it exists — create one)

- [ ] **Step 1: Run full backend test suite**

```bash
cd backend && go test ./... -count=1
```

- [ ] **Step 2: Run full Flutter analysis**

```bash
cd frontend && flutter analyze --no-fatal-infos
```

- [ ] **Step 3: Commit all uncommitted changes**

```bash
git add -A
git commit -m "chore: wire up Phase 2 services and handlers"
```

- [ ] **Step 4: Push and create PR**

```bash
git push origin develop
```

- [ ] **Step 5: Create PR via gh**

```bash
gh pr create --base main --head develop --title "Phase 2: Core Domain CRUD + Local Database" --body "Implements Family, Category, Transaction CRUD on backend and Flutter local Drift database with DAOs."
```
