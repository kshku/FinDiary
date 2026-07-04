package service_test

import (
	"context"
	"testing"

	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/service"
	"github.com/stretchr/testify/require"
)

type mockFamilyRepo struct {
	Families    []*domain.Family
	Members     []*domain.FamilyMember
	Invitations []*domain.Invitation
}

func (m *mockFamilyRepo) Create(ctx context.Context, f *domain.Family) error {
	m.Families = append(m.Families, f)
	return nil
}

func (m *mockFamilyRepo) FindByID(ctx context.Context, id string) (*domain.Family, error) {
	for _, f := range m.Families {
		if f.ID == id {
			return f, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (m *mockFamilyRepo) Update(ctx context.Context, f *domain.Family) error {
	for i, ff := range m.Families {
		if ff.ID == f.ID {
			m.Families[i] = f
			return nil
		}
	}
	return domain.ErrNotFound
}

func (m *mockFamilyRepo) ListByUser(ctx context.Context, userID string) ([]*domain.Family, error) {
	var result []*domain.Family
	for _, f := range m.Families {
		if f.OwnerID == userID {
			result = append(result, f)
			continue
		}
		for _, mem := range m.Members {
			if mem.FamilyID == f.ID && mem.UserID == userID {
				result = append(result, f)
				break
			}
		}
	}
	return result, nil
}

func (m *mockFamilyRepo) AddMember(ctx context.Context, member *domain.FamilyMember) error {
	m.Members = append(m.Members, member)
	return nil
}

func (m *mockFamilyRepo) RemoveMember(ctx context.Context, familyID, userID string) error {
	for i, mem := range m.Members {
		if mem.FamilyID == familyID && mem.UserID == userID {
			m.Members = append(m.Members[:i], m.Members[i+1:]...)
			return nil
		}
	}
	return domain.ErrNotFound
}

func (m *mockFamilyRepo) ListMembers(ctx context.Context, familyID string) ([]*domain.FamilyMember, error) {
	var result []*domain.FamilyMember
	for _, mem := range m.Members {
		if mem.FamilyID == familyID {
			result = append(result, mem)
		}
	}
	return result, nil
}

func (m *mockFamilyRepo) IsMember(ctx context.Context, familyID, userID string) (bool, error) {
	for _, mem := range m.Members {
		if mem.FamilyID == familyID && mem.UserID == userID {
			return true, nil
		}
	}
	return false, nil
}

func (m *mockFamilyRepo) CreateInvitation(ctx context.Context, inv *domain.Invitation) error {
	m.Invitations = append(m.Invitations, inv)
	return nil
}

func (m *mockFamilyRepo) FindInvitationByCode(ctx context.Context, code string) (*domain.Invitation, error) {
	for _, inv := range m.Invitations {
		if inv.Code == code {
			return inv, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (m *mockFamilyRepo) UpdateInvitation(ctx context.Context, inv *domain.Invitation) error {
	for i, ii := range m.Invitations {
		if ii.ID == inv.ID {
			m.Invitations[i] = inv
			return nil
		}
	}
	return domain.ErrNotFound
}

func (m *mockFamilyRepo) ListInvitations(ctx context.Context, familyID string) ([]*domain.Invitation, error) {
	var result []*domain.Invitation
	for _, inv := range m.Invitations {
		if inv.FamilyID == familyID {
			result = append(result, inv)
		}
	}
	return result, nil
}

func (m *mockFamilyRepo) ListInvitationsByEmail(ctx context.Context, email string) ([]*domain.Invitation, error) {
	var result []*domain.Invitation
	for _, inv := range m.Invitations {
		if inv.Email == email {
			result = append(result, inv)
		}
	}
	return result, nil
}

type mockFamUserRepo struct {
	Users []*domain.User
}

func (m *mockFamUserRepo) Create(ctx context.Context, user *domain.User) error {
	m.Users = append(m.Users, user)
	return nil
}

func (m *mockFamUserRepo) FindByID(ctx context.Context, id string) (*domain.User, error) {
	for _, u := range m.Users {
		if u.ID == id {
			return u, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (m *mockFamUserRepo) FindByEmail(ctx context.Context, email string) (*domain.User, error) {
	for _, u := range m.Users {
		if u.Email == email {
			return u, nil
		}
	}
	return nil, domain.ErrNotFound
}

func setupFamilyService() (*service.FamilyService, *mockFamilyRepo, *mockFamUserRepo) {
	familyRepo := &mockFamilyRepo{}
	userRepo := &mockFamUserRepo{}
	svc := service.NewFamilyService(familyRepo, userRepo)
	return svc, familyRepo, userRepo
}

func TestCreate(t *testing.T) {
	svc, familyRepo, _ := setupFamilyService()
	ctx := context.Background()

	family, err := svc.Create(ctx, "user-1", "My Family")
	require.NoError(t, err)
	require.NotEmpty(t, family.ID)
	require.Equal(t, "My Family", family.Name)
	require.Equal(t, "user-1", family.OwnerID)
	require.Len(t, familyRepo.Families, 1)
	require.Len(t, familyRepo.Members, 1)
	require.Equal(t, "owner", familyRepo.Members[0].Role)
}

func TestCreate_EmptyName(t *testing.T) {
	svc, _, _ := setupFamilyService()
	ctx := context.Background()

	_, err := svc.Create(ctx, "user-1", "")
	require.ErrorIs(t, err, domain.ErrInvalidInput)
}

func TestGet_NotMember(t *testing.T) {
	svc, familyRepo, _ := setupFamilyService()
	ctx := context.Background()

	familyRepo.Families = append(familyRepo.Families, &domain.Family{
		ID: "fam-1", Name: "Test", OwnerID: "user-1",
	})
	familyRepo.Members = append(familyRepo.Members, &domain.FamilyMember{
		FamilyID: "fam-1", UserID: "user-1", Role: "owner",
	})

	_, err := svc.Get(ctx, "user-2", "fam-1")
	require.ErrorIs(t, err, domain.ErrForbidden)
}

func TestInvite_InvalidEmail(t *testing.T) {
	svc, familyRepo, _ := setupFamilyService()
	ctx := context.Background()

	familyRepo.Families = append(familyRepo.Families, &domain.Family{
		ID: "fam-1", Name: "Test", OwnerID: "user-1",
	})
	familyRepo.Members = append(familyRepo.Members, &domain.FamilyMember{
		FamilyID: "fam-1", UserID: "user-1", Role: "owner",
	})

	_, err := svc.Invite(ctx, "user-1", "fam-1", "")
	require.ErrorIs(t, err, domain.ErrInvalidInput)

	_, err = svc.Invite(ctx, "user-1", "fam-1", "not-an-email")
	require.ErrorIs(t, err, domain.ErrInvalidInput)
}
