-- ====================================================================
-- DATABASE SCHEMA: ServerCloud (PostgreSQL DDL)
-- Sistem Manajemen Layanan Cloud & VPS Hosting UMKM
-- ====================================================================

-- 1. Buat Tabel Users
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'client' CHECK (role IN ('admin', 'client')),
    phone VARCHAR(30),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Buat Tabel Kategori Layanan (Data Utama 1)
CREATE TABLE IF NOT EXISTS service_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Buat Tabel Paket Layanan Cloud / Server (Data Utama 2)
CREATE TABLE IF NOT EXISTS server_packages (
    id SERIAL PRIMARY KEY,
    category_id INT NOT NULL REFERENCES service_categories(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(150) UNIQUE NOT NULL,
    cpu_cores INT NOT NULL DEFAULT 1 CHECK (cpu_cores >= 1),
    ram_gb INT NOT NULL DEFAULT 1 CHECK (ram_gb >= 1),
    storage_gb INT NOT NULL DEFAULT 20 CHECK (storage_gb >= 1),
    bandwidth_tb INT NOT NULL DEFAULT 1 CHECK (bandwidth_tb >= 1),
    price_per_month NUMERIC(14, 2) NOT NULL DEFAULT 0 CHECK (price_per_month >= 0),
    stock_available INT NOT NULL DEFAULT 10 CHECK (stock_available >= 0),
    image_url TEXT,
    description TEXT,
    created_by INT REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Index untuk mempercepat query search & filter
CREATE INDEX IF NOT EXISTS idx_packages_category ON server_packages(category_id);
CREATE INDEX IF NOT EXISTS idx_packages_slug ON server_packages(slug);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
