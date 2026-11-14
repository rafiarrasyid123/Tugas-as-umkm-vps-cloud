-- ====================================================================
-- MIGRATION: Table Orders (Sewa & Transaksi ServerCloud UMKM)
-- ====================================================================

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(60) UNIQUE NOT NULL,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    package_id INT NOT NULL REFERENCES server_packages(id) ON DELETE RESTRICT,
    duration_months INT NOT NULL DEFAULT 1 CHECK (duration_months >= 1),
    total_price NUMERIC(14, 2) NOT NULL CHECK (total_price >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'cancelled')),
    payment_method VARCHAR(50) NOT NULL DEFAULT 'bca_va',
    payment_code VARCHAR(100),
    server_ip VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    paid_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_package ON orders(package_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
