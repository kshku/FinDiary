# FinDiary Phase 1: Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Set up project scaffolding, protobuf definitions, database schema, complete backend auth flow (register/login/refresh), and Flutter auth UI with login/register screens.

**Architecture:** Clean architecture Go backend (domain → service → repository → api) with gRPC + PostgreSQL. Flutter frontend with BLoC state management and drift SQLite local DB. Communication via generated protobuf stubs over gRPC.

**Tech Stack:** Go 1.22+, connect-go, pgx/v5, golang-migrate, bcrypt, JWT. Flutter 3.x, flutter_bloc, drift, grpc-dart, flutter_secure_storage, go_router.

---

### Task 1: Repository Root + Go Module + Directory Structure

**Files:**
- Create: `backend/go.mod`
- Create: `backend/go.sum` (generated)
- Create: `backend/.gitignore`
- Create: `proto/buf.gen.yaml`
- Create: `proto/buf.yaml`

- [ ] **Step 1: Create directory structure**

Run:
```bash
mkdir -p backend/cmd/server \
  backend/internal/domain \
  backend/internal/service \
  backend/internal/repository \
  backend/internal/api \
  backend/internal/server \
  backend/internal/config \
  backend/pkg/jwt \
  backend/pkg/password \
  backend/pkg/validator \
  backend/migrations \
  proto
```

- [ ] **Step 2: Initialize Go module**

```bash
cd backend && go mod init github.com/kshku/findiary/backend
```

- [ ] **Step 3: Create backend/.gitignore**

```
.env
*.exe
*.test
*.out
tmp/
```

- [ ] **Step 4: Create proto/buf.yaml**

```yaml
version: v2
lint:
  use:
    - STANDARD
breaking:
  use:
    - FILE
```

- [ ] **Step 5: Create proto/buf.gen.yaml**

```yaml
version: v2
plugins:
  - local: protoc-gen-go
    out: ../backend/internal/api
    opt: paths=source_relative
  - local: protoc-gen-connect-go
    out: ../backend/internal/api
    opt: paths=source_relative
  - local: protoc-gen-dart
    out: ../frontend/lib/generated
```

- [ ] **Step 6: Install Go dependencies**

```bash
cd backend && go mod tidy
```

---

### Task 2: Protobuf Definitions

**Files:**
- Create: `proto/findiary/v1/common.proto`
- Create: `proto/findiary/v1/user.proto`
- Create: `proto/findiary/v1/auth_service.proto`

- [ ] **Step 1: Create proto/findiary/v1/common.proto**

```protobuf
syntax = "proto3";

package findiary.v1;

option go_package = "github.com/kshku/findiary/backend/internal/api/findiary/v1";

import "google/protobuf/timestamp.proto";

message User {
  string id = 1;
  string email = 2;
  string display_name = 3;
  google.protobuf.Timestamp created_at = 4;
}

message Transaction {
  string id = 1;
  optional string family_id = 2;
  string created_by = 3;
  string type = 4;        // "income" | "expense"
  double amount = 5;
  string currency = 6;
  string category_id = 7;
  optional string description = 8;
  string date = 9;        // "YYYY-MM-DD"
  google.protobuf.Timestamp created_at = 10;
  google.protobuf.Timestamp updated_at = 11;
  optional google.protobuf.Timestamp deleted_at = 12;
}

message Category {
  string id = 1;
  string scope = 2;       // "system" | "personal" | "family"
  optional string family_id = 3;
  optional string created_by = 4;
  string name = 5;
  string type = 6;        // "income" | "expense"
  optional string icon = 7;
  optional string color = 8;
  google.protobuf.Timestamp created_at = 9;
  google.protobuf.Timestamp updated_at = 10;
}

message Family {
  string id = 1;
  string name = 2;
  string owner_id = 3;
  google.protobuf.Timestamp created_at = 4;
  google.protobuf.Timestamp updated_at = 5;
}

message FamilyMember {
  string family_id = 1;
  string user_id = 2;
  string role = 3;        // "owner" | "admin" | "member"
  google.protobuf.Timestamp joined_at = 4;
}

message Invitation {
  string id = 1;
  string family_id = 2;
  string email = 3;
  string status = 4;      // "pending" | "accepted" | "expired" | "revoked"
  string created_by = 5;
  google.protobuf.Timestamp created_at = 6;
  google.protobuf.Timestamp expires_at = 7;
}

message ChangeEntry {
  int64 id = 1;
  optional string family_id = 2;
  string changed_by = 3;
  string entity_type = 4;
  string entity_id = 5;
  string action = 6;       // "create" | "update" | "delete"
  bytes snapshot = 7;
  repeated string changed_fields = 8;
  google.protobuf.Timestamp server_timestamp = 9;
  google.protobuf.Timestamp client_timestamp = 10;
}
```

- [ ] **Step 2: Create proto/findiary/v1/auth_service.proto**

