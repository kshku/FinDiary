package domain

import "context"

type Category struct {
	ID        string
	Scope     string
	FamilyID  *string
	CreatedBy *string
	Name      string
	Type      string
	Icon      *string
	Color     *string
	CreatedAt string
	UpdatedAt string
}

type CategoryRepository interface {
	Create(ctx context.Context, cat *Category) error
	FindByID(ctx context.Context, id string) (*Category, error)
	Update(ctx context.Context, cat *Category) error
	Delete(ctx context.Context, id string) error
	List(ctx context.Context, scope string, familyID *string, catType string) ([]*Category, error)
}

type CategoryService interface {
	CreatePersonal(ctx context.Context, userID, name, catType string, icon, color *string) (*Category, error)
	CreateFamily(ctx context.Context, userID, familyID, name, catType string, icon, color *string) (*Category, error)
	Get(ctx context.Context, id string) (*Category, error)
	Update(ctx context.Context, id, name string, icon, color *string) (*Category, error)
	Delete(ctx context.Context, id string) error
	List(ctx context.Context, userID string, scope string, familyID *string, catType string) ([]*Category, error)
}
