# Dokumentasi Basis Data & Entity Relationship Diagram (ERD)

**Nama Proyek:** ServerCloud  
**Tema:** Aplikasi Layanan Cloud Hosting & VPS Mandiri untuk UMKM  
**Satuan Pendidikan:** SMK Taruna Bhakti  
**Tahun Pelajaran:** 2026/2027  
**DBMS:** PostgreSQL / Aiven Cloud  

---

## 1. Diagram ERD (Mermaid)

```mermaid
erDiagram
    USERS ||--o{ SERVER_PACKAGES : "creates_and_manages"
    SERVICE_CATEGORIES ||--o{ SERVER_PACKAGES : "categorizes"

    USERS {
        serial id PK
        varchar(100) full_name
        varchar(100) email UK
        varchar(255) password "Bcrypt Hashed"
        varchar(20) role "admin | client"
        varchar(30) phone
        timestamptz created_at
    }

    SERVICE_CATEGORIES {
        serial id PK
        varchar(100) name
        varchar(100) slug UK
        text description
        timestamptz created_at
    }

    SERVER_PACKAGES {
        serial id PK
        int category_id FK
        varchar(150) name
        varchar(150) slug UK
        int cpu_cores
        int ram_gb
        int storage_gb
        int bandwidth_tb
        numeric(14,2) price_per_month
        int stock_available
        text image_url "Cloudinary URL / Local path"
        text description
        int created_by FK
        timestamptz created_at
        timestamptz updated_at
    }
```

---

## 2. Struktur Tabel & Atribut

### A. Tabel `users`
Menyimpan identitas pengguna, hak akses (role), dan password terenkripsi.
| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `SERIAL PRIMARY KEY` | ID unik pengguna (Auto Increment) |
| `full_name` | `VARCHAR(100) NOT NULL` | Nama lengkap pengguna |
| `email` | `VARCHAR(100) UNIQUE NOT NULL` | Alamat email untuk login |
| `password` | `VARCHAR(255) NOT NULL` | Password ter-hash menggunakan bcrypt |
| `role` | `VARCHAR(20) NOT NULL DEFAULT 'client'` | Hak akses (`admin` atau `client`) |
| `phone` | `VARCHAR(30)` | Nomor kontak telepon / WhatsApp |
| `created_at` | `TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP` | Waktu registrasi akun |

### B. Tabel `service_categories` (Data Utama 1)
Kategori paket layanan yang disediakan oleh UMKM ServerCloud (contoh: Cloud VPS NVMe, Shared Web Hosting, Dedicated Server).
| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `SERIAL PRIMARY KEY` | ID unik kategori (Auto Increment) |
| `name` | `VARCHAR(100) NOT NULL` | Nama kategori layanan |
| `slug` | `VARCHAR(100) UNIQUE NOT NULL` | Identifikasi URL ramah mesin pencari |
| `description` | `TEXT` | Deskripsi penjelasan kategori |
| `created_at` | `TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP` | Waktu penambahan kategori |

### C. Tabel `server_packages` (Data Utama 2)
Daftar paket spesifikasi server dan harga sewa bulanan yang ditawarkan.
| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `SERIAL PRIMARY KEY` | ID unik paket server (Auto Increment) |
| `category_id` | `INT NOT NULL (FK)` | Relasi ke `service_categories(id)` |
| `name` | `VARCHAR(150) NOT NULL` | Nama paket (contoh: VPS Starter NVMe 1G) |
| `slug` | `VARCHAR(150) UNIQUE NOT NULL` | Slug unik paket server |
| `cpu_cores` | `INT NOT NULL CHECK (cpu_cores >= 1)` | Jumlah core processor vCPU |
| `ram_gb` | `INT NOT NULL CHECK (ram_gb >= 1)` | Kapasitas RAM dalam Gigabyte |
| `storage_gb` | `INT NOT NULL CHECK (storage_gb >= 1)` | Kapasitas penyimpanan SSD NVMe |
| `bandwidth_tb` | `INT NOT NULL CHECK (bandwidth_tb >= 1)` | Kuota bandwidth bulanan dalam TB |
| `price_per_month` | `NUMERIC(14,2) NOT NULL` | Biaya sewa bulanan dalam Rupiah |
| `stock_available` | `INT NOT NULL DEFAULT 10` | Ketersediaan slot server |
| `image_url` | `TEXT` | URL file gambar banner/arsitektur |
| `description` | `TEXT` | Rincian fitur & sistem operasi pendukung |
| `created_by` | `INT (FK)` | Relasi ke `users(id)` yang membuat paket |
| `created_at` | `TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP` | Waktu dibuat |
| `updated_at` | `TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP` | Waktu terakhir diperbarui |

---

## 3. Relasi & Integritas Data
1. **Relasi `service_categories` -> `server_packages`**:
   - Tipe: **One-to-Many (1:N)**. Satu kategori dapat memiliki banyak paket server.
   - Aturan Integritas: `ON DELETE RESTRICT ON UPDATE CASCADE`. Kategori tidak boleh dihapus jika masih ada paket server aktif di dalamnya untuk mencegah *orphan records*.
2. **Relasi `users` -> `server_packages`**:
   - Tipe: **One-to-Many (1:N)**. Satu user admin dapat menginput banyak paket server.
   - Aturan Integritas: `ON DELETE SET NULL ON UPDATE CASCADE`. Jika user dihapus, data paket tetap aman dan kolom `created_by` diset NULL.
