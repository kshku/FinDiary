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
	FamilyID  string
	UserID    string
	Role      string
	JoinedAt  string
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
