package service

import (
	"context"
	"fmt"
	"math/rand"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/kshku/findiary/backend/internal/domain"
)

type FamilyService struct {
	familyRepo domain.FamilyRepository
	userRepo   domain.UserRepository
}

func NewFamilyService(familyRepo domain.FamilyRepository, userRepo domain.UserRepository) *FamilyService {
	return &FamilyService{familyRepo: familyRepo, userRepo: userRepo}
}

func (s *FamilyService) Create(ctx context.Context, userID, name string) (*domain.Family, error) {
	if name == "" {
		return nil, fmt.Errorf("%w: family name is required", domain.ErrInvalidInput)
	}

	now := time.Now().UTC().Format(time.RFC3339Nano)
	family := &domain.Family{
		ID:        uuid.New().String(),
		Name:      name,
		OwnerID:   userID,
		CreatedAt: now,
		UpdatedAt: now,
	}

	if err := s.familyRepo.Create(ctx, family); err != nil {
		return nil, err
	}

	member := &domain.FamilyMember{
		FamilyID:  family.ID,
		UserID:    userID,
		Role:      "owner",
		JoinedAt:  now,
		InvitedBy: userID,
	}
	if err := s.familyRepo.AddMember(ctx, member); err != nil {
		return nil, err
	}

	return family, nil
}

func (s *FamilyService) Get(ctx context.Context, userID, familyID string) (*domain.Family, error) {
	ok, err := s.familyRepo.IsMember(ctx, familyID, userID)
	if err != nil {
		return nil, err
	}
	if !ok {
		return nil, fmt.Errorf("%w: not a family member", domain.ErrForbidden)
	}
	return s.familyRepo.FindByID(ctx, familyID)
}

func (s *FamilyService) Update(ctx context.Context, userID, familyID, name string) (*domain.Family, error) {
	if name == "" {
		return nil, fmt.Errorf("%w: family name is required", domain.ErrInvalidInput)
	}

	family, err := s.familyRepo.FindByID(ctx, familyID)
	if err != nil {
		return nil, err
	}
	if family.OwnerID != userID {
		return nil, fmt.Errorf("%w: only the owner can update the family", domain.ErrForbidden)
	}

	family.Name = name
	family.UpdatedAt = time.Now().UTC().Format(time.RFC3339Nano)

	if err := s.familyRepo.Update(ctx, family); err != nil {
		return nil, err
	}
	return family, nil
}

func (s *FamilyService) ListMy(ctx context.Context, userID string) ([]*domain.Family, error) {
	return s.familyRepo.ListByUser(ctx, userID)
}

func (s *FamilyService) AddMember(ctx context.Context, userID, familyID, targetUserID, role string) (*domain.FamilyMember, error) {
	isAdmin, err := isAdminOrOwner(ctx, s.familyRepo, familyID, userID)
	if err != nil {
		return nil, err
	}
	if !isAdmin {
		return nil, fmt.Errorf("%w: only admin or owner can add members", domain.ErrForbidden)
	}

	now := time.Now().UTC().Format(time.RFC3339Nano)
	member := &domain.FamilyMember{
		FamilyID:  familyID,
		UserID:    targetUserID,
		Role:      role,
		JoinedAt:  now,
		InvitedBy: userID,
	}
	if err := s.familyRepo.AddMember(ctx, member); err != nil {
		return nil, err
	}
	return member, nil
}

func (s *FamilyService) RemoveMember(ctx context.Context, userID, familyID, targetUserID string) error {
	family, err := s.familyRepo.FindByID(ctx, familyID)
	if err != nil {
		return err
	}
	if family.OwnerID != userID {
		return fmt.Errorf("%w: only the owner can remove members", domain.ErrForbidden)
	}
	if targetUserID == userID {
		return fmt.Errorf("%w: owner cannot remove themselves", domain.ErrForbidden)
	}
	return s.familyRepo.RemoveMember(ctx, familyID, targetUserID)
}

func generateCode() string {
	rng := rand.New(rand.NewSource(time.Now().UnixNano()))
	const charset = "abcdefghijklmnopqrstuvwxyz0123456789"
	code := make([]byte, 8)
	for i := range code {
		code[i] = charset[rng.Intn(len(charset))]
	}
	return string(code)
}

