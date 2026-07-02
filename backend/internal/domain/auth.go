package domain

type AuthService interface {
	Register(email, password, displayName string) (*User, string, string, error)
	Login(email, password string) (*User, string, string, error)
	RefreshToken(refreshToken string) (string, string, error)
}
