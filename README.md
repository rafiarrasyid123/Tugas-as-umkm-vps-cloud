# ServerCloud - Layanan Cloud Hosting & VPS Mandiri untuk UMKM

Platform digital penyedia dan manajemen infrastruktur cloud, Virtual Private Server (VPS), dan Web Hosting berskala UMKM (Jasa Teknologi Informasi).

## 🚀 Tech Stack

### Backend REST API
- **Runtime**: Node.js & TypeScript
- **Framework**: Express.js
- **Database**: PostgreSQL (Hosted on Aiven Cloud with SSL)
- **Validation**: Zod Schema Validation
- **Authentication**: JSON Web Token (JWT) & Bcrypt Password Hashing
- **File Upload**: Multer & Cloudinary CDN
- **Deployment**: Vercel Serverless

### Mobile Client
- **Framework**: Flutter (Dart)
- **State & Theme**: Neo-brutalism Clean Theme (`AppTheme.neoDecoration`), Google Fonts Inter
- **Networking**: `http` package, `shared_preferences`, `image_picker`

---

## 👥 Akun Pengujian (Testing Accounts)

| Role | Email | Password | Hak Akses |
| :--- | :--- | :--- | :--- |
| **Admin** | `admin@servercloud.id` | `password123` | Kelola kategori, CRUD paket server, upload banner |
| **Client** | `client@servercloud.id` | `password123` | Melihat katalog, filter spek teknis, detail server |

---

## 📋 Endpoint REST API

- `POST /api/auth/register` - Registrasi pengguna baru
- `POST /api/auth/login` - Login pengguna (menerbitkan JWT)
- `GET /api/auth/profile` - Profil pengguna aktif
- `GET /api/categories` - Ambil daftar kategori layanan
- `POST /api/categories` - Tambah kategori (Admin)
- `GET /api/packages` - Ambil daftar paket server (search, filter category, sort)
- `GET /api/packages/:id` - Detail spesifikasi paket server
- `POST /api/packages` - Tambah paket server + Upload banner (Admin)
- `PUT /api/packages/:id` - Update paket server (Admin)
- `DELETE /api/packages/:id` - Hapus paket server (Admin)

---

## 🛠️ Menjalankan Backend Secara Lokal

```bash
cd backend
npm install
npm run migrate  # Migrasi DDL & seeder akun uji ke PostgreSQL
npm run dev      # Menjalankan server (port 5000)
```
