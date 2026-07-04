package server

import (
	"context"
	"log/slog"
	"strings"

	"github.com/bufbuild/connect-go"
	"github.com/kshku/findiary/backend/pkg/jwt"
)

type contextKey string

const userIDKey contextKey = "user_id"
const userEmailKey contextKey = "user_email"

var publicProcedures = map[string]bool{
	"/findiary.v1.AuthService/Register":     true,
	"/findiary.v1.AuthService/Login":        true,
	"/findiary.v1.AuthService/RefreshToken": true,
}

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

			ctx = context.WithValue(ctx, userIDKey, claims.UserID)
			ctx = context.WithValue(ctx, userEmailKey, claims.Email)
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
