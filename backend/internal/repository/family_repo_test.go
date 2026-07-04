package repository_test

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/repository"
	"github.com/stretchr/testify/require"
)

func TestFamilyRepo_CreateAndFind(t *testing.T) {
	db := setupTestDB(t)
	repo := repository.NewFamilyRepo(db)
	ctx := context.Background()

	user := createTestUser(t, ctx, db)
	now := time.Now().UTC().Format(time.RFC3339Nano)

	family := &domain.Family{
		ID:        uuid.New().String(),
		Name:      "Test Family",
		OwnerID:   user.ID,
		CreatedAt: now,
		UpdatedAt: now,
	}

	err := repo.Create(ctx, family)
	require.NoError(t, err)

	found, err := repo.FindByID(ctx, family.ID)
	require.NoError(t, err)
	require.Equal(t, family.ID, found.ID)
	require.Equal(t, family.Name, found.Name)
	require.Equal(t, family.OwnerID, found.OwnerID)
	require.Equal(t, family.CreatedAt, found.CreatedAt)
	require.Equal(t, family.UpdatedAt, found.UpdatedAt)
}

func TestFamilyRepo_NotFound(t *testing.T) {
	db := setupTestDB(t)
	repo := repository.NewFamilyRepo(db)

	_, err := repo.FindByID(context.Background(), uuid.New().String())
	require.ErrorIs(t, err, domain.ErrNotFound)
}

func TestFamilyRepo_AddAndListMembers(t *testing.T) {
	db := setupTestDB(t)
	familyRepo := repository.NewFamilyRepo(db)
	ctx := context.Background()

	owner := createTestUser(t, ctx, db)
	member := createTestUser(t, ctx, db)

	now := time.Now().UTC().Format(time.RFC3339Nano)
	family := &domain.Family{
		ID:        uuid.New().String(),
		Name:      "Test Family",
		OwnerID:   owner.ID,
		CreatedAt: now,
		UpdatedAt: now,
	}
	require.NoError(t, familyRepo.Create(ctx, family))

	fm := &domain.FamilyMember{
		FamilyID:  family.ID,
		UserID:    member.ID,
		Role:      "member",
		JoinedAt:  now,
	}
	err := familyRepo.AddMember(ctx, fm)
	require.NoError(t, err)

	// List members
	members, err := familyRepo.ListMembers(ctx, family.ID)
	require.NoError(t, err)
	require.Len(t, members, 1)
	require.Equal(t, member.ID, members[0].UserID)
	require.Equal(t, "member", members[0].Role)

	// IsMember
	isMember, err := familyRepo.IsMember(ctx, family.ID, member.ID)
	require.NoError(t, err)
	require.True(t, isMember)

	isMember, err = familyRepo.IsMember(ctx, family.ID, uuid.New().String())
	require.NoError(t, err)
	require.False(t, isMember)
}

func TestFamilyRepo_AddMemberDuplicate(t *testing.T) {
	db := setupTestDB(t)
	familyRepo := repository.NewFamilyRepo(db)
	ctx := context.Background()

	owner := createTestUser(t, ctx, db)
	member := createTestUser(t, ctx, db)

	now := time.Now().UTC().Format(time.RFC3339Nano)
	family := &domain.Family{
		ID:        uuid.New().String(),
		Name:      "Test Family",
		OwnerID:   owner.ID,
		CreatedAt: now,
		UpdatedAt: now,
	}
	require.NoError(t, familyRepo.Create(ctx, family))

	fm := &domain.FamilyMember{
		FamilyID:  family.ID,
		UserID:    member.ID,
		Role:      "member",
		JoinedAt:  now,
	}
	require.NoError(t, familyRepo.AddMember(ctx, fm))

	err := familyRepo.AddMember(ctx, fm)
	require.ErrorIs(t, err, domain.ErrAlreadyExists)
}

func TestFamilyRepo_ListByUser(t *testing.T) {
	db := setupTestDB(t)
	familyRepo := repository.NewFamilyRepo(db)
	ctx := context.Background()

	user := createTestUser(t, ctx, db)
	now := time.Now().UTC().Format(time.RFC3339Nano)

	family1 := &domain.Family{
		ID:        uuid.New().String(),
		Name:      "Family One",
		OwnerID:   user.ID,
		CreatedAt: now,
		UpdatedAt: now,
	}
	require.NoError(t, familyRepo.Create(ctx, family1))

	// List families where user is owner
	families, err := familyRepo.ListByUser(ctx, user.ID)
	require.NoError(t, err)
	require.Len(t, families, 1)
	require.Equal(t, family1.ID, families[0].ID)

	// Add user as member of another family
	otherOwner := createTestUser(t, ctx, db)
	family2 := &domain.Family{
		ID:        uuid.New().String(),
		Name:      "Family Two",
		OwnerID:   otherOwner.ID,
		CreatedAt: now,
		UpdatedAt: now,
	}
	require.NoError(t, familyRepo.Create(ctx, family2))

	fm := &domain.FamilyMember{
		FamilyID:  family2.ID,
		UserID:    user.ID,
		Role:      "member",
		JoinedAt:  now,
	}
	require.NoError(t, familyRepo.AddMember(ctx, fm))

	families, err = familyRepo.ListByUser(ctx, user.ID)
	require.NoError(t, err)
	require.Len(t, families, 2)
}

