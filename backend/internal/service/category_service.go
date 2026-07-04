package service

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/kshku/findiary/backend/internal/domain"
)

type CategoryService struct {
	categoryRepo domain.CategoryRepository
	familyRepo   domain.FamilyRepository
}

func NewCategoryService(categoryRepo domain.CategoryRepository, familyRepo domain.FamilyRepository) *CategoryService {
	return &CategoryService{categoryRepo: categoryRepo, familyRepo: familyRepo}
}

func (s *CategoryService) CreatePersonal(ctx context.Context, userID, name, catType string, icon, color *string) (*domain.Category, error) {
	if name == "" {
		return nil, fmt.Errorf("%w: category name is required", domain.ErrInvalidInput)
	}
	if catType != "income" && catType != "expense" {
		return nil, fmt.Errorf("%w: type must be income or expense", domain.ErrInvalidInput)
	}

	now := time.Now().UTC().Format(time.RFC3339Nano)
	cat := &domain.Category{
		ID:        uuid.New().String(),
		Scope:     "personal",
		CreatedBy: &userID,
		Name:      name,
		Type:      catType,
		Icon:      icon,
		Color:     color,
		CreatedAt: now,
		UpdatedAt: now,
	}
	if err := s.categoryRepo.Create(ctx, cat); err != nil {
		return nil, err
	}
	return cat, nil
}

func (s *CategoryService) CreateFamily(ctx context.Context, userID, familyID, name, catType string, icon, color *string) (*domain.Category, error) {
	isMember, err := s.familyRepo.IsMember(ctx, familyID, userID)
	if err != nil {
		return nil, fmt.Errorf("check membership: %w", err)
	}
	if !isMember {
		return nil, fmt.Errorf("%w: not a family member", domain.ErrForbidden)
	}
	if name == "" {
		return nil, fmt.Errorf("%w: category name is required", domain.ErrInvalidInput)
	}
	if catType != "income" && catType != "expense" {
		return nil, fmt.Errorf("%w: type must be income or expense", domain.ErrInvalidInput)
	}

	now := time.Now().UTC().Format(time.RFC3339Nano)
	familyIDCopy := familyID
	cat := &domain.Category{
		ID:        uuid.New().String(),
		Scope:     "family",
		FamilyID:  &familyIDCopy,
		CreatedBy: &userID,
		Name:      name,
		Type:      catType,
		Icon:      icon,
		Color:     color,
		CreatedAt: now,
		UpdatedAt: now,
	}
	if err := s.categoryRepo.Create(ctx, cat); err != nil {
		return nil, err
	}
	return cat, nil
}

func (s *CategoryService) Get(ctx context.Context, id string) (*domain.Category, error) {
	return s.categoryRepo.FindByID(ctx, id)
}

func (s *CategoryService) Update(ctx context.Context, id, name string, icon, color *string) (*domain.Category, error) {
	cat, err := s.categoryRepo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if cat.Scope == "system" {
		return nil, fmt.Errorf("%w: cannot modify system categories", domain.ErrForbidden)
	}

	cat.Name = name
	cat.Icon = icon
	cat.Color = color
	cat.UpdatedAt = time.Now().UTC().Format(time.RFC3339Nano)

	if err := s.categoryRepo.Update(ctx, cat); err != nil {
		return nil, err
	}
	return cat, nil
}

func (s *CategoryService) Delete(ctx context.Context, id string) error {
	cat, err := s.categoryRepo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if cat.Scope == "system" {
		return fmt.Errorf("%w: cannot delete system categories", domain.ErrForbidden)
	}
	return s.categoryRepo.Delete(ctx, id)
}

func (s *CategoryService) List(ctx context.Context, userID string, scope string, familyID *string, catType string) ([]*domain.Category, error) {
	return s.categoryRepo.List(ctx, scope, familyID, catType)
}
