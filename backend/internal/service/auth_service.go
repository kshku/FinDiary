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

	accessToken, _, err := s.jwtMgr.GenerateAccessToken(user.ID, user.Email)
	if err != nil {
		return nil, "", "", fmt.Errorf("generate access token: %w", err)
	}
	refreshToken, _, err := s.jwtMgr.GenerateRefreshToken(user.ID, user.Email)
	if err != nil {
		return nil, "", "", fmt.Errorf("generate refresh token: %w", err)
	}

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

	accessToken, _, err := s.jwtMgr.GenerateAccessToken(user.ID, user.Email)
	if err != nil {
		return nil, "", "", fmt.Errorf("generate access token: %w", err)
	}
	refreshToken, _, err := s.jwtMgr.GenerateRefreshToken(user.ID, user.Email)
	if err != nil {
		return nil, "", "", fmt.Errorf("generate refresh token: %w", err)
	}

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
