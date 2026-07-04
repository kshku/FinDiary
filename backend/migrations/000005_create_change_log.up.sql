CREATE TABLE IF NOT EXISTS change_log (
    id BIGSERIAL PRIMARY KEY,
    family_id UUID REFERENCES families(id),
    changed_by UUID NOT NULL REFERENCES users(id),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('create', 'update', 'delete')),
    snapshot JSONB NOT NULL DEFAULT '{}',
    changed_fields TEXT[],
    server_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    client_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_change_log_family ON change_log(family_id);
CREATE INDEX idx_change_log_entity ON change_log(entity_type, entity_id);
CREATE INDEX idx_change_log_server_timestamp ON change_log(server_timestamp);
