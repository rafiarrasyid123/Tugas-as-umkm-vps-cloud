-- ====================================================================
-- DATABASE SEED: ServerCloud (PostgreSQL DML)
-- Data Awal Akun Pengujian, Kategori Layanan, dan Paket Server
-- ====================================================================

-- Password untuk akun pengujian di bawah ini adalah "password123"
INSERT INTO users (full_name, email, password, role, phone)
VALUES 
    ('Cloud Administrator', 'admin@servercloud.id', '$2b$10$gzwAjOka//OZcPPsYByNfOG5q7nDrS21lsLxoTj/cb0rg.hyO2t.C', 'admin', '081234567890'),
    ('Rafi Client', 'client@servercloud.id', '$2b$10$gzwAjOka//OZcPPsYByNfOG5q7nDrS21lsLxoTj/cb0rg.hyO2t.C', 'client', '089876543210')
ON CONFLICT (email) DO UPDATE SET password = EXCLUDED.password;

-- Data Kategori Layanan
INSERT INTO service_categories (name, slug, description)
VALUES 
    ('Cloud VPS NVMe', 'cloud-vps-nvme', 'Server virtual performa tinggi dengan teknologi storage NVMe SSD kecepatan tinggi untuk aplikasi web dan backend.'),
    ('Shared Web Hosting', 'shared-web-hosting', 'Paket hosting hemat dan handal untuk website profil UMKM, portfolio, dan landing page.'),
    ('Dedicated Server', 'dedicated-server', 'Server fisik mandiri tanpa berbagi resource untuk database skala besar dan komputasi intensif.')
ON CONFLICT (slug) DO NOTHING;

-- Data Paket Layanan Server
INSERT INTO server_packages 
    (category_id, name, slug, cpu_cores, ram_gb, storage_gb, bandwidth_tb, price_per_month, stock_available, image_url, description, created_by)
VALUES 
    (1, 'VPS Starter NVMe 1G', 'vps-starter-nvme-1g', 1, 1, 25, 1, 85000.00, 15, 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=800&q=80', 'Cocok untuk microservice, bot Telegram/Discord, dan staging environment.', 1),
    (1, 'VPS Business NVMe 4G', 'vps-business-nvme-4g', 2, 4, 80, 4, 250000.00, 8, 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?auto=format&fit=crop&w=800&q=80', 'Rekomendasi terbaik untuk aplikasi e-commerce UMKM dan REST API production.', 1),
    (2, 'Hosting UMKM Pro', 'hosting-umkm-pro', 1, 2, 20, 2, 45000.00, 30, 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=800&q=80', 'Sudah termasuk Free SSL, cPanel, unlimited email akun bisnis, dan auto backup.', 1),
    (3, 'Baremetal Enterprise AMD', 'baremetal-enterprise-amd', 16, 64, 1000, 20, 1850000.00, 3, 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=800&q=80', 'Dedicated server prosesor AMD EPYC dengan perlindungan Anti-DDoS enterprise.', 1)
ON CONFLICT (slug) DO NOTHING;
