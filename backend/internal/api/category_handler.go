package api

import (
	"context"
	"errors"

	"github.com/bufbuild/connect-go"
	pb "github.com/kshku/findiary/backend/internal/api/findiary/v1"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/service"
)

type CategoryHandler struct {
	svc *service.CategoryService
}

func NewCategoryHandler(svc *service.CategoryService) *CategoryHandler {
	return &CategoryHandler{svc: svc}
}

func (h *CategoryHandler) CreateCategory(ctx context.Context, req *connect.Request[pb.CreateCategoryRequest]) (*connect.Response[pb.CreateCategoryResponse], error) {
	userID := UserIDFromContext(ctx)
	var cat *domain.Category
	var err error
	switch req.Msg.Scope {
	case "personal":
		cat, err = h.svc.CreatePersonal(ctx, userID, req.Msg.Name, req.Msg.Type, req.Msg.Icon, req.Msg.Color)
	case "family":
		if req.Msg.FamilyId == nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("family_id is required for family scope"))
		}
		cat, err = h.svc.CreateFamily(ctx, userID, *req.Msg.FamilyId, req.Msg.Name, req.Msg.Type, req.Msg.Icon, req.Msg.Color)
	default:
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("scope must be personal or family"))
	}
	if err != nil {
		return nil, mapError(err)
	}
	return connect.NewResponse(&pb.CreateCategoryResponse{
		Category: domainCategoryToProto(cat),
	}), nil
}

func (h *CategoryHandler) GetCategory(ctx context.Context, req *connect.Request[pb.GetCategoryRequest]) (*connect.Response[pb.GetCategoryResponse], error) {
	cat, err := h.svc.Get(ctx, req.Msg.Id)
	if err != nil {
		return nil, mapError(err)
	}
	return connect.NewResponse(&pb.GetCategoryResponse{
		Category: domainCategoryToProto(cat),
	}), nil
}

func (h *CategoryHandler) UpdateCategory(ctx context.Context, req *connect.Request[pb.UpdateCategoryRequest]) (*connect.Response[pb.UpdateCategoryResponse], error) {
	cat, err := h.svc.Update(ctx, req.Msg.Id, req.Msg.Name, req.Msg.Icon, req.Msg.Color)
	if err != nil {
		return nil, mapError(err)
	}
	return connect.NewResponse(&pb.UpdateCategoryResponse{
		Category: domainCategoryToProto(cat),
	}), nil
}

func (h *CategoryHandler) DeleteCategory(ctx context.Context, req *connect.Request[pb.DeleteCategoryRequest]) (*connect.Response[pb.DeleteCategoryResponse], error) {
	err := h.svc.Delete(ctx, req.Msg.Id)
	if err != nil {
		return nil, mapError(err)
	}
	return connect.NewResponse(&pb.DeleteCategoryResponse{}), nil
}

func (h *CategoryHandler) ListCategories(ctx context.Context, req *connect.Request[pb.ListCategoriesRequest]) (*connect.Response[pb.ListCategoriesResponse], error) {
	userID := UserIDFromContext(ctx)
	categories, err := h.svc.List(ctx, userID, req.Msg.Scope, req.Msg.FamilyId, req.Msg.Type)
	if err != nil {
		return nil, mapError(err)
	}
	protoCats := make([]*pb.Category, len(categories))
	for i, c := range categories {
		protoCats[i] = domainCategoryToProto(c)
	}
	return connect.NewResponse(&pb.ListCategoriesResponse{
		Categories: protoCats,
	}), nil
}

func domainCategoryToProto(c *domain.Category) *pb.Category {
	return &pb.Category{
		Id:        c.ID,
		Scope:     c.Scope,
		FamilyId:  c.FamilyID,
		CreatedBy: c.CreatedBy,
		Name:      c.Name,
		Type:      c.Type,
		Icon:      c.Icon,
		Color:     c.Color,
		CreatedAt: parseTimeToProto(c.CreatedAt),
		UpdatedAt: parseTimeToProto(c.UpdatedAt),
	}
}