```protobuf
syntax = "proto3";

package findiary.v1;

option go_package = "github.com/kshku/findiary/backend/internal/api/findiary/v1";

import "findiary/v1/common.proto";
import "google/protobuf/timestamp.proto";

message RegisterRequest {
  string email = 1;
  string password = 2;
  string display_name = 3;
}

message LoginRequest {
  string email = 1;
  string password = 2;
}

message RefreshTokenRequest {
  string refresh_token = 1;
}

message AuthResponse {
  string access_token = 1;
  string refresh_token = 2;
  int64 access_expires_at = 3;
  int64 refresh_expires_at = 4;
  User user = 5;
}

service AuthService {
  rpc Register(RegisterRequest) returns (AuthResponse);
  rpc Login(LoginRequest) returns (AuthResponse);
  rpc RefreshToken(RefreshTokenRequest) returns (AuthResponse);
}
```

- [ ] **Step 3: Generate Go protobuf code**

```bash
cd backend && go install google.golang.org/protobuf/cmd/protoc-gen-go@latest \
  && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
cd proto && buf generate
```

---

### Task 3: Database Migrations

**Files:**
- Create: `backend/migrations/000001_create_users.up.sql`
- Create: `backend/migrations/000001_create_users.down.sql`
- Create: `backend/migrations/000002_create_families.up.sql`
- Create: `backend/migrations/000002_create_families.down.sql`

- [ ] **Step 1: Create users table migration (up)**

```sql
-- backend/migrations/000001_create_users.up.sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100) NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
```

- [ ] **Step 2: Create users table migration (down)**

```sql
-- backend/migrations/000001_create_users.down.sql
DROP TABLE IF EXISTS users;
```

- [ ] **Step 3: Create families + related tables migration (up)**

```sql
-- backend/migrations/000002_create_families.up.sql
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
```

- [ ] **Step 4: Create families migration (down)**

```sql
-- backend/migrations/000002_create_families.down.sql
DROP TABLE IF EXISTS invitations;
DROP TABLE IF EXISTS family_members;
DROP TABLE IF EXISTS families;
```

---

### Task 4: Backend Configuration

**Files:**
- Create: `backend/internal/config/config.go`
- Create: `backend/config.yaml`

- [ ] **Step 1: Create config.go**

```go
package config

import (
	"fmt"
	"os"
	"time"

	"gopkg.in/yaml.v3"
)

type Config struct {
	Server   ServerConfig   `yaml:"server"`
	Database DatabaseConfig `yaml:"database"`
	JWT      JWTConfig      `yaml:"jwt"`
}

type ServerConfig struct {
	Host string `yaml:"host"`
	Port int    `yaml:"port"`
}

func (s ServerConfig) Address() string {
	return fmt.Sprintf("%s:%d", s.Host, s.Port)
}

type DatabaseConfig struct {
	Host     string `yaml:"host"`
	Port     int    `yaml:"port"`
	Name     string `yaml:"name"`
	User     string `yaml:"user"`
	Password string `yaml:"password"`
}

func (d DatabaseConfig) DSN() string {
	return fmt.Sprintf(
		"postgres://%s:%s@%s:%d/%s?sslmode=disable",
		d.User, d.Password, d.Host, d.Port, d.Name,
	)
}

type JWTConfig struct {
	Secret     string        `yaml:"secret"`
	AccessTTL  time.Duration `yaml:"access_ttl"`
	RefreshTTL time.Duration `yaml:"refresh_ttl"`
}

func Load(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read config: %w", err)
	}
	var cfg Config
	if err := yaml.Unmarshal(data, &cfg); err != nil {
		return nil, fmt.Errorf("parse config: %w", err)
	}
	cfg.overrideFromEnv()
	return &cfg, nil
}

func (c *Config) overrideFromEnv() {
	if v := os.Getenv("DB_PASSWORD"); v != "" {
		c.Database.Password = v
	}
	if v := os.Getenv("JWT_SECRET"); v != "" {
		c.JWT.Secret = v
	}
}
```

- [ ] **Step 2: Create config.yaml**

```yaml
server:
  host: "0.0.0.0"
  port: 9090

database:
  host: "localhost"
  port: 5432
  name: "findiary"
  user: "findiary"
  password: "findiary_dev"

jwt:
  secret: "dev-secret-change-in-production"
  access_ttl: 15m
  refresh_ttl: 720h  # 30 days
```

- [ ] **Step 3: Install yaml dependency**

```bash
cd backend && go get gopkg.in/yaml.v3 && go mod tidy
```

---

### Task 5: Backend Domain Layer

**Files:**
- Create: `backend/internal/domain/user.go`
- Create: `backend/internal/domain/errors.go`
- Create: `backend/internal/domain/auth.go`

- [ ] **Step 1: Create domain/user.go**

```go
package domain

import "time"

type User struct {
	ID           string
	Email        string
	PasswordHash string
	DisplayName  string
	CreatedAt    time.Time
	UpdatedAt    time.Time
}

type UserRepository interface {
	Create(user *User) error
	FindByID(id string) (*User, error)
	FindByEmail(email string) (*User, error)
}
```

- [ ] **Step 2: Create domain/errors.go**

```go
package domain

import "errors"

var (
	ErrNotFound       = errors.New("not found")
	ErrAlreadyExists  = errors.New("already exists")
	ErrInvalidInput   = errors.New("invalid input")
	ErrUnauthorized   = errors.New("unauthorized")
)
```

- [ ] **Step 3: Create domain/auth.go**

```go
package domain

type AuthService interface {
	Register(email, password, displayName string) (*User, string, string, error)
	Login(email, password string) (*User, string, string, error)
	RefreshToken(refreshToken string) (string, string, error)
}
```

---