func (s *FamilyService) Invite(ctx context.Context, userID, familyID, email string) (*domain.Invitation, error) {
	if email == "" || !strings.Contains(email, "@") {
		return nil, fmt.Errorf("%w: valid email is required", domain.ErrInvalidInput)
	}

	isAdmin, err := isAdminOrOwner(ctx, s.familyRepo, familyID, userID)
	if err != nil {
		return nil, err
	}
	if !isAdmin {
		return nil, fmt.Errorf("%w: only admin or owner can invite", domain.ErrForbidden)
	}

	now := time.Now().UTC()
	inv := &domain.Invitation{
		ID:        uuid.New().String(),
		FamilyID:  familyID,
		Email:     email,
		Code:      generateCode(),
		Status:    "pending",
		CreatedBy: userID,
		CreatedAt: now.Format(time.RFC3339Nano),
		ExpiresAt: now.Add(7 * 24 * time.Hour).Format(time.RFC3339Nano),
	}
	if err := s.familyRepo.CreateInvitation(ctx, inv); err != nil {
		return nil, err
	}
	return inv, nil
}

func (s *FamilyService) AcceptInvitation(ctx context.Context, userID, code string) (*domain.FamilyMember, error) {
	inv, err := s.familyRepo.FindInvitationByCode(ctx, code)
	if err != nil {
		return nil, fmt.Errorf("%w: invalid invitation code", domain.ErrNotFound)
	}
	if inv.Status != "pending" {
		return nil, fmt.Errorf("%w: invitation is not pending", domain.ErrInvalidInput)
	}

	expiresAt, err := time.Parse(time.RFC3339Nano, inv.ExpiresAt)
	if err == nil && time.Now().UTC().After(expiresAt) {
		return nil, fmt.Errorf("%w: invitation has expired", domain.ErrInvalidInput)
	}

	user, err := s.userRepo.FindByID(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("find user: %w", err)
	}
	if user.Email != inv.Email {
		return nil, fmt.Errorf("%w: invitation email does not match user email", domain.ErrForbidden)
	}

	now := time.Now().UTC().Format(time.RFC3339Nano)
	member := &domain.FamilyMember{
		FamilyID:  inv.FamilyID,
		UserID:    userID,
		Role:      "member",
		JoinedAt:  now,
		InvitedBy: inv.CreatedBy,
	}
	if err := s.familyRepo.AddMember(ctx, member); err != nil {
		return nil, err
	}

	inv.Status = "accepted"
	if err := s.familyRepo.UpdateInvitation(ctx, inv); err != nil {
		return nil, fmt.Errorf("update invitation: %w", err)
	}
	return member, nil
}

func (s *FamilyService) RevokeInvitation(ctx context.Context, userID, invitationID string) (*domain.Invitation, error) {
	families, err := s.familyRepo.ListByUser(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("list families: %w", err)
	}

	for _, family := range families {
		isOwner := family.OwnerID == userID
		isAdmin := false
		if !isOwner {
			members, err := s.familyRepo.ListMembers(ctx, family.ID)
			if err != nil {
				return nil, fmt.Errorf("list members: %w", err)
			}
			for _, m := range members {
				if m.UserID == userID && m.Role == "admin" {
					isAdmin = true
					break
				}
			}
		}
		if !isOwner && !isAdmin {
			continue
		}

		invs, err := s.familyRepo.ListInvitations(ctx, family.ID)
		if err != nil {
			return nil, fmt.Errorf("list invitations: %w", err)
		}
		for _, inv := range invs {
			if inv.ID == invitationID {
				inv.Status = "revoked"
				if err := s.familyRepo.UpdateInvitation(ctx, inv); err != nil {
					return nil, fmt.Errorf("revoke invitation: %w", err)
				}
				return inv, nil
			}
		}
	}
	return nil, fmt.Errorf("%w: invitation not found", domain.ErrNotFound)
}

func (s *FamilyService) ListInvitations(ctx context.Context, userID, familyID string) ([]*domain.Invitation, error) {
	ok, err := s.familyRepo.IsMember(ctx, familyID, userID)
	if err != nil {
		return nil, err
	}
	if !ok {
		return nil, fmt.Errorf("%w: not a family member", domain.ErrForbidden)
	}
	return s.familyRepo.ListInvitations(ctx, familyID)
}

func (s *FamilyService) ListMembers(ctx context.Context, userID, familyID string) ([]*domain.FamilyMember, error) {
	ok, err := s.familyRepo.IsMember(ctx, familyID, userID)
	if err != nil {
		return nil, err
	}
	if !ok {
		return nil, fmt.Errorf("%w: not a family member", domain.ErrForbidden)
	}
	return s.familyRepo.ListMembers(ctx, familyID)
}

func isAdminOrOwner(ctx context.Context, familyRepo domain.FamilyRepository, familyID, userID string) (bool, error) {
	family, err := familyRepo.FindByID(ctx, familyID)
	if err != nil {
		return false, err
	}
	if family.OwnerID == userID {
		return true, nil
	}
	members, err := familyRepo.ListMembers(ctx, familyID)
	if err != nil {
		return false, err
	}
	for _, m := range members {
		if m.UserID == userID && (m.Role == "admin" || m.Role == "owner") {
			return true, nil
		}
	}
	return false, nil
}
