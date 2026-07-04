package api

import (
	"context"
	"errors"
	"time"

	"github.com/bufbuild/connect-go"
	pb "github.com/kshku/findiary/backend/internal/api/findiary/v1"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/service"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type FamilyHandler struct {
	svc *service.FamilyService
}

func NewFamilyHandler(svc *service.FamilyService) *FamilyHandler {
	return &FamilyHandler{svc: svc}
}

func (h *FamilyHandler) CreateFamily(ctx context.Context, req *connect.Request[pb.CreateFamilyRequest]) (*connect.Response[pb.CreateFamilyResponse], error) {
	userID := UserIDFromContext(ctx)
	family, err := h.svc.Create(ctx, userID, req.Msg.Name)
	if err != nil {
		return nil, mapError(err)
	}
	return connect.NewResponse(&pb.CreateFamilyResponse{
		Family: domainFamilyToProto(family),
	}), nil
}

func (h *FamilyHandler) GetFamily(ctx context.Context, req *connect.Request[pb.GetFamilyRequest]) (*connect.Response[pb.GetFamilyResponse], error) {
	userID := UserIDFromContext(ctx)
	family, err := h.svc.Get(ctx, userID, req.Msg.Id)
	if err != nil {
		return nil, mapError(err)
	}
	return connect.NewResponse(&pb.GetFamilyResponse{
		Family: domainFamilyToProto(family),
	}), nil
}

func (h *FamilyHandler) UpdateFamily(ctx context.Context, req *connect.Request[pb.UpdateFamilyRequest]) (*connect.Response[pb.UpdateFamilyResponse], error) {
	userID := UserIDFromContext(ctx)
	family, err := h.svc.Update(ctx, userID, req.Msg.Id, req.Msg.Name)
	if err != nil {
		return nil, mapError(err)
	}
	return connect.NewResponse(&pb.UpdateFamilyResponse{
		Family: domainFamilyToProto(family),
	}), nil
}

func (h *FamilyHandler) ListMyFamilies(ctx context.Context, req *connect.Request[emptypb.Empty]) (*connect.Response[pb.ListMyFamiliesResponse], error) {
	userID := UserIDFromContext(ctx)
	families, err := h.svc.ListMy(ctx, userID)
	if err != nil {
		return nil, mapError(err)
	}
	protoFamilies := make([]*pb.Family, len(families))
	for i, f := range families {
		protoFamilies[i] = domainFamilyToProto(f)
	}
	return connect.NewResponse(&pb.ListMyFamiliesResponse{
		Families: protoFamilies,
	}), nil
}

func (h *FamilyHandler) AddMember(ctx context.Context, req *connect.Request[pb.AddMemberRequest]) (*connect.Response[pb.AddMemberResponse], error) {
	userID := UserIDFromContext(ctx)
	member, err := h.svc.AddMember(ctx, userID, req.Msg.FamilyId, req.Msg.UserId, req.Msg.Role)
	if err != nil {
		return nil, mapError(err)
	}
	return connect.NewResponse(&pb.AddMemberResponse{
		Member: domainFamilyMemberToProto(member),
	}), nil
}

func (h *FamilyHandler) RemoveMember(ctx context.Context, req *connect.Request[pb.RemoveMemberRequest]) (*connect.Response[pb.RemoveMemberResponse], error) {
	userID := UserIDFromContext(ctx)
	err := h.svc.RemoveMember(ctx, userID, req.Msg.FamilyId, req.Msg.UserId)
	if err != nil {
		return nil, mapError(err)
	}
	return connect.NewResponse(&pb.RemoveMemberResponse{}), nil
}

func (h *FamilyHandler) InviteMember(ctx context.Context, req *connect.Request[pb.InviteMemberRequest]) (*connect.Response[pb.InviteMemberResponse], error) {
	userID := UserIDFromContext(ctx)
	inv, err := h.svc.Invite(ctx, userID, req.Msg.FamilyId, req.Msg.Email)
	if err != nil {
		return nil, mapError(err)
	}
	return connect.NewResponse(&pb.InviteMemberResponse{
		Invitation: domainInvitationToProto(inv),
	}), nil
}

