package server

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/bufbuild/connect-go"
	pb "github.com/kshku/findiary/backend/internal/api/findiary/v1"
	pbv1connect "github.com/kshku/findiary/backend/internal/api/findiary/v1/v1connect"
	"github.com/kshku/findiary/backend/internal/api"
	"github.com/kshku/findiary/backend/internal/config"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/service"
	"github.com/kshku/findiary/backend/pkg/jwt"
	"github.com/stretchr/testify/require"
)

type mockUserRepo struct {
	users []*domain.User
}

func (m *mockUserRepo) Create(_ context.Context, user *domain.User) error {
	for _, u := range m.users {
		if u.Email == user.Email {
			return domain.ErrAlreadyExists
		}
	}
	m.users = append(m.users, user)
	return nil
}

func (m *mockUserRepo) FindByID(_ context.Context, id string) (*domain.User, error) {
	for _, u := range m.users {
		if u.ID == id {
			return u, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (m *mockUserRepo) FindByEmail(_ context.Context, email string) (*domain.User, error) {
	for _, u := range m.users {
		if u.Email == email {
			return u, nil
		}
	}
	return nil, domain.ErrNotFound
}

func setupTestServer(t *testing.T) *httptest.Server {
	t.Helper()

	cfg := &config.Config{
		JWT: config.JWTConfig{
			Secret:     "test-secret",
			AccessTTL:  15 * time.Minute,
			RefreshTTL: 720 * time.Hour,
		},
	}

	mgr := jwt.NewManager(cfg.JWT.Secret, cfg.JWT.AccessTTL, cfg.JWT.RefreshTTL)
	svc := service.NewAuthService(&mockUserRepo{}, mgr)
	handler := api.NewAuthHandler(svc)

	mux := http.NewServeMux()
	pattern, connectHandler := pbv1connect.NewAuthServiceHandler(
		handler,
		connect.WithInterceptors(AuthInterceptor(mgr)),
	)
	mux.Handle(pattern, connectHandler)

	return httptest.NewServer(mux)
}

func TestRegisterViaHTTP(t *testing.T) {
	srv := setupTestServer(t)
	defer srv.Close()

	client := pbv1connect.NewAuthServiceClient(
		http.DefaultClient,
		srv.URL,
	)

	resp, err := client.Register(
		context.Background(),
		connect.NewRequest(&pb.RegisterRequest{
			Email:       "test@example.com",
			Password:    "password123",
			DisplayName: "Test User",
		}),
	)
	require.NoError(t, err)
	require.NotEmpty(t, resp.Msg.AccessToken)
	require.NotEmpty(t, resp.Msg.RefreshToken)
	require.NotEmpty(t, resp.Msg.User.Id)
	require.Equal(t, "test@example.com", resp.Msg.User.Email)
}

func TestLoginViaHTTP(t *testing.T) {
	srv := setupTestServer(t)
	defer srv.Close()

	client := pbv1connect.NewAuthServiceClient(
		http.DefaultClient,
		srv.URL,
	)

	_, err := client.Register(
		context.Background(),
		connect.NewRequest(&pb.RegisterRequest{
			Email:    "login@example.com",
			Password: "password123",
		}),
	)
	require.NoError(t, err)

	resp, err := client.Login(
		context.Background(),
		connect.NewRequest(&pb.LoginRequest{
			Email:    "login@example.com",
			Password: "password123",
		}),
	)
	require.NoError(t, err)
	require.NotEmpty(t, resp.Msg.AccessToken)
}

func TestAuthInterceptor_RejectsUnauthenticated(t *testing.T) {
	srv := setupTestServer(t)
	defer srv.Close()

	client := pbv1connect.NewAuthServiceClient(
		http.DefaultClient,
		srv.URL,
	)

	_, err := client.RefreshToken(
		context.Background(),
		connect.NewRequest(&pb.RefreshTokenRequest{
			RefreshToken: "some-token",
		}),
	)
	require.Error(t, err)
	require.Equal(t, connect.CodeUnauthenticated, connect.CodeOf(err))
}