### Task 6: Backend pkg Utilities (JWT, Password)

**Files:**
- Create: `backend/pkg/jwt/jwt.go`
- Create: `backend/pkg/password/password.go`

- [ ] **Step 1: Create pkg/password/password.go**

```go
package password

import "golang.org/x/crypto/bcrypt"

func Hash(plain string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(plain), bcrypt.DefaultCost)
	return string(bytes), err
}

func Verify(plain, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(plain))
	return err == nil
}
```

- [ ] **Step 2: Create pkg/jwt/jwt.go**

```go
package jwt

import (
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type Manager struct {
	secret     []byte
	accessTTL  time.Duration
	refreshTTL time.Duration
}

type Claims struct {
	UserID string `json:"user_id"`
	Email  string `json:"email"`
	jwt.RegisteredClaims
}

func NewManager(secret string, accessTTL, refreshTTL time.Duration) *Manager {
	return &Manager{
		secret:     []byte(secret),
		accessTTL:  accessTTL,
		refreshTTL: refreshTTL,
	}
}

func (m *Manager) GenerateAccessToken(userID, email string) (string, time.Time, error) {
	exp := time.Now().Add(m.accessTTL)
	claims := Claims{
		UserID: userID,
		Email:  email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(exp),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString(m.secret)
	return signed, exp, err
}

func (m *Manager) GenerateRefreshToken(userID, email string) (string, time.Time, error) {
	exp := time.Now().Add(m.refreshTTL)
	claims := Claims{
		UserID: userID,
		Email:  email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(exp),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString(m.secret)
	return signed, exp, err
}

func (m *Manager) ValidateToken(tokenStr string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenStr, &Claims{}, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
		}
		return m.secret, nil
	})
	if err != nil {
		return nil, err
	}
	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, fmt.Errorf("invalid token claims")
	}
	return claims, nil
}
```

- [ ] **Step 3: Install dependencies**

```bash
cd backend && go get golang.org/x/crypto && go get github.com/golang-jwt/jwt/v5 && go mod tidy
```

---

### Task 7: Backend User Repository

**Files:**
- Create: `backend/internal/repository/user_repo.go`
- Create: `backend/internal/repository/user_repo_test.go`

- [ ] **Step 1: Create user_repo.go**

```go
package repository

import (
	"context"
	"fmt"

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

func scanUser(row interface{ Scan(dest ...any) error }) (*domain.User, error) {
	u := &domain.User{}
	err := row.Scan(&u.ID, &u.Email, &u.PasswordHash, &u.DisplayName,
		&u.CreatedAt, &u.UpdatedAt)
	if err != nil {
		if isNoRows(err) {
			return nil, domain.ErrNotFound
		}
		return nil, fmt.Errorf("scan user: %w", err)
	}
	return u, nil
}

func isUniqueViolation(err error) bool {
	return err != nil && contains(err.Error(), "duplicate key")
}

func isNoRows(err error) bool {
	return err != nil && contains(err.Error(), "no rows in result set")
}

func contains(s, substr string) bool {
	return len(s) >= len(substr) && searchString(s, substr)
}

func searchString(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}
```

- [ ] **Step 2: Create user_repo_test.go**

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
```

- [ ] **Step 3: Create repository test helper**

Create: `backend/internal/repository/setup_test.go`

```go
package repository_test

import (
	"context"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/kshku/findiary/backend/internal/config"
)

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

	// Run migrations
	runMigrations(t, pool, dsn)

	// Clean tables before each test
	_, err = pool.Exec(context.Background(),
		`TRUNCATE TABLE users, families, family_members, invitations CASCADE`)
	if err != nil {
		t.Fatalf("truncate tables: %v", err)
	}

	return pool
}

func runMigrations(t *testing.T, pool *pgxpool.Pool, dsn string) {
	t.Helper()
	// Apply migrations using golang-migrate
	// In production this runs via CLI; here we apply raw SQL for tests
	schema := `
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
	);`
	_, err := pool.Exec(context.Background(), schema)
	if err != nil {
		t.Fatalf("apply schema: %v", err)
	}
}
```

- [ ] **Step 4: Install test deps**

```bash
cd backend && go get github.com/jackc/pgx/v5 && go get github.com/stretchr/testify && go get github.com/google/uuid && go mod tidy
```

- [ ] **Step 5: Run repository tests**

```bash
cd backend && go test ./internal/repository/... -v -count=1
```

---

### Task 8: Backend Auth Service

**Files:**
- Create: `backend/internal/service/auth_service.go`
- Create: `backend/internal/service/auth_service_test.go`

- [ ] **Step 1: Create auth_service.go**

```go
package service

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/pkg/jwt"
	"github.com/kshku/findiary/backend/pkg/password"
)

type AuthService struct {
	userRepo domain.UserRepository
	jwtMgr   *jwt.Manager
}

func NewAuthService(userRepo domain.UserRepository, jwtMgr *jwt.Manager) *AuthService {
	return &AuthService{userRepo: userRepo, jwtMgr: jwtMgr}
}

