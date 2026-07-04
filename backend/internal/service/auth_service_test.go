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
