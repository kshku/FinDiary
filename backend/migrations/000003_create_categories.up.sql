CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY,
    scope VARCHAR(20) NOT NULL DEFAULT 'system',
    family_id UUID REFERENCES families(id),
    created_by UUID REFERENCES users(id),
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense')),
    icon VARCHAR(50),
    color VARCHAR(7),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_categories_scope ON categories(scope);
CREATE INDEX idx_categories_family ON categories(family_id);
