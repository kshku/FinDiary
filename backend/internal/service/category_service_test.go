package service_test

import (
	"context"
	"testing"

	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/service"
	"github.com/stretchr/testify/require"
)

type mockCatRepo struct {
	Categories map[string]*domain.Category
}

func (m *mockCatRepo) Create(ctx context.Context, cat *domain.Category) error {
	if m.Categories == nil {
		m.Categories = make(map[string]*domain.Category)
	}
	m.Categories[cat.ID] = cat
	return nil
}

func (m *mockCatRepo) FindByID(ctx context.Context, id string) (*domain.Category, error) {
	if m.Categories == nil {
		return nil, domain.ErrNotFound
	}
	cat, ok := m.Categories[id]
	if !ok {
		return nil, domain.ErrNotFound
	}
	return cat, nil
}

func (m *mockCatRepo) Update(ctx context.Context, cat *domain.Category) error {
	if m.Categories == nil {
		return domain.ErrNotFound
	}
	m.Categories[cat.ID] = cat
	return nil
}

func (m *mockCatRepo) Delete(ctx context.Context, id string) error {
	if m.Categories == nil {
		return domain.ErrNotFound
	}
	delete(m.Categories, id)
	return nil
}

func (m *mockCatRepo) List(ctx context.Context, scope string, familyID *string, catType string) ([]*domain.Category, error) {
	var result []*domain.Category
	for _, c := range m.Categories {
		if scope != "" && c.Scope != scope {
			continue
		}
		if familyID != nil && (c.FamilyID == nil || *c.FamilyID != *familyID) {
			continue
		}
		if catType != "" && c.Type != catType {
			continue
		}
		result = append(result, c)
	}
	return result, nil
}

type mockCatFamilyRepo struct {
	Members []*domain.FamilyMember
}

func (m *mockCatFamilyRepo) Create(ctx context.Context, family *domain.Family) error {
	return nil
}

func (m *mockCatFamilyRepo) FindByID(ctx context.Context, id string) (*domain.Family, error) {
	return nil, domain.ErrNotFound
}

func (m *mockCatFamilyRepo) Update(ctx context.Context, family *domain.Family) error {
	return nil
}

func (m *mockCatFamilyRepo) ListByUser(ctx context.Context, userID string) ([]*domain.Family, error) {
	return nil, nil
}

func (m *mockCatFamilyRepo) AddMember(ctx context.Context, member *domain.FamilyMember) error {
	return nil
}

func (m *mockCatFamilyRepo) RemoveMember(ctx context.Context, familyID, userID string) error {
	return nil
}

func (m *mockCatFamilyRepo) ListMembers(ctx context.Context, familyID string) ([]*domain.FamilyMember, error) {
	return nil, nil
}

func (m *mockCatFamilyRepo) IsMember(ctx context.Context, familyID, userID string) (bool, error) {
	for _, mem := range 	m.Members {
		if mem.FamilyID == familyID && mem.UserID == userID {
			return true, nil
		}
	}
	return false, nil
}

func (m *mockCatFamilyRepo) CreateInvitation(ctx context.Context, inv *domain.Invitation) error {
	return nil
}

func (m *mockCatFamilyRepo) FindInvitationByCode(ctx context.Context, code string) (*domain.Invitation, error) {
	return nil, domain.ErrNotFound
}

func (m *mockCatFamilyRepo) UpdateInvitation(ctx context.Context, inv *domain.Invitation) error {
	return nil
}

func (m *mockCatFamilyRepo) ListInvitations(ctx context.Context, familyID string) ([]*domain.Invitation, error) {
	return nil, nil
}

func (m *mockCatFamilyRepo) ListInvitationsByEmail(ctx context.Context, email string) ([]*domain.Invitation, error) {
	return nil, nil
}

func setupCategoryService() (*service.CategoryService, *mockCatRepo, *mockCatFamilyRepo) {
	catRepo := &mockCatRepo{}
	familyRepo := &mockCatFamilyRepo{}
	svc := service.NewCategoryService(catRepo, familyRepo)
	return svc, catRepo, familyRepo
}

func TestCreatePersonal(t *testing.T) {
	svc, catRepo, _ := setupCategoryService()
	ctx := context.Background()

	cat, err := svc.CreatePersonal(ctx, "user-1", "Groceries", "expense", nil, nil)
	require.NoError(t, err)
	require.NotEmpty(t, cat.ID)
	require.Equal(t, "Groceries", cat.Name)
	require.Equal(t, "expense", cat.Type)
	require.Equal(t, "personal", cat.Scope)
	require.NotNil(t, cat.CreatedBy)
	require.Equal(t, "user-1", *cat.CreatedBy)
	require.Len(t, catRepo.Categories, 1)
}

func TestDeleteSystem(t *testing.T) {
	svc, catRepo, _ := setupCategoryService()
	ctx := context.Background()

	catRepo.Categories = map[string]*domain.Category{
		"sys-1": {
		ID:    "sys-1",
			Name:  "System Category",
			Scope: "system",
			Type:  "expense",
		},
	}

	err := svc.Delete(ctx, "sys-1")
	require.ErrorIs(t, err, domain.ErrForbidden)
}
