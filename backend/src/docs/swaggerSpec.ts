export const swaggerSpec = {
  openapi: "3.0.3",
  info: {
    title: "ServerCloud REST API Documentation",
    version: "1.0.0",
    description:
      "Dokumentasi Resmi REST API ServerCloud — Platform Penyedia Layanan Cloud Hosting, Virtual Private Server (VPS), dan Dedicated Server Mandiri untuk UMKM.\n\n" +
      "**Pengembang:** Rafi Arrasyid (Kelas XI RPL 3 — SMK Taruna Bhakti)\n" +
      "**Database:** PostgreSQL 16 (Aiven Cloud + SSL Mode)\n" +
      "**Deployment:** Vercel Serverless Function\n\n" +
      "### Akun Pengujian Siap Pakai:\n" +
      "- **Admin:** `admin@servercloud.id` / `password123` (Hak akses penuh: CRUD paket, kategori, upload cover)\n" +
      "- **Client:** `client@servercloud.id` / `password123` (Hak akses: sewa server, simulasi bayar, riwayat pesanan, edit profil)",
    contact: {
      name: "Rafi Arrasyid (XI RPL 3)",
      url: "https://github.com/rafiarrasyid123/Tugas-as-umkm-vps-cloud",
    },
  },
  servers: [
    {
      url: "https://tugas-as-umkm-vps-cloud-8hk2.vercel.app",
      description: "Production Serverless (Vercel Live)",
    },
    {
      url: "http://localhost:5000",
      description: "Local Development Server",
    },
  ],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: "http",
        scheme: "bearer",
        bearerFormat: "JWT",
        description: "Masukkan token JWT yang didapat setelah login: `Bearer <token>`",
      },
    },
    schemas: {
      User: {
        type: "object",
        properties: {
          id: { type: "integer", example: 1 },
          full_name: { type: "string", example: "Rafi Arrasyid" },
          email: { type: "string", format: "email", example: "admin@servercloud.id" },
          role: { type: "string", enum: ["admin", "client"], example: "admin" },
          phone: { type: "string", example: "081234567890" },
          avatar_url: { type: "string", nullable: true, example: "https://res.cloudinary.com/.../avatar.jpg" },
          created_at: { type: "string", format: "date-time" },
        },
      },
      Category: {
        type: "object",
        properties: {
          id: { type: "integer", example: 1 },
          name: { type: "string", example: "Cloud VPS NVMe" },
          slug: { type: "string", example: "cloud-vps-nvme" },
          description: { type: "string", example: "Server virtual performa tinggi dengan storage NVMe SSD." },
          created_at: { type: "string", format: "date-time" },
        },
      },
      ServerPackage: {
        type: "object",
        properties: {
          id: { type: "integer", example: 1 },
          category_id: { type: "integer", example: 1 },
          category_name: { type: "string", example: "Cloud VPS NVMe" },
          name: { type: "string", example: "VPS Starter NVMe 1G" },
          slug: { type: "string", example: "vps-starter-nvme-1g" },
          cpu_cores: { type: "integer", example: 1 },
          ram_gb: { type: "integer", example: 1 },
          storage_gb: { type: "integer", example: 25 },
          bandwidth_tb: { type: "integer", example: 1 },
          price_per_month: { type: "number", example: 85000 },
          stock_available: { type: "integer", example: 15 },
          image_url: { type: "string", example: "https://images.unsplash.com/..." },
          description: { type: "string", example: "Cocok untuk microservice dan staging environment." },
          created_by: { type: "integer", example: 1 },
          created_at: { type: "string", format: "date-time" },
          updated_at: { type: "string", format: "date-time" },
        },
      },
      Order: {
        type: "object",
        properties: {
          id: { type: "integer", example: 1 },
          order_number: { type: "string", example: "SC-INV-20261118-4405" },
          user_id: { type: "integer", example: 2 },
          package_id: { type: "integer", example: 1 },
          duration_months: { type: "integer", example: 1 },
          total_price: { type: "number", example: 85000 },
          status: { type: "string", enum: ["pending", "active", "cancelled"], example: "active" },
          payment_method: { type: "string", example: "bca_va" },
          payment_code: { type: "string", example: "880192837465" },
          server_ip: { type: "string", example: "103.187.33.14" },
          created_at: { type: "string", format: "date-time" },
          paid_at: { type: "string", format: "date-time", nullable: true },
        },
      },
      ApiResponse: {
        type: "object",
        properties: {
          success: { type: "boolean", example: true },
          message: { type: "string", example: "Operasi berhasil" },
          data: { type: "object" },
        },
      },
    },
  },
  paths: {
    "/": {
      get: {
        summary: "Health Check API",
        description: "Memeriksa status operasional REST API ServerCloud.",
        tags: ["System"],
        responses: {
          200: {
            description: "Server API sedang berjalan normal.",
          },
        },
      },
    },
    "/api/auth/register": {
      post: {
        summary: "Registrasi Pengguna Baru",
        description: "Mendaftarkan akun baru pelanggan (Client). Password otomatis di-hash menggunakan Bcrypt.",
        tags: ["Autentikasi & Akun"],
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                required: ["full_name", "email", "password"],
                properties: {
                  full_name: { type: "string", example: "Budi Santoso" },
                  email: { type: "string", format: "email", example: "budi@umkm.id" },
                  password: { type: "string", format: "password", example: "Client123!" },
                  phone: { type: "string", example: "081298765432" },
                },
              },
            },
          },
        },
        responses: {
          201: { description: "Registrasi berhasil." },
          400: { description: "Validasi gagal (Zod error)." },
          409: { description: "Email sudah terdaftar." },
        },
      },
    },
    "/api/auth/login": {
      post: {
        summary: "Login Pengguna",
        description: "Otentikasi dengan email & password untuk mendapatkan JSON Web Token (JWT).",
        tags: ["Autentikasi & Akun"],
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                required: ["email", "password"],
                properties: {
                  email: { type: "string", example: "admin@servercloud.id" },
                  password: { type: "string", example: "password123" },
                },
              },
            },
          },
        },
        responses: {
          200: { description: "Login berhasil, mengembalikan token JWT." },
          401: { description: "Email atau password salah." },
        },
      },
    },
    "/api/auth/profile": {
      get: {
        summary: "Ambil Profil Pengguna Aktif",
        description: "Mengambil data identitas pengguna yang sedang login berdasarkan token JWT.",
        tags: ["Autentikasi & Akun"],
        security: [{ bearerAuth: [] }],
        responses: {
          200: { description: "Data profil berhasil diambil." },
          401: { description: "Token tidak valid atau tidak disertakan." },
        },
      },
      put: {
        summary: "Perbarui Profil & Upload Avatar",
        description: "Mengubah nama lengkap, nomor telepon, dan upload foto profil ke Cloudinary CDN.",
        tags: ["Autentikasi & Akun"],
        security: [{ bearerAuth: [] }],
        requestBody: {
          content: {
            "multipart/form-data": {
              schema: {
                type: "object",
                properties: {
                  full_name: { type: "string", example: "Rafi Arrasyid XI RPL 3" },
                  phone: { type: "string", example: "081299887766" },
                  avatar: { type: "string", format: "binary", description: "File foto profil (JPG/PNG max 2MB)" },
                },
              },
            },
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  full_name: { type: "string", example: "Rafi Arrasyid XI RPL 3" },
                  phone: { type: "string", example: "081299887766" },
                },
              },
            },
          },
        },
        responses: {
          200: { description: "Profil berhasil diperbarui." },
          401: { description: "Unauthorized." },
        },
      },
    },
    "/api/categories": {
      get: {
        summary: "Daftar Semua Kategori Layanan",
        description: "Mengambil seluruh kategori layanan cloud (Cloud VPS, Shared Hosting, Dedicated Server).",
        tags: ["Kategori Layanan"],
        responses: {
          200: { description: "Daftar kategori berhasil diambil." },
        },
      },
      post: {
        summary: "Tambah Kategori Baru (Admin Only)",
        description: "Menambahkan kategori layanan baru. Hanya bisa diakses oleh role Admin.",
        tags: ["Kategori Layanan"],
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                required: ["name"],
                properties: {
                  name: { type: "string", example: "Bare Metal Server" },
                  description: { type: "string", example: "Server fisik mandiri komputasi intensif." },
                },
              },
            },
          },
        },
        responses: {
          201: { description: "Kategori baru berhasil dibuat." },
          401: { description: "Unauthorized." },
          403: { description: "Forbidden (Bukan admin)." },
        },
      },
    },
    "/api/categories/{id}": {
      get: {
        summary: "Detail Kategori Berdasarkan ID",
        description: "Mengambil data kategori beserta paket-paket server di bawahnya.",
        tags: ["Kategori Layanan"],
        parameters: [
          { name: "id", in: "path", required: true, schema: { type: "integer" }, example: 1 },
        ],
        responses: {
          200: { description: "Data kategori ditemukan." },
          404: { description: "Kategori tidak ditemukan." },
        },
      },
      put: {
        summary: "Update Kategori (Admin Only)",
        description: "Memperbarui nama dan deskripsi kategori layanan.",
        tags: ["Kategori Layanan"],
        security: [{ bearerAuth: [] }],
        parameters: [
          { name: "id", in: "path", required: true, schema: { type: "integer" }, example: 1 },
        ],
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  name: { type: "string", example: "Cloud VPS High Performance" },
                  description: { type: "string", example: "Deskripsi kategori terupdate." },
                },
              },
            },
          },
        },
        responses: {
          200: { description: "Kategori berhasil diperbarui." },
          403: { description: "Forbidden." },
          404: { description: "Kategori tidak ditemukan." },
        },
      },
      delete: {
        summary: "Hapus Kategori (Admin Only)",
        description: "Menghapus kategori layanan (dibatasi jika masih ada paket terkait).",
        tags: ["Kategori Layanan"],
        security: [{ bearerAuth: [] }],
        parameters: [
          { name: "id", in: "path", required: true, schema: { type: "integer" }, example: 1 },
        ],
        responses: {
          200: { description: "Kategori berhasil dihapus." },
          400: { description: "Gagal: Masih terdapat paket yang menggunakan kategori ini." },
          403: { description: "Forbidden." },
        },
      },
    },
    "/api/packages": {
      get: {
        summary: "Katalog Paket Server (Filter & Search)",
        description: "Mengambil daftar paket hosting/VPS dengan query pencarian keyword dan filter kategori.",
        tags: ["Paket Server Cloud"],
        parameters: [
          { name: "category_id", in: "query", schema: { type: "integer" }, description: "Filter ID Kategori" },
          { name: "search", in: "query", schema: { type: "string" }, description: "Keyword pencarian nama paket" },
          { name: "sort", in: "query", schema: { type: "string", enum: ["price_asc", "price_desc", "newest"] }, description: "Urutan harga/waktu" },
        ],
        responses: {
          200: { description: "Katalog paket server berhasil diambil." },
        },
      },
      post: {
        summary: "Tambah Paket Server Baru (Admin Only)",
        description: "Membuat paket server baru dengan spesifikasi teknis dan upload gambar banner/cover ke Cloudinary CDN.",
        tags: ["Paket Server Cloud"],
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            "multipart/form-data": {
              schema: {
                type: "object",
                required: ["category_id", "name", "price_per_month"],
                properties: {
                  category_id: { type: "integer", example: 1 },
                  name: { type: "string", example: "VPS UMKM Super Fast" },
                  cpu_cores: { type: "integer", example: 4 },
                  ram_gb: { type: "integer", example: 8 },
                  storage_gb: { type: "integer", example: 120 },
                  bandwidth_tb: { type: "integer", example: 5 },
                  price_per_month: { type: "number", example: 350000 },
                  stock_available: { type: "integer", example: 10 },
                  description: { type: "string", example: "Dedicated resource untuk toko online UMKM ramai pengunjung." },
                  image: { type: "string", format: "binary", description: "Foto banner paket (JPG/PNG max 2MB)" },
                },
              },
            },
          },
        },
        responses: {
          201: { description: "Paket server berhasil dibuat." },
          403: { description: "Forbidden (Bukan admin)." },
        },
      },
    },
    "/api/packages/{id}": {
      get: {
        summary: "Detail Spesifikasi Paket Server",
        description: "Mengambil detail lengkap paket server berdasarkan ID.",
        tags: ["Paket Server Cloud"],
        parameters: [
          { name: "id", in: "path", required: true, schema: { type: "integer" }, example: 1 },
        ],
        responses: {
          200: { description: "Detail paket server berhasil diambil." },
          404: { description: "Paket tidak ditemukan." },
        },
      },
      put: {
        summary: "Update Paket Server (Admin Only)",
        description: "Mengubah spesifikasi teknis, harga sewa, stok, atau gambar cover paket server.",
        tags: ["Paket Server Cloud"],
        security: [{ bearerAuth: [] }],
        parameters: [
          { name: "id", in: "path", required: true, schema: { type: "integer" }, example: 1 },
        ],
        requestBody: {
          content: {
            "multipart/form-data": {
              schema: {
                type: "object",
                properties: {
                  name: { type: "string", example: "VPS Starter NVMe 1G Updated" },
                  price_per_month: { type: "number", example: 90000 },
                  stock_available: { type: "integer", example: 20 },
                  image: { type: "string", format: "binary" },
                },
              },
            },
          },
        },
        responses: {
          200: { description: "Paket berhasil diperbarui." },
          403: { description: "Forbidden." },
        },
      },
      delete: {
        summary: "Hapus Paket Server (Admin Only)",
        description: "Menghapus paket server dari katalog aplikasi.",
        tags: ["Paket Server Cloud"],
        security: [{ bearerAuth: [] }],
        parameters: [
          { name: "id", in: "path", required: true, schema: { type: "integer" }, example: 1 },
        ],
        responses: {
          200: { description: "Paket server berhasil dihapus." },
          403: { description: "Forbidden." },
        },
      },
    },
    "/api/orders": {
      get: {
        summary: "Daftar Semua Pesanan (Admin Only)",
        description: "Melihat seluruh transaksi penyewaan server pelanggan masuk.",
        tags: ["Transaksi & Sewa Server"],
        security: [{ bearerAuth: [] }],
        responses: {
          200: { description: "Seluruh transaksi sewa berhasil diambil." },
          403: { description: "Forbidden." },
        },
      },
      post: {
        summary: "Checkout / Sewa Paket Server (Client)",
        description: "Melakukan sewa server baru. Otomatis menerbitkan nomor invoice unik `SC-INV-YYYYMMDD-XXXX` dan mengurangi stok server.",
        tags: ["Transaksi & Sewa Server"],
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                required: ["package_id", "duration_months"],
                properties: {
                  package_id: { type: "integer", example: 1 },
                  duration_months: { type: "integer", enum: [1, 3, 12], example: 1 },
                  payment_method: { type: "string", enum: ["bca_va", "mandiri_va", "qris"], example: "bca_va" },
                },
              },
            },
          },
        },
        responses: {
          201: { description: "Pesanan sewa berhasil dibuat dengan status `pending`." },
          400: { description: "Stok habis atau durasi tidak valid." },
        },
      },
    },
    "/api/orders/my-orders": {
      get: {
        summary: "Riwayat Sewa Server Saya (Client)",
        description: "Mengambil daftar seluruh server dan transaksi sewa milik akun pelanggan yang sedang login.",
        tags: ["Transaksi & Sewa Server"],
        security: [{ bearerAuth: [] }],
        responses: {
          200: { description: "Daftar riwayat sewa berhasil diambil." },
        },
      },
    },
    "/api/orders/{id}": {
      get: {
        summary: "Detail Tagihan / Invoice Pesanan",
        description: "Mengambil informasi detail pesanan sewa, nomor VA pembayaran, dan status server.",
        tags: ["Transaksi & Sewa Server"],
        security: [{ bearerAuth: [] }],
        parameters: [
          { name: "id", in: "path", required: true, schema: { type: "integer" }, example: 1 },
        ],
        responses: {
          200: { description: "Detail invoice pesanan ditemukan." },
          404: { description: "Pesanan tidak ditemukan." },
        },
      },
    },
    "/api/orders/{id}/pay": {
      patch: {
        summary: "Simulasi Pembayaran Tagihan Sewa",
        description: "Mengubah status pesanan dari `pending` menjadi `active`, mencatat waktu bayar, dan mengalokasikan IP publik server virtual (`103.187.xx.xx`).",
        tags: ["Transaksi & Sewa Server"],
        security: [{ bearerAuth: [] }],
        parameters: [
          { name: "id", in: "path", required: true, schema: { type: "integer" }, example: 1 },
        ],
        responses: {
          200: { description: "Pembayaran berhasil, server aktif dengan IP publik teralokasi." },
          400: { description: "Pesanan sudah pernah dibayar." },
        },
      },
    },
  },
};