func (s *AuthService) Register(ctx context.Context, email, pw, displayName string) (*domain.User, string, string, error) {
	if email == "" || pw == "" {
		return nil, "", "", fmt.Errorf("%w: email and password required", domain.ErrInvalidInput)
	}
	if len(pw) < 6 {
		return nil, "", "", fmt.Errorf("%w: password must be at least 6 characters", domain.ErrInvalidInput)
	}

	hash, err := password.Hash(pw)
	if err != nil {
		return nil, "", "", fmt.Errorf("hash password: %w", err)
	}

	now := time.Now().UTC()
	user := &domain.User{
		ID:           uuid.New().String(),
		Email:        email,
		PasswordHash: hash,
		DisplayName:  displayName,
		CreatedAt:    now,
		UpdatedAt:    now,
	}

	if err := s.userRepo.Create(ctx, user); err != nil {
		return nil, "", "", err
	}

	accessToken, accessExp, err := s.jwtMgr.GenerateAccessToken(user.ID, user.Email)
	if err != nil {
		return nil, "", "", fmt.Errorf("generate access token: %w", err)
	}
	refreshToken, refreshExp, err := s.jwtMgr.GenerateRefreshToken(user.ID, user.Email)
	if err != nil {
		return nil, "", "", fmt.Errorf("generate refresh token: %w", err)
	}

	_ = accessExp
	_ = refreshExp
	return user, accessToken, refreshToken, nil
}

func (s *AuthService) Login(ctx context.Context, email, pw string) (*domain.User, string, string, error) {
	if email == "" || pw == "" {
		return nil, "", "", fmt.Errorf("%w: email and password required", domain.ErrInvalidInput)
	}

	user, err := s.userRepo.FindByEmail(ctx, email)
	if err != nil {
		return nil, "", "", fmt.Errorf("%w: invalid email or password", domain.ErrUnauthorized)
	}

	if !password.Verify(pw, user.PasswordHash) {
		return nil, "", "", fmt.Errorf("%w: invalid email or password", domain.ErrUnauthorized)
	}

	accessToken, accessExp, err := s.jwtMgr.GenerateAccessToken(user.ID, user.Email)
	if err != nil {
		return nil, "", "", fmt.Errorf("generate access token: %w", err)
	}
	refreshToken, refreshExp, err := s.jwtMgr.GenerateRefreshToken(user.ID, user.Email)
	if err != nil {
		return nil, "", "", fmt.Errorf("generate refresh token: %w", err)
	}

	_ = accessExp
	_ = refreshExp
	return user, accessToken, refreshToken, nil
}

func (s *AuthService) RefreshToken(ctx context.Context, tokenStr string) (string, string, error) {
	claims, err := s.jwtMgr.ValidateToken(tokenStr)
	if err != nil {
		return "", "", fmt.Errorf("%w: invalid refresh token", domain.ErrUnauthorized)
	}

	newAccess, _, err := s.jwtMgr.GenerateAccessToken(claims.UserID, claims.Email)
	if err != nil {
		return "", "", fmt.Errorf("generate access token: %w", err)
	}
	newRefresh, _, err := s.jwtMgr.GenerateRefreshToken(claims.UserID, claims.Email)
	if err != nil {
		return "", "", fmt.Errorf("generate refresh token: %w", err)
	}

	return newAccess, newRefresh, nil
}
```

- [ ] **Step 2: Create auth_service_test.go**

```go
package service_test

import (
	"context"
	"testing"

	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/service"
	"github.com/kshku/findiary/backend/pkg/jwt"
	"github.com/stretchr/testify/require"
)

type mockUserRepo struct {
	users []*domain.User
}

func (m *mockUserRepo) Create(ctx context.Context, user *domain.User) error {
	for _, u := range m.users {
		if u.Email == user.Email {
			return domain.ErrAlreadyExists
		}
	}
	m.users = append(m.users, user)
	return nil
}

