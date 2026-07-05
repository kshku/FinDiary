CREATE TABLE IF NOT EXISTS sync_checkpoints (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    scope_id UUID,
    scope_type VARCHAR(20) NOT NULL CHECK (scope_type IN ('personal', 'family')),
    last_checkpoint BIGINT NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_sync_checkpoints_unique
    ON sync_checkpoints(user_id, coalesce(scope_id, '00000000-0000-0000-0000-000000000000'), scope_type);
