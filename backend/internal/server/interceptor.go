package server

import (
	"context"
	"log/slog"
	"strings"

	"github.com/bufbuild/connect-go"
	"github.com/kshku/findiary/backend/internal/api"
	"github.com/kshku/findiary/backend/pkg/jwt"
)

var publicProcedures = map[string]bool{
	"/findiary.v1.AuthService/Register":     true,
	"/findiary.v1.AuthService/Login":        true,
	"/findiary.v1.AuthService/RefreshToken": true,
}

func AuthInterceptor(mgr *jwt.Manager) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			if publicProcedures[req.Spec().Procedure] {
				return next(ctx, req)
			}

			tokenStr := req.Header().Get("Authorization")
			if tokenStr == "" {
				return nil, connect.NewError(connect.CodeUnauthenticated, nil)
			}
			if strings.HasPrefix(tokenStr, "Bearer ") {
				tokenStr = tokenStr[7:]
			}

			claims, err := mgr.ValidateToken(tokenStr)
			if err != nil {
				return nil, connect.NewError(connect.CodeUnauthenticated, err)
			}

			ctx = context.WithValue(ctx, api.UserIDContextKey, claims.UserID)
			ctx = context.WithValue(ctx, api.UserEmailContextKey, claims.Email)
			return next(ctx, req)
		}
	}
}

func LoggingInterceptor(logger *slog.Logger) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			logger.Info("request", "procedure", req.Spec().Procedure)
			return next(ctx, req)
		}
	}
}