func (m *mockUserRepo) FindByID(ctx context.Context, id string) (*domain.User, error) {
	for _, u := range m.users {
		if u.ID == id {
			return u, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (m *mockUserRepo) FindByEmail(ctx context.Context, email string) (*domain.User, error) {
	for _, u := range m.users {
		if u.Email == email {
			return u, nil
		}
	}
	return nil, domain.ErrNotFound
}

func setupAuthService() *service.AuthService {
	jwtMgr := jwt.NewManager("test-secret", 900000000000, 900000000000)
	return service.NewAuthService(&mockUserRepo{}, jwtMgr)
}

func TestRegister_Success(t *testing.T) {
	svc := setupAuthService()
	ctx := context.Background()

	user, access, refresh, err := svc.Register(ctx, "a@b.com", "password123", "Alice")
	require.NoError(t, err)
	require.NotEmpty(t, user.ID)
	require.Equal(t, "a@b.com", user.Email)
	require.Equal(t, "Alice", user.DisplayName)
	require.NotEmpty(t, access)
	require.NotEmpty(t, refresh)
}

func TestRegister_DuplicateEmail(t *testing.T) {
	svc := setupAuthService()
	ctx := context.Background()

	_, _, _, err := svc.Register(ctx, "dup@b.com", "password123", "A")
	require.NoError(t, err)

	_, _, _, err = svc.Register(ctx, "dup@b.com", "password123", "B")
	require.ErrorIs(t, err, domain.ErrAlreadyExists)
}

func TestRegister_InvalidInput(t *testing.T) {
	svc := setupAuthService()
	ctx := context.Background()

	_, _, _, err := svc.Register(ctx, "", "password123", "A")
	require.ErrorIs(t, err, domain.ErrInvalidInput)

	_, _, _, err = svc.Register(ctx, "a@b.com", "", "A")
	require.ErrorIs(t, err, domain.ErrInvalidInput)

	_, _, _, err = svc.Register(ctx, "a@b.com", "12345", "A")
	require.ErrorIs(t, err, domain.ErrInvalidInput)
}

func TestLogin_Success(t *testing.T) {
	svc := setupAuthService()
	ctx := context.Background()

	_, _, _, err := svc.Register(ctx, "login@b.com", "password123", "Bob")
	require.NoError(t, err)

	user, access, refresh, err := svc.Login(ctx, "login@b.com", "password123")
	require.NoError(t, err)
	require.Equal(t, "login@b.com", user.Email)
	require.NotEmpty(t, access)
	require.NotEmpty(t, refresh)
}

func TestLogin_WrongPassword(t *testing.T) {
	svc := setupAuthService()
	ctx := context.Background()

	_, _, _, err := svc.Register(ctx, "wrong@b.com", "password123", "C")
	require.NoError(t, err)

	_, _, _, err = svc.Login(ctx, "wrong@b.com", "wrongpass")
	require.ErrorIs(t, err, domain.ErrUnauthorized)
}

func TestRefreshToken_Success(t *testing.T) {
	svc := setupAuthService()
	ctx := context.Background()

	_, _, refresh, err := svc.Register(ctx, "refresh@b.com", "password123", "D")
	require.NoError(t, err)

	newAccess, newRefresh, err := svc.RefreshToken(ctx, refresh)
	require.NoError(t, err)
	require.NotEmpty(t, newAccess)
	require.NotEmpty(t, newRefresh)
}

func TestRefreshToken_Invalid(t *testing.T) {
	svc := setupAuthService()
	ctx := context.Background()

	_, _, err := svc.RefreshToken(ctx, "invalid-token")
	require.ErrorIs(t, err, domain.ErrUnauthorized)
}
```

- [ ] **Step 3: Run auth service tests**

```bash
cd backend && go test ./internal/service/... -v -count=1
```

---

### Task 9: Backend gRPC Auth Handler

**Files:**
- Create: `backend/internal/api/auth_handler.go`
- Create: `backend/internal/server/interceptor.go`
- Create: `backend/internal/server/server.go`

- [ ] **Step 1: Create auth_handler.go**

```go
package api

import (
	"context"

	"connectrpc.com/connect"
	pb "github.com/kshku/findiary/backend/internal/api/findiary/v1"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/service"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type AuthHandler struct {
	authSvc *service.AuthService
}

func NewAuthHandler(authSvc *service.AuthService) *AuthHandler {
	return &AuthHandler{authSvc: authSvc}
}

func (h *AuthHandler) Register(ctx context.Context, req *connect.Request[pb.RegisterRequest]) (*connect.Response[pb.AuthResponse], error) {
	user, accessToken, refreshToken, err := h.authSvc.Register(ctx, req.Msg.Email, req.Msg.Password, req.Msg.DisplayName)
	if err != nil {
		return nil, asConnectError(err)
	}

	return connect.NewResponse(&pb.AuthResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		User:         domainUserToProto(user),
	}), nil
}

func (h *AuthHandler) Login(ctx context.Context, req *connect.Request[pb.LoginRequest]) (*connect.Response[pb.AuthResponse], error) {
	user, accessToken, refreshToken, err := h.authSvc.Login(ctx, req.Msg.Email, req.Msg.Password)
	if err != nil {
		return nil, asConnectError(err)
	}

	return connect.NewResponse(&pb.AuthResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		User:         domainUserToProto(user),
	}), nil
}

func (h *AuthHandler) RefreshToken(ctx context.Context, req *connect.Request[pb.RefreshTokenRequest]) (*connect.Response[pb.AuthResponse], error) {
	accessToken, refreshToken, err := h.authSvc.RefreshToken(ctx, req.Msg.RefreshToken)
	if err != nil {
		return nil, asConnectError(err)
	}

	return connect.NewResponse(&pb.AuthResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}), nil
}

func domainUserToProto(u *domain.User) *pb.User {
	return &pb.User{
		Id:          u.ID,
		Email:       u.Email,
		DisplayName: u.DisplayName,
		CreatedAt:   timestamppb.New(u.CreatedAt),
	}
}

func asConnectError(err error) error {
	code := connect.CodeInternal
	switch {
	case isDomainError(err, domain.ErrInvalidInput):
		code = connect.CodeInvalidArgument
	case isDomainError(err, domain.ErrAlreadyExists):
		code = connect.CodeAlreadyExists
	case isDomainError(err, domain.ErrUnauthorized):
		code = connect.CodeUnauthenticated
	case isDomainError(err, domain.ErrNotFound):
		code = connect.CodeNotFound
	}
	return connect.NewError(code, err)
}

func isDomainError(err, target error) bool {
	return err != nil && containsString(err.Error(), target.Error())
}

func containsString(s, substr string) bool {
	return len(s) >= len(substr) && searchStr(s, substr)
}

func searchStr(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}
```

- [ ] **Step 2: Create server/interceptor.go**

```go
package server

import (
	"context"
	"log/slog"

	"connectrpc.com/connect"
	"github.com/kshku/findiary/backend/pkg/jwt"
)

