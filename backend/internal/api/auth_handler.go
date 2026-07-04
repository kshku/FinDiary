package api

import (
	"context"
	"errors"

	"github.com/bufbuild/connect-go"
	"github.com/golang-jwt/jwt/v5"
	pb "github.com/kshku/findiary/backend/internal/api/findiary/v1"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/service"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type AuthHandler struct {
	svc *service.AuthService
}

func NewAuthHandler(svc *service.AuthService) *AuthHandler {
	return &AuthHandler{svc: svc}
}

func (h *AuthHandler) Register(ctx context.Context, req *connect.Request[pb.RegisterRequest]) (*connect.Response[pb.RegisterResponse], error) {
	user, accessToken, refreshToken, err := h.svc.Register(ctx, req.Msg.Email, req.Msg.Password, req.Msg.DisplayName)
	if err != nil {
		if errors.Is(err, domain.ErrAlreadyExists) {
			return nil, connect.NewError(connect.CodeAlreadyExists, err)
		}
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	return connect.NewResponse(&pb.RegisterResponse{
		AccessToken:      accessToken,
		RefreshToken:     refreshToken,
		AccessExpiresAt:  tokenExpiresUnix(accessToken),
		RefreshExpiresAt: tokenExpiresUnix(refreshToken),
		User:             domainUserToProto(user),
	}), nil
}

func (h *AuthHandler) Login(ctx context.Context, req *connect.Request[pb.LoginRequest]) (*connect.Response[pb.LoginResponse], error) {
	user, accessToken, refreshToken, err := h.svc.Login(ctx, req.Msg.Email, req.Msg.Password)
	if err != nil {
		if errors.Is(err, domain.ErrUnauthorized) {
			return nil, connect.NewError(connect.CodeUnauthenticated, err)
		}
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}
	return connect.NewResponse(&pb.LoginResponse{
		AccessToken:      accessToken,
		RefreshToken:     refreshToken,
		AccessExpiresAt:  tokenExpiresUnix(accessToken),
		RefreshExpiresAt: tokenExpiresUnix(refreshToken),
		User:             domainUserToProto(user),
	}), nil
}

func (h *AuthHandler) RefreshToken(ctx context.Context, req *connect.Request[pb.RefreshTokenRequest]) (*connect.Response[pb.RefreshTokenResponse], error) {
	accessToken, refreshToken, err := h.svc.RefreshToken(ctx, req.Msg.RefreshToken)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnauthenticated, err)
	}
	return connect.NewResponse(&pb.RefreshTokenResponse{
		AccessToken:      accessToken,
		RefreshToken:     refreshToken,
		AccessExpiresAt:  tokenExpiresUnix(accessToken),
		RefreshExpiresAt: tokenExpiresUnix(refreshToken),
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

func tokenExpiresUnix(tokenStr string) int64 {
	p := jwt.Parser{}
	t, _, _ := p.ParseUnverified(tokenStr, jwt.MapClaims{})
	if claims, ok := t.Claims.(jwt.MapClaims); ok {
		if exp, ok := claims["exp"].(float64); ok {
			return int64(exp)
		}
	}
	return 0
}
