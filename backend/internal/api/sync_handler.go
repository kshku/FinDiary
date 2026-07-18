package api

import (
	"context"
	"errors"

	"github.com/bufbuild/connect-go"
	pb "github.com/kshku/findiary/backend/internal/api/findiary/v1"
	"github.com/kshku/findiary/backend/internal/domain"
	"github.com/kshku/findiary/backend/internal/service"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type SyncHandler struct {
	svc *service.SyncService
}

func NewSyncHandler(svc *service.SyncService) *SyncHandler {
	return &SyncHandler{svc: svc}
}

func (h *SyncHandler) Sync(ctx context.Context, req *connect.Request[pb.SyncRequest]) (*connect.Response[pb.SyncResponse], error) {
	userID := UserIDFromContext(ctx)

	localChanges := make([]domain.SyncChange, len(req.Msg.LocalChanges))
	for i, lc := range req.Msg.LocalChanges {
		localChanges[i] = domain.SyncChange{
			EntityType:      lc.EntityType,
			EntityID:        lc.EntityId,
			Action:          lc.Action,
			Snapshot:        lc.Snapshot,
			ClientTimestamp: lc.ClientTimestamp.AsTime(),
			ChangedFields:   lc.ChangedFields,
		}
	}

	result, err := h.svc.Sync(ctx, userID, req.Msg.ScopeId, req.Msg.ScopeType, req.Msg.LastCheckpoint, localChanges)
	if err != nil {
		if errors.Is(err, domain.ErrForbidden) {
			return nil, connect.NewError(connect.CodePermissionDenied, err)
		}
		if errors.Is(err, domain.ErrInvalidInput) {
			return nil, connect.NewError(connect.CodeInvalidArgument, err)
		}
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	resp := &pb.SyncResponse{
		NewCheckpoint: result.NewCheckpoint,
	}

	for _, rc := range result.RemoteChanges {
		pbEntry := changeLogEntryToProto(&rc)
		resp.RemoteChanges = append(resp.RemoteChanges, pbEntry)
	}

	for _, c := range result.Conflicts {
		resp.Conflicts = append(resp.Conflicts, conflictInfoToProto(&c))
	}

	return connect.NewResponse(resp), nil
}

func changeLogEntryToProto(entry *domain.ChangeLogEntry) *pb.SyncChangeEntry {
	ts := timestamppb.New(entry.ClientTimestamp)
	return &pb.SyncChangeEntry{
		EntityType:      entry.EntityType,
		EntityId:        entry.EntityID,
		Action:          entry.Action,
		Snapshot:        []byte(entry.Snapshot),
		ClientTimestamp: ts,
		ChangedFields:   entry.ChangedFields,
	}
}

func conflictInfoToProto(c *domain.ConflictInfo) *pb.ConflictInfo {
	return &pb.ConflictInfo{
		EntityType:  c.EntityType,
		EntityId:    c.EntityID,
		Field:       c.Field,
		LocalValue:  c.LocalValue,
		ServerValue: c.ServerValue,
	}
}