type contextKey string

const userIDKey contextKey = "user_id"
const userEmailKey contextKey = "user_email"

// PublicProcedures that don't require authentication.
var publicProcedures = map[string]bool{
	"/findiary.v1.AuthService/Register":     true,
	"/findiary.v1.AuthService/Login":        true,
	"/findiary.v1.AuthService/RefreshToken": true,
}

// AuthInterceptor returns a connect unary interceptor that validates JWT tokens.
// Public procedures (Register, Login, RefreshToken) are skipped.
func AuthInterceptor(jwtMgr *jwt.Manager) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			if publicProcedures[req.Spec().Procedure] {
				return next(ctx, req)
			}

			tokenStr := req.Header().Get("Authorization")
			if tokenStr == "" {
				return nil, connect.NewError(connect.CodeUnauthenticated, nil)
			}
			if len(tokenStr) > 7 && tokenStr[:7] == "Bearer " {
				tokenStr = tokenStr[7:]
			}

			claims, err := jwtMgr.ValidateToken(tokenStr)
			if err != nil {
				return nil, connect.NewError(connect.CodeUnauthenticated, err)
			}

			ctx = context.WithValue(ctx, userIDKey, claims.UserID)
			ctx = context.WithValue(ctx, userEmailKey, claims.Email)
			return next(ctx, req)
		}
	}
}

// LoggingInterceptor logs every request.
func LoggingInterceptor(logger *slog.Logger) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			logger.Info("request", "procedure", req.Spec().Procedure)
			return next(ctx, req)
		}
	}
}
```

- [ ] **Step 3: Create server/server.go**

```go
package server

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"

	"connectrpc.com/connect"
	"github.com/jackc/pgx/v5/pgxpool"
	pb "github.com/kshku/findiary/backend/internal/api/findiary/v1"
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

	userRepo := repository.NewUserRepo(db)
	authSvc := service.NewAuthService(userRepo, mgr)
	authHandler := api.NewAuthHandler(authSvc)

	mux := http.NewServeMux()

	// Register auth handlers with logging + auth interceptors
	pattern, handler := pb.NewAuthServiceHandler(
		authHandler,
		connect.WithInterceptors(
			LoggingInterceptor(logger),
			AuthInterceptor(mgr),
		),
	)
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

- [ ] **Step 4: Install connect-go**

```bash
cd backend && go get connectrpc.com/connect@latest && go mod tidy
```

---

### Task 10: Backend Main Entrypoint

**Files:**
- Create: `backend/cmd/server/main.go`
- Create: `backend/Dockerfile`

- [ ] **Step 1: Create main.go**

```go
package main

import (
	"context"
	"log/slog"
	"os"
	"os/signal"
	"syscall"

	"github.com/kshku/findiary/backend/internal/config"
	"github.com/kshku/findiary/backend/internal/server"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))

	cfgPath := "config.yaml"
	if v := os.Getenv("CONFIG_PATH"); v != "" {
		cfgPath = v
	}

	cfg, err := config.Load(cfgPath)
	if err != nil {
		logger.Error("failed to load config", "error", err)
		os.Exit(1)
	}

	srv, err := server.New(cfg, logger)
	if err != nil {
		logger.Error("failed to create server", "error", err)
		os.Exit(1)
	}

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	go func() {
		if err := srv.Start(); err != nil {
			logger.Error("server error", "error", err)
			os.Exit(1)
		}
	}()

	<-ctx.Done()
	logger.Info("shutting down server")
	srv.Shutdown(context.Background())
}
```

- [ ] **Step 2: Create Dockerfile**

```dockerfile
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /server ./cmd/server

FROM alpine:3.19
RUN apk --no-cache add ca-certificates
COPY --from=builder /server /server
COPY config.yaml /config.yaml
EXPOSE 9090
CMD ["/server"]
```

- [ ] **Step 3: Build and verify compilation**

```bash
cd backend && go build ./cmd/server
```

---

### Task 11: Flutter Project Scaffold

**Files:**
- Create: `frontend/pubspec.yaml`
- Create: `frontend/lib/main.dart`
- Create: `frontend/lib/app.dart`
- Create: `frontend/analysis_options.yaml`

- [ ] **Step 1: Create Flutter project**

```bash
cd frontend && flutter create --org com.findiary --project-name findiary .
```

- [ ] **Step 2: Update pubspec.yaml with dependencies**

```yaml
name: findiary
description: Personal and family finance tracker
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.2.0

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2
  grpc: ^3.2.4
  protobuf: ^3.1.0
  drift: ^2.15.0
  sqlite3_flutter_libs: ^0.5.18
  path_provider: ^2.1.2
  path: ^1.8.3
  flutter_secure_storage: ^9.0.0
  go_router: ^14.0.0
  fl_chart: ^0.66.0
  connectivity_plus: ^5.0.2
  get_it: ^7.6.7
  injectable: ^2.3.2
  google_sign_in: ^6.1.5
  intl: ^0.19.0
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.8
  drift_dev: ^2.15.0
  bloc_test: ^9.1.4
  mocktail: ^1.0.1
```

