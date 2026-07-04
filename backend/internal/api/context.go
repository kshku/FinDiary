package api

import "context"

type ContextKey string

const UserIDContextKey ContextKey = "user_id"
const UserEmailContextKey ContextKey = "user_email"

func UserIDFromContext(ctx context.Context) string {
	if v, ok := ctx.Value(UserIDContextKey).(string); ok {
		return v
	}
	return ""
}

func UserEmailFromContext(ctx context.Context) string {
	if v, ok := ctx.Value(UserEmailContextKey).(string); ok {
		return v
	}
	return ""
}