func (h *FamilyHandler) AcceptInvitation(ctx context.Context, req *connect.Request[pb.AcceptInvitationRequest]) (*connect.Response[pb.AcceptInvitationResponse], error) {
	userID := UserIDFromContext(ctx)
	member, err := h.svc.AcceptInvitation(ctx, userID, req.Msg.Code)
	if err != nil {
		return nil, mapError(err)
	}
	return connect.NewResponse(&pb.AcceptInvitationResponse{
		Member: domainFamilyMemberToProto(member),
	}), nil
}

func (h *FamilyHandler) RevokeInvitation(ctx context.Context, req *connect.Request[pb.RevokeInvitationRequest]) (*connect.Response[pb.RevokeInvitationResponse], error) {
	userID := UserIDFromContext(ctx)
	inv, err := h.svc.RevokeInvitation(ctx, userID, req.Msg.Id)
	if err != nil {
		return nil, mapError(err)
	}
	return connect.NewResponse(&pb.RevokeInvitationResponse{
		Invitation: domainInvitationToProto(inv),
	}), nil
}

func (h *FamilyHandler) ListInvitations(ctx context.Context, req *connect.Request[pb.ListInvitationsRequest]) (*connect.Response[pb.ListInvitationsResponse], error) {
	userID := UserIDFromContext(ctx)
	invitations, err := h.svc.ListInvitations(ctx, userID, req.Msg.FamilyId)
	if err != nil {
		return nil, mapError(err)
	}
	protoInvs := make([]*pb.Invitation, len(invitations))
	for i, inv := range invitations {
		protoInvs[i] = domainInvitationToProto(inv)
	}
	return connect.NewResponse(&pb.ListInvitationsResponse{
		Invitations: protoInvs,
	}), nil
}

func (h *FamilyHandler) ListMembers(ctx context.Context, req *connect.Request[pb.ListMembersRequest]) (*connect.Response[pb.ListMembersResponse], error) {
	userID := UserIDFromContext(ctx)
	members, err := h.svc.ListMembers(ctx, userID, req.Msg.FamilyId)
	if err != nil {
		return nil, mapError(err)
	}
	protoMembers := make([]*pb.FamilyMember, len(members))
	for i, m := range members {
		protoMembers[i] = domainFamilyMemberToProto(m)
	}
	return connect.NewResponse(&pb.ListMembersResponse{
		Members: protoMembers,
	}), nil
}

func mapError(err error) error {
	if errors.Is(err, domain.ErrNotFound) {
		return connect.NewError(connect.CodeNotFound, err)
	}
	if errors.Is(err, domain.ErrAlreadyExists) {
		return connect.NewError(connect.CodeAlreadyExists, err)
	}
	if errors.Is(err, domain.ErrInvalidInput) {
		return connect.NewError(connect.CodeInvalidArgument, err)
	}
	if errors.Is(err, domain.ErrUnauthorized) {
		return connect.NewError(connect.CodeUnauthenticated, err)
	}
	if errors.Is(err, domain.ErrForbidden) {
		return connect.NewError(connect.CodePermissionDenied, err)
	}
	return connect.NewError(connect.CodeInternal, err)
}

func parseTimeToProto(s string) *timestamppb.Timestamp {
	t, err := time.Parse(time.RFC3339Nano, s)
	if err != nil {
		return nil
	}
	return timestamppb.New(t)
}

func domainFamilyToProto(f *domain.Family) *pb.Family {
	return &pb.Family{
		Id:        f.ID,
		Name:      f.Name,
		OwnerId:   f.OwnerID,
		CreatedAt: parseTimeToProto(f.CreatedAt),
		UpdatedAt: parseTimeToProto(f.UpdatedAt),
	}
}

func domainFamilyMemberToProto(m *domain.FamilyMember) *pb.FamilyMember {
	return &pb.FamilyMember{
		FamilyId: m.FamilyID,
		UserId:   m.UserID,
		Role:     m.Role,
		JoinedAt: parseTimeToProto(m.JoinedAt),
	}
}

func domainInvitationToProto(inv *domain.Invitation) *pb.Invitation {
	return &pb.Invitation{
		Id:        inv.ID,
		FamilyId:  inv.FamilyID,
		Email:     inv.Email,
		Status:    inv.Status,
		CreatedBy: inv.CreatedBy,
		CreatedAt: parseTimeToProto(inv.CreatedAt),
		ExpiresAt: parseTimeToProto(inv.ExpiresAt),
	}
}