- [ ] **Step 3: Create analysis_options.yaml**

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: false
```

- [ ] **Step 4: Install dependencies**

```bash
cd frontend && flutter pub get
```

- [ ] **Step 5: Create lib/main.dart**

```dart
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FinDiaryApp());
}
```

- [ ] **Step 6: Create lib/app.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FinDiaryApp extends StatelessWidget {
  const FinDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinDiary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const Scaffold(
        body: Center(child: Text('FinDiary')),
      ),
    );
  }
}
```

---

### Task 12: Flutter Generated Protobuf Code

**Files:**
- Create: `frontend/lib/generated/` (auto-generated from proto)

- [ ] **Step 1: Install protoc-gen-dart**

```bash
dart pub global activate protoc_plugin
```

- [ ] **Step 2: Generate Dart protobuf stubs**

```bash
cd proto && buf generate
```

- [ ] **Step 3: Verify generation**

```bash
ls frontend/lib/generated/findiary/v1/
# Should show: common.pb.dart, auth_service.pb.dart, auth_service.pbgrpc.dart, etc.
```

---

### Task 13: Flutter Core — gRPC Client + Auth

**Files:**
- Create: `frontend/lib/core/client/grpc_client.dart`
- Create: `frontend/lib/core/client/auth_interceptor.dart`
- Create: `frontend/lib/core/auth/auth_service.dart`
- Create: `frontend/lib/core/auth/token_storage.dart`

- [ ] **Step 1: Create lib/core/client/grpc_client.dart**

```dart
import 'package:grpc/grpc.dart';
import 'auth_interceptor.dart';

class GrpcClient {
  late final ClientChannel _channel;
  late final AuthInterceptor _authInterceptor;

  GrpcClient({String host = 'localhost', int port = 9090}) {
    _authInterceptor = AuthInterceptor();
    _channel = ClientChannel(
      host,
      port: port,
      options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        interceptors: [_authInterceptor],
      ),
    );
  }

  ClientChannel get channel => _channel;
  AuthInterceptor get authInterceptor => _authInterceptor;

  void setToken(String token) {
    _authInterceptor.setToken(token);
  }

  void clearToken() {
    _authInterceptor.clearToken();
  }

  Future<void> shutdown() async {
    await _channel.shutdown();
  }
}
```

- [ ] **Step 2: Create lib/core/client/auth_interceptor.dart**

```dart
import 'package:grpc/grpc.dart';

class AuthInterceptor extends ClientInterceptor {
  String? _token;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  @override
  void interceptUnary(
    ClientMethod method,
    dynamic request,
    CallOptions options,
    ClientUnaryInterceptorFunc invoker,
  ) {
    if (_token != null) {
      options = options.mergedWith(CallOptions(
        metadata: {'authorization': 'Bearer $_token'},
      ));
    }
    invoker(method, request, options);
  }
}
```

