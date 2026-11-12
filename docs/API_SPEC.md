# Dokumentasi Spesifikasi REST API ServerCloud

Dokumentasi lengkap endpoint API, method HTTP, status code, dan skema request/response JSON untuk presentasi penilaian.

**Base URL**: `http://localhost:5000` (atau URL Cloud jika di-deploy)

---

## 1. Autentikasi Pengguna (`/api/auth`)

### 1.1 Registrasi Pengguna
* **URL**: `/api/auth/register`
* **Method**: `POST`
* **Access**: Public
* **Request Body** (JSON):
```json
{
  "full_name": "Rafi Arrasyid",
  "email": "rafi@servercloud.id",
  "password": "password123",
  "phone": "081234567890",
  "role": "client"
}
```
* **Success Response (201 Created)**:
```json
{
  "success": true,
  "message": "Registrasi pengguna berhasil",
  "data": {
    "user": {
      "id": 3,
      "full_name": "Rafi Arrasyid",
      "email": "rafi@servercloud.id",
      "role": "client",
      "phone": "081234567890",
      "created_at": "2026-11-12T12:00:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```
* **Error Response (400 Bad Request)**:
```json
{
  "success": false,
  "message": "Validasi data gagal",
  "errors": [
    { "field": "email", "message": "Format email tidak valid" },
    { "field": "password", "message": "Password minimal 6 karakter" }
  ]
}
```

### 1.2 Login Pengguna
* **URL**: `/api/auth/login`
* **Method**: `POST`
* **Access**: Public
* **Request Body** (JSON):
```json
{
  "email": "admin@servercloud.id",
  "password": "password123"
}
```
* **Success Response (200 OK)**:
```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "user": {
      "id": 1,
      "full_name": "Cloud Administrator",
      "email": "admin@servercloud.id",
      "role": "admin"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```
* **Error Response (401 Unauthorized)**:
```json
{
  "success": false,
  "message": "Kombinasi email atau password salah"
}
```

### 1.3 Ambil Profil User Aktif
* **URL**: `/api/auth/profile`
* **Method**: `GET`
* **Header**: `Authorization: Bearer <token>`
* **Success Response (200 OK)**:
```json
{
  "success": true,
  "message": "Profil pengguna berhasil diambil",
  "data": {
    "id": 1,
    "full_name": "Cloud Administrator",
    "email": "admin@servercloud.id",
    "role": "admin",
    "phone": "081234567890",
    "created_at": "2026-11-12T12:00:00.000Z"
  }
}
```

---

## 2. Kategori Layanan (`/api/categories`)

### 2.1 Ambil Semua Kategori
* **URL**: `/api/categories`
* **Method**: `GET`
* **Access**: Public / Authenticated
* **Success Response (200 OK)**:
```json
{
  "success": true,
  "message": "Berhasil mengambil daftar kategori layanan",
  "data": [
    {
      "id": 1,
      "name": "Cloud VPS NVMe",
      "slug": "cloud-vps-nvme",
      "description": "Server virtual performa tinggi NVMe SSD.",
      "total_packages": 2
    }
  ]
}
```

### 2.2 Tambah Kategori Baru
* **URL**: `/api/categories`
* **Method**: `POST`
* **Access**: **Admin Only** (`Authorization: Bearer <admin_token>`)
* **Request Body** (JSON):
```json
{
  "name": "Kubernetes Managed Cluster",
  "description": "Layanan orkestrasi container dengan high-availability."
}
```
* **Success Response (201 Created)**

### 2.3 Update & Hapus Kategori
* **PUT** `/api/categories/:id` (Admin Only, 200 OK)
* **DELETE** `/api/categories/:id` (Admin Only, 200 OK / 400 jika kategori memiliki paket)

---

## 3. Paket Server & Layanan Cloud (`/api/packages`)

### 3.1 Ambil Daftar Paket (Filter & Search)
* **URL**: `/api/packages`
* **Query Params**:
  * `category_id`: Filter ID kategori (misal: `?category_id=1`)
  * `search`: Pencarian nama atau deskripsi (misal: `?search=nvme`)
  * `sort`: `price_asc` (termurah) atau `price_desc` (termahal)
* **Success Response (200 OK)**:
```json
{
  "success": true,
  "message": "Berhasil mengambil daftar paket server",
  "total": 4,
  "data": [
    {
      "id": 1,
      "category_id": 1,
      "category_name": "Cloud VPS NVMe",
      "name": "VPS Starter NVMe 1G",
      "slug": "vps-starter-nvme-1g",
      "cpu_cores": 1,
      "ram_gb": 1,
      "storage_gb": 25,
      "bandwidth_tb": 1,
      "price_per_month": "85000.00",
      "stock_available": 15,
      "image_url": "https://...",
      "description": "Cocok untuk microservice dan staging."
    }
  ]
}
```

### 3.2 Detail Paket
* **URL**: `/api/packages/:id`
* **Method**: `GET`
* **Success Response (200 OK)**

### 3.3 Tambah Paket Server (Upload Gambar)
* **URL**: `/api/packages`
* **Method**: `POST`
* **Access**: **Admin Only**
* **Content-Type**: `multipart/form-data`
* **Form Fields**:
  * `category_id`: 1
  * `name`: VPS Business NVMe 8G
  * `cpu_cores`: 4
  * `ram_gb`: 8
  * `storage_gb`: 160
  * `bandwidth_tb`: 5
  * `price_per_month`: 450000
  * `stock_available`: 10
  * `description`: Cocok untuk backend production trafik tinggi.
  * `image`: [File Gambar JPG/PNG maks 2MB] *(Opsional jika ada image_url)*
* **Success Response (201 Created)**

### 3.4 Update & Hapus Paket
* **PUT** `/api/packages/:id` (Admin Only, Form-data / JSON)
* **DELETE** `/api/packages/:id` (Admin Only, 200 OK)
