package domain

import "time"

type SyncScope struct {
	ScopeID   string
	ScopeType string
}

type SyncCheckpoint struct {
	ID             int64
	UserID         string
	ScopeID        *string
	ScopeType      string
	LastCheckpoint int64
	UpdatedAt      time.Time
}

type ChangeLogEntry struct {
	ID              int64
	FamilyID        *string
	ChangedBy       string
	EntityType      string
	EntityID        string
	Action          string
	Snapshot        string
	ChangedFields   []string
	ServerTimestamp time.Time
	ClientTimestamp time.Time
}

type SyncChange struct {
	EntityType      string
	EntityID        string
	Action          string
	Snapshot        []byte
	ClientTimestamp time.Time
	ChangedFields   []string
}

type ConflictInfo struct {
	EntityType  string
	EntityID    string
	Field       string
	LocalValue  string
	ServerValue string
}