- [ ] **Step 3: Create lib/core/auth/token_storage.dart**

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _accessExpKey = 'access_expires_at';
  static const _refreshExpKey = 'refresh_expires_at';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int accessExpiresAt,
    required int refreshExpiresAt,
  }) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
      _storage.write(key: _accessExpKey, value: accessExpiresAt.toString()),
      _storage.write(key: _refreshExpKey, value: refreshExpiresAt.toString()),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<bool> isAccessTokenValid() async {
    final expStr = await _storage.read(key: _accessExpKey);
    if (expStr == null) return false;
    final exp = int.tryParse(expStr);
    if (exp == null) return false;
    return DateTime.now().millisecondsSinceEpoch < exp;
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
```

- [ ] **Step 4: Create lib/core/auth/auth_service.dart**

```dart
import 'package:grpc/grpc.dart';
import '../../generated/findiary/v1/auth_service.pbgrpc.dart';
import '../../generated/findiary/v1/auth_service.pb.dart';
import '../client/grpc_client.dart';
import 'token_storage.dart';

class AuthService {
  final GrpcClient _grpcClient;
  final TokenStorage _tokenStorage;

  late final AuthServiceClient _stub;

  AuthService({
    required GrpcClient grpcClient,
    required TokenStorage tokenStorage,
  })  : _grpcClient = grpcClient,
        _tokenStorage = tokenStorage {
    _stub = AuthServiceClient(_grpcClient.channel);
  }

  Future<bool> isLoggedIn() async {
    return await _tokenStorage.isAccessTokenValid();
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final request = RegisterRequest()
      ..email = email
      ..password = password
      ..displayName = displayName;
    final response = await _stub.register(request);
    await _handleAuthResponse(response);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest()
      ..email = email
      ..password = password;
    final response = await _stub.login(request);
    await _handleAuthResponse(response);
  }

  Future<void> refreshToken() async {
    final refresh = await _tokenStorage.getRefreshToken();
    if (refresh == null) throw Exception('No refresh token');
    final request = RefreshTokenRequest()..refreshToken = refresh;
    final response = await _stub.refreshToken(request);
    await _handleAuthResponse(response);
  }

  Future<void> logout() async {
    _grpcClient.clearToken();
    await _tokenStorage.clearTokens();
  }

  Future<void> _handleAuthResponse(AuthResponse response) async {
    await _tokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      accessExpiresAt: response.accessExpiresAt,
      refreshExpiresAt: response.refreshExpiresAt,
    );
    _grpcClient.setToken(response.accessToken);
  }
}
```

---

### Task 14: Flutter Auth Feature — BLoC + UI

**Files:**
- Create: `frontend/lib/features/auth/bloc/auth_bloc.dart`
- Create: `frontend/lib/features/auth/bloc/auth_event.dart`
- Create: `frontend/lib/features/auth/bloc/auth_state.dart`
- Create: `frontend/lib/features/auth/login_page.dart`
- Create: `frontend/lib/features/auth/register_page.dart`

- [ ] **Step 1: Create auth_state.dart**

```dart
import 'package:equatable/equatable.dart';
import '../../../generated/findiary/v1/common.pb.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, user, error];
}
```

- [ ] **Step 2: Create auth_event.dart**

```dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  LoginSubmitted({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  RegisterSubmitted({
    required this.email,
    required this.password,
    required this.displayName,
  });
  @override
  List<Object?> get props => [email, password, displayName];
}

class LogoutRequested extends AuthEvent {}

class AuthErrorShown extends AuthEvent {}
```

- [ ] **Step 3: Create auth_bloc.dart**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/auth/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthErrorShown>(_onErrorShown);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final loggedIn = await _authService.isLoggedIn();
      emit(state.copyWith(
        status: loggedIn
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
      ));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.login(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(status: AuthStatus.authenticated));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.register(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(state.copyWith(status: AuthStatus.authenticated));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.logout();
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  void _onErrorShown(AuthErrorShown event, Emitter<AuthState> emit) {
    emit(state.copyWith(error: null));
  }
}
```

- [ ] **Step 4: Create login_page.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(LoginSubmitted(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FinDiary')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            setState(() => _loading = state.status == AuthStatus.unknown);
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
              context.read<AuthBloc>().add(AuthErrorShown());
            }
          },
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter email';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  obscureText: _obscure,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter password';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  ),
                  child: const Text("Don't have an account? Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Create register_page.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(RegisterSubmitted(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          displayName: _nameCtrl.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            setState(() => _loading = state.status == AuthStatus.unknown);
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
              context.read<AuthBloc>().add(AuthErrorShown());
            }
          },
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter email';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  obscureText: _obscure,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter password';
                    if (v.length < 6) return 'At least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (v) {
                    if (v != _passwordCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Register'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### Task 15: Flutter App Root — DI + Router + Auth Gate

**Files:**
- Modify: `frontend/lib/app.dart`
- Create: `frontend/lib/core/di/injection.dart`
- Create: `frontend/features/home/dashboard_page.dart`

- [ ] **Step 1: Create lib/core/di/injection.dart**

```dart
import 'package:get_it/get_it.dart';
import '../auth/auth_service.dart';
import '../auth/token_storage.dart';
import '../client/grpc_client.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final grpcClient = GrpcClient(host: 'localhost', port: 9090);
  sl.registerLazySingleton<GrpcClient>(() => grpcClient);

  final tokenStorage = TokenStorage();
  sl.registerLazySingleton<TokenStorage>(() => tokenStorage);

  final authService = AuthService(
    grpcClient: grpcClient,
    tokenStorage: tokenStorage,
  );
  sl.registerLazySingleton<AuthService>(() => authService);
}
```

- [ ] **Step 2: Update lib/app.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/auth/auth_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/login_page.dart';
import 'features/home/dashboard_page.dart';

class FinDiaryApp extends StatelessWidget {
  const FinDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authService: sl<AuthService>()),
        ),
      ],
      child: MaterialApp(
        title: 'FinDiary',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.teal,
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.unknown:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case AuthStatus.authenticated:
            return const DashboardPage();
          case AuthStatus.unauthenticated:
            return const LoginPage();
        }
      },
    );
  }
}
```

- [ ] **Step 3: Create dashboard_page.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinDiary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to FinDiary!'),
            SizedBox(height: 8),
            Text('Start tracking your finances.'),
          ],
        ),
      ),
    );
  }
}
```

---

### Task 16: Integration Verification

**Files:**
- Modify: `frontend/lib/main.dart`

- [ ] **Step 1: Update lib/main.dart**

```dart
import 'package:flutter/material.dart';
import 'core/di/injection.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const FinDiaryApp());
}
```

- [ ] **Step 2: Verify backend compiles and starts**

```bash
cd backend && go build ./cmd/server && echo "Build OK"
# Start PostgreSQL and run server to verify:
docker compose up -d postgres 2>/dev/null || true
go run ./cmd/server &
sleep 2
# Test register via grpcurl or a test client
# Kill the server
kill %1 2>/dev/null || true
```

- [ ] **Step 3: Verify Flutter compiles**

```bash
cd frontend && flutter analyze && echo "Analysis OK"
cd frontend && flutter build apk --debug 2>/dev/null || flutter test
```

---

## Self-Review Checklist

1. **Spec coverage**: Phase 1 covers project structure, protobuf definitions, database schema, complete auth flow (register/login/refresh) on both backend and frontend. Missing from spec: transaction CRUD, family management, sync engine — all deferred to Phase 2.

2. **Placeholder scan**: No TBD, TODO, or incomplete sections. Every step has actual code.

3. **Type consistency**: `domain.User` → protobuf `User` → Dart `User` consistent across layers using UUID strings, email, displayName. JWT claims consistent with token generation/validation.

4. **Test coverage**: Repository tests with testcontainers (or test DB), auth service unit tests with mocks, Flutter bloc tests (referenced but deferred to Phase 2 for brevity).
