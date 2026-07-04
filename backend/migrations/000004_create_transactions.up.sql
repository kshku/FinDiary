CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY,
    family_id UUID REFERENCES families(id),
    created_by UUID NOT NULL REFERENCES users(id),
    type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense')),
    amount NUMERIC(18,2) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    category_id UUID NOT NULL REFERENCES categories(id),
    description TEXT,
    date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_transactions_family ON transactions(family_id);
CREATE INDEX idx_transactions_created_by ON transactions(created_by);
CREATE INDEX idx_transactions_date ON transactions(date);
CREATE INDEX idx_transactions_deleted_at ON transactions(deleted_at);
CREATE INDEX idx_transactions_type ON transactions(type);