func TestFamilyRepo_RemoveMember(t *testing.T) {
	db := setupTestDB(t)
	familyRepo := repository.NewFamilyRepo(db)
	ctx := context.Background()

	owner := createTestUser(t, ctx, db)
	member := createTestUser(t, ctx, db)

	now := time.Now().UTC().Format(time.RFC3339Nano)
	family := &domain.Family{
		ID:        uuid.New().String(),
		Name:      "Test Family",
		OwnerID:   owner.ID,
		CreatedAt: now,
		UpdatedAt: now,
	}
	require.NoError(t, familyRepo.Create(ctx, family))

	fm := &domain.FamilyMember{
		FamilyID:  family.ID,
		UserID:    member.ID,
		Role:      "member",
		JoinedAt:  now,
	}
	require.NoError(t, familyRepo.AddMember(ctx, fm))

	err := familyRepo.RemoveMember(ctx, family.ID, member.ID)
	require.NoError(t, err)

	isMember, err := familyRepo.IsMember(ctx, family.ID, member.ID)
	require.NoError(t, err)
	require.False(t, isMember)

	err = familyRepo.RemoveMember(ctx, family.ID, member.ID)
	require.ErrorIs(t, err, domain.ErrNotFound)
}

func TestFamilyRepo_Invitations(t *testing.T) {
	db := setupTestDB(t)
	familyRepo := repository.NewFamilyRepo(db)
	ctx := context.Background()

	owner := createTestUser(t, ctx, db)
	now := time.Now().UTC().Format(time.RFC3339Nano)

	family := &domain.Family{
		ID:        uuid.New().String(),
		Name:      "Test Family",
		OwnerID:   owner.ID,
		CreatedAt: now,
		UpdatedAt: now,
	}
	require.NoError(t, familyRepo.Create(ctx, family))

	inv := &domain.Invitation{
		ID:        uuid.New().String(),
		FamilyID:  family.ID,
		Email:     "invited@example.com",
		Code:      uuid.New().String(),
		Status:    "pending",
		CreatedBy: owner.ID,
		CreatedAt: now,
		ExpiresAt: time.Now().UTC().Add(24 * time.Hour).Format(time.RFC3339Nano),
	}

	err := familyRepo.CreateInvitation(ctx, inv)
	require.NoError(t, err)

	// Find by code
	found, err := familyRepo.FindInvitationByCode(ctx, inv.Code)
	require.NoError(t, err)
	require.Equal(t, inv.ID, found.ID)
	require.Equal(t, inv.Email, found.Email)

	// Update invitation
	found.Status = "accepted"
	err = familyRepo.UpdateInvitation(ctx, found)
	require.NoError(t, err)

	// List invitations
	list, err := familyRepo.ListInvitations(ctx, family.ID)
	require.NoError(t, err)
	require.Len(t, list, 1)
	require.Equal(t, "accepted", list[0].Status)

	// List by email
	emailList, err := familyRepo.ListInvitationsByEmail(ctx, "invited@example.com")
	require.NoError(t, err)
	require.Len(t, emailList, 0) // no longer pending

	// Find by code not found
	_, err = familyRepo.FindInvitationByCode(ctx, "nonexistent")
	require.ErrorIs(t, err, domain.ErrNotFound)
}

func TestFamilyRepo_Update(t *testing.T) {
	db := setupTestDB(t)
	familyRepo := repository.NewFamilyRepo(db)
	ctx := context.Background()

	user := createTestUser(t, ctx, db)
	now := time.Now().UTC().Format(time.RFC3339Nano)

	family := &domain.Family{
		ID:        uuid.New().String(),
		Name:      "Original Name",
		OwnerID:   user.ID,
		CreatedAt: now,
		UpdatedAt: now,
	}
	require.NoError(t, familyRepo.Create(ctx, family))

	family.Name = "Updated Name"
	family.UpdatedAt = time.Now().UTC().Format(time.RFC3339Nano)
	err := familyRepo.Update(ctx, family)
	require.NoError(t, err)

	found, err := familyRepo.FindByID(ctx, family.ID)
	require.NoError(t, err)
	require.Equal(t, "Updated Name", found.Name)
}
