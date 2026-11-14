import fs from "fs";
import path from "path";
import {
  Document,
  Packer,
  Paragraph,
  TextRun,
  HeadingLevel,
  Table,
  TableRow,
  TableCell,
  WidthType,
  AlignmentType,
  ShadingType,
} from "docx";

function createHeaderCell(text: string, widthPercent: number): TableCell {
  return new TableCell({
    width: { size: widthPercent, type: WidthType.PERCENTAGE },
    shading: { fill: "1E293B", type: ShadingType.CLEAR },
    margins: { top: 120, bottom: 120, left: 140, right: 140 },
    children: [
      new Paragraph({
        children: [
          new TextRun({
            text,
            bold: true,
            color: "FFFFFF",
            size: 20,
            font: "Calibri",
          }),
        ],
      }),
    ],
  });
}

function createCell(text: string, widthPercent: number, isAlt: boolean = false): TableCell {
  return new TableCell({
    width: { size: widthPercent, type: WidthType.PERCENTAGE },
    shading: isAlt ? { fill: "F8FAFC", type: ShadingType.CLEAR } : undefined,
    margins: { top: 100, bottom: 100, left: 140, right: 140 },
    children: [
      new Paragraph({
        children: [
          new TextRun({
            text,
            size: 19,
            font: "Calibri",
          }),
        ],
      }),
    ],
  });
}

function p(text: string, options: { bold?: boolean; size?: number; color?: string; align?: AlignmentType; spacingAfter?: number } = {}): Paragraph {
  return new Paragraph({
    alignment: options.align ?? AlignmentType.LEFT,
    spacing: { after: options.spacingAfter ?? 120 },
    children: [
      new TextRun({
        text,
        bold: options.bold ?? false,
        size: options.size ?? 22,
        color: options.color ?? "1E293B",
        font: "Calibri",
      }),
    ],
  });
}

function h1(text: string): Paragraph {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    spacing: { before: 280, after: 140 },
    children: [
      new TextRun({
        text,
        bold: true,
        size: 30,
        color: "0F172A",
        font: "Calibri",
      }),
    ],
  });
}

function h2(text: string): Paragraph {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    spacing: { before: 200, after: 100 },
    children: [
      new TextRun({
        text,
        bold: true,
        size: 25,
        color: "334155",
        font: "Calibri",
      }),
    ],
  });
}

function h3(text: string): Paragraph {
  return new Paragraph({
    heading: HeadingLevel.HEADING_3,
    spacing: { before: 160, after: 80 },
    children: [
      new TextRun({
        text,
        bold: true,
        size: 22,
        color: "475569",
        font: "Calibri",
      }),
    ],
  });
}

async function buildDocx() {
  const doc = new Document({
    sections: [
      {
        properties: {},
        children: [
          // JUDUL DOKUMEN & COVER
          p("UJI LEVEL KOMPETENSI KEAHLIAN REKAYASA PERANGKAT LUNAK", { bold: true, size: 28, align: AlignmentType.CENTER, spacingAfter: 60 }),
          p("TAHUN PELAJARAN 2026/2027 — SMK TARUNA BHAKTI", { bold: true, size: 22, color: "64748B", align: AlignmentType.CENTER, spacingAfter: 200 }),
          
          p("DOKUMEN SOFTWARE REQUIREMENTS SPECIFICATION (SRS)", { bold: true, size: 36, color: "1E40AF", align: AlignmentType.CENTER, spacingAfter: 100 }),
          p("SISTEM LAYANAN CLOUD HOSTING & VPS MANDIRI UNTUK UMKM (SERVERCLOUD)", { bold: true, size: 24, align: AlignmentType.CENTER, spacingAfter: 260 }),

          // IDENTITAS PENILAIAN
          new Table({
            width: { size: 100, type: WidthType.PERCENTAGE },
            rows: [
              new TableRow({
                children: [
                  createHeaderCell("IDENTITAS PENYUSUN", 35),
                  createHeaderCell("KETERANGAN PESERTA UJI LEVEL", 65),
                ],
              }),
              new TableRow({
                children: [
                  createCell("Nama Lengkap", 35),
                  createCell("Rafi Arrasyid", 65),
                ],
              }),
              new TableRow({
                children: [
                  createCell("NISN", 35, true),
                  createCell("0095484729", 65, true),
                ],
              }),
              new TableRow({
                children: [
                  createCell("Kelas / Kompetensi", 35),
                  createCell("XI RPL 3 / Rekayasa Perangkat Lunak", 65),
                ],
              }),
              new TableRow({
                children: [
                  createCell("Satuan Pendidikan", 35, true),
                  createCell("SMK Taruna Bhakti", 65, true),
                ],
              }),
              new TableRow({
                children: [
                  createCell("Level / Alokasi Waktu", 35),
                  createCell("Medium / 4 Jam (Individu)", 65),
                ],
              }),
              new TableRow({
                children: [
                  createCell("Tautan Repositori GitHub", 35, true),
                  createCell("https://github.com/rafiarrasyid123/Tugas-as-umkm-vps-cloud.git", 65, true),
                ],
              }),
              new TableRow({
                children: [
                  createCell("Branching Repositori", 35),
                  createCell("main (Production), backend (REST API), mobile (Flutter App)", 65),
                ],
              }),
              new TableRow({
                children: [
                  createCell("URL Deployment Live Vercel", 35, true),
                  createCell("https://tugas-as-umkm-vps-cloud-8hk2.vercel.app", 65, true),
                ],
              }),
              new TableRow({
                children: [
                  createCell("Database Cloud Host", 35),
                  createCell("Aiven Cloud PostgreSQL (raffznyaauwia-raffznyaekin.g.aivencloud.com:10266)", 65),
                ],
              }),
            ],
          }),

          p("", { spacingAfter: 260 }),

          // BAB I PENDAHULUAN
          h1("BAB I PENDAHULUAN"),
          h2("1.1 Latar Belakang"),
          p("Di era transformasi digital saat ini, Usaha Mikro, Kecil, dan Menengah (UMKM) dituntut untuk memiliki kehadiran daring (online presence) yang andal, mulai dari website profil, platform toko online, hingga aplikasi operasional berbasis web. Namun, sebagian besar pelaku UMKM di Indonesia menghadapi kendala tingginya biaya berlangganan infrastruktur cloud internasional (seperti AWS, Microsoft Azure, atau Google Cloud) yang menggunakan mata uang asing serta skema penagihan variabel yang rumit."),
          p("Untuk menjawab tantangan tersebut, hadir pelaku UMKM di sektor Jasa Teknologi Informasi yang menyediakan layanan Cloud Hosting, Virtual Private Server (VPS), dan Dedicated Server berskala lokal dengan harga terjangkau dalam mata uang Rupiah. Guna mendukung operasional penyedia jasa infrastruktur digital ini, dibangun sistem terintegrasi bernama ServerCloud yang menghubungkan pengelolaan katalog paket server, pemesanan sewa, penerbitan invoice otomatis, hingga simulasi aktivasi node server."),

          h2("1.2 Rumusan Masalah"),
          p("1. Bagaimana merancang arsitektur sistem informasi katalog dan manajemen layanan cloud/VPS yang terstruktur dan aman untuk UMKM?"),
          p("2. Bagaimana membangun REST API berbasis Node.js Express dan TypeScript dengan validasi data Zod serta otorisasi berbasis peran (Role-Based Access Control)?"),
          p("3. Bagaimana mengelola penyimpanan basis data relasional di cloud Aiven PostgreSQL serta mengintegrasikan penyimpanan banner arsitektur ke Cloudinary?"),
          p("4. Bagaimana merancang aplikasi client mobile (Flutter) dengan gaya desain Neo-Brutalism yang memudahkan pelanggan dalam menjelajahi spesifikasi server dan melakukan sewa mandiri?"),

          h2("1.3 Tujuan Penulisan Dokumen"),
          p("1. Mendefinisikan kebutuhan fungsional dan non-fungsional dari sistem ServerCloud secara komprehensif."),
          p("2. Menjadi acuan teknis dalam tahap perancangan basis data relasional (ERD), diagram alir (UML Use Case, Activity, Class), dan implementasi kode sumber."),
          p("3. Menjadi panduan pengujian mutu perangkat lunak (Quality Assurance) menggunakan metode Blackbox Testing."),
          p("4. Memenuhi seluruh rubrik penilaian Uji Level Kompetensi Keahlian Rekayasa Perangkat Lunak SMK Taruna Bhakti TP 2026/2027."),

          // BAB II METODE PENGEMBANGAN
          h1("BAB II METODE PENGEMBANGAN SISTEM"),
          h2("2.1 Metode Pengembangan (Model SDLC Waterfall)"),
          p("Pengembangan sistem ServerCloud mengadopsi model Software Development Life Cycle (SDLC) Waterfall klasik yang terdiri dari 5 tahapan berurutan dan terstruktur:"),
          p("1. Requirement Analysis: Mengumpulkan seluruh kebutuhan fungsional penyedia layanan (Admin) dan pelanggan UMKM (Client)."),
          p("2. System Design: Merancang pemodelan data relasional (ERD 4 tabel), use case diagram, activity diagram, class diagram, arsitektur REST API, dan antarmuka UI Flutter Neo-Brutalism."),
          p("3. Implementation: Pengkodean backend (Node.js, Express, TypeScript, Aiven PostgreSQL) dan client mobile (Flutter Dart)."),
          p("4. Testing: Pengujian fungsionalitas menggunakan metode Blackbox Testing serta validasi API."),
          p("5. Deployment & Maintenance: Publikasi backend ke platform serverless Vercel dan database cloud ke Aiven PostgreSQL."),

          h2("2.2 Jadwal Pengembangan Sistem (Timeline / Gantt Chart)"),
          new Table({
            width: { size: 100, type: WidthType.PERCENTAGE },
            rows: [
              new TableRow({
                children: [
                  createHeaderCell("TAHAPAN PROYEK", 50),
                  createHeaderCell("ALOKASI WAKTU", 25),
                  createHeaderCell("STATUS CAPAIAN", 25),
                ],
              }),
              new TableRow({
                children: [
                  createCell("1. Analisis Kebutuhan & Dokumen SRS", 50),
                  createCell("Hari ke-1", 25),
                  createCell("SELESAI (100%)", 25),
                ],
              }),
              new TableRow({
                children: [
                  createCell("2. Perancangan Database ERD & DDL Migration Aiven", 50, true),
                  createCell("Hari ke-1 s/d 2", 25, true),
                  createCell("SELESAI (100%)", 25, true),
                ],
              }),
              new TableRow({
                children: [
                  createCell("3. Implementasi Backend REST API, Zod, JWT", 50),
                  createCell("Hari ke-2", 25),
                  createCell("SELESAI (100%)", 25),
                ],
              }),
              new TableRow({
                children: [
                  createCell("4. Integrasi Cloudinary & Deployment Live Vercel", 50, true),
                  createCell("Hari ke-2 s/d 3", 25, true),
                  createCell("SELESAI (100%)", 25, true),
                ],
              }),
              new TableRow({
                children: [
                  createCell("5. Implementasi Flutter Mobile (Auth, Neo-Brutalism, Katalog)", 50),
                  createCell("Hari ke-3", 25),
                  createCell("SELESAI (100%)", 25),
                ],
              }),
              new TableRow({
                children: [
                  createCell("6. Fitur Order Sewa, Invoicing, & Simulasi Bayar", 50, true),
                  createCell("Hari ke-4", 25, true),
                  createCell("SELESAI (100%)", 25, true),
                ],
              }),
              new TableRow({
                children: [
                  createCell("7. Blackbox Testing & Finalisasi Dokumen Uji Level", 50),
                  createCell("Hari ke-4", 25),
                  createCell("SELESAI (100%)", 25),
                ],
              }),
            ],
          }),

          p("", { spacingAfter: 200 }),

          // BAB III ANALISIS KEBUTUHAN SISTEM
          h1("BAB III ANALISIS KEBUTUHAN SISTEM"),
          h2("3.1 Nama Sistem"),
          p("ServerCloud — Platform Layanan Cloud Hosting, Virtual Private Server (VPS), dan Dedicated Server Mandiri untuk UMKM."),

          h2("3.2 Ruang Lingkup"),
          p("• Deskripsi Sistem: Sistem perangkat lunak terintegrasi yang terdiri dari Backend REST API dan antarmuka client mobile Flutter untuk memfasilitasi katalogisasi, pencarian, dan pemesanan layanan infrastruktur server."),
          p("• Manfaat Bagi Administrator: Pengelolaan kategori layanan, pembaharuan stok unit server, input foto banner spesifikasi hardware, dan pemantauan transaksi pelanggan."),
          p("• Manfaat Bagi Pelanggan (Client): Kemudahan membandingkan spesifikasi komputer server (vCPU, RAM, SSD NVMe, Bandwidth) dalam mata uang Rupiah, sewa fleksibel bulanan, dan aktivasi server mandiri."),

          h2("3.3 Kebutuhan Fungsional (Functional Requirements)"),
          h3("A. Karakteristik Pengguna (User Characteristics)"),
          p("1. Administrator: Memiliki pemahaman teknis spesifikasi server, bertugas memelihara katalog paket dan mengonfirmasi ketersediaan infrastruktur."),
          p("2. Client: Pelaku UMKM atau pengembang web yang membutuhkan hosting atau server dengan antarmuka yang ramah dan transaksi yang transparan."),

          h3("B. Tabel Kebutuhan Fungsional"),
          new Table({
            width: { size: 100, type: WidthType.PERCENTAGE },
            rows: [
              new TableRow({
                children: [
                  createHeaderCell("KODE", 15),
                  createHeaderCell("MODUL", 25),
                  createHeaderCell("DESKRIPSI KEBUTUHAN FUNGSIONAL", 60),
                ],
              }),
              new TableRow({
                children: [
                  createCell("FR-01", 15),
                  createCell("Autentikasi", 25),
                  createCell("Pengguna dapat mendaftar akun baru dengan otomatis memperoleh hak akses Client.", 60),
                ],
              }),
              new TableRow({
                children: [
                  createCell("FR-02", 15, true),
                  createCell("Autentikasi", 25, true),
                  createCell("Pengguna dapat login dan memperoleh token otorisasi JWT (masa aktif 24 jam).", 60, true),
                ],
              }),
              new TableRow({
                children: [
                  createCell("FR-03", 15),
                  createCell("Keamanan", 25),
                  createCell("Sistem mengenkripsi kata sandi menggunakan bcrypt sebelum disimpan ke database.", 60),
                ],
              }),
              new TableRow({
                children: [
                  createCell("FR-04", 15, true),
                  createCell("Kategori", 25, true),
                  createCell("Pengguna dapat melihat daftar kategori layanan cloud (VPS NVMe, Shared, Dedicated).", 60, true),
                ],
              }),
              new TableRow({
                children: [
                  createCell("FR-05", 15),
                  createCell("Kategori", 25),
                  createCell("Admin dapat menambah, mengedit, dan menghapus kategori (dilindungi relasi RESTRICT).", 60),
                ],
              }),
              new TableRow({
                children: [
                  createCell("FR-06", 15, true),
                  createCell("Paket Server", 25, true),
                  createCell("Pengguna dapat melihat katalog paket server dengan filter kategori dan pencarian live.", 60, true),
                ],
              }),
              new TableRow({
                children: [
                  createCell("FR-07", 15),
                  createCell("Paket Server", 25),
                  createCell("Admin dapat membuat paket baru dengan spesifikasi vCPU, RAM, SSD NVMe, Bandwidth, Stok, dan Harga.", 60),
                ],
              }),
              new TableRow({
                children: [
                  createCell("FR-08", 15, true),
                  createCell("Paket Server", 25, true),
                  createCell("Admin dapat mengunggah file foto banner spesifikasi via kamera/galeri HP ke Cloudinary.", 60, true),
                ],
              }),
              new TableRow({
                children: [
                  createCell("FR-09", 15),
                  createCell("Transaksi", 25),
                  createCell("Client dapat memilih durasi sewa (1, 3, 12 bulan) dan metode bayar Virtual Account / QRIS.", 60),
                ],
              }),
              new TableRow({
                children: [
                  createCell("FR-10", 15, true),
                  createCell("Transaksi", 25, true),
                  createCell("Sistem menerbitkan invoice unik (SC-INV-YYYYMMDD-XXXX) dan memotong stok paket 1 unit.", 60, true),
                ],
              }),
              new TableRow({
                children: [
                  createCell("FR-11", 15),
                  createCell("Transaksi", 25),
                  createCell("Client dapat melakukan simulasi bayar instan -> status menjadi ACTIVE & terbit alokasi IP publik.", 60),
                ],
              }),
              new TableRow({
                children: [
                  createCell("FR-12", 15, true),
                  createCell("Transaksi", 25, true),
                  createCell("Admin dapat memantau seluruh riwayat transaksi sewa masuk dari semua pelanggan UMKM.", 60, true),
                ],
              }),
            ],
          }),

          p("", { spacingAfter: 160 }),

          h3("C. Kamus Data (Data Dictionary)"),
          p("• users: id, full_name, email, password, role ('admin'/'client'), phone, created_at."),
          p("• service_categories: id, name, slug, description, created_at."),
          p("• server_packages: id, category_id, name, slug, cpu_cores, ram_gb, storage_gb, bandwidth_tb, price_per_month, stock_available, image_url, description, created_by, created_at, updated_at."),
          p("• orders: id, order_number, user_id, package_id, duration_months, total_price, status ('pending'/'active'/'cancelled'), payment_method, payment_code, server_ip, created_at, paid_at."),

          h3("D. Alur Bisnis Transaksi"),
          p("1. Pelanggan memilih spesifikasi paket server dari katalog aplikasi mobile."),
          p("2. Pelanggan memilih durasi sewa (1, 3, atau 12 bulan) dan bank Virtual Account."),
          p("3. Sistem mencatat order status 'pending', memotong stok 1 unit, dan menerbitkan invoice resmi."),
          p("4. Pelanggan melakukan pembayaran simulasi -> status order beralih menjadi 'active'."),
          p("5. Sistem mengalokasikan IP Address node server dan menampilkan kredensial akses SSH root."),

          h2("3.4 Kebutuhan Non-Fungsional (Non-Functional Requirements)"),
          p("• Kebutuhan Produk (Product): Kecepatan respon API di bawah 250 ms, respon JSON konsisten, format sandi aman bcrypt."),
          p("• Kebutuhan Organisasi: Kode sumber TypeScript modular, version control Git branching rapi (main, backend, mobile)."),
          p("• Kebutuhan Eksternal: Host database PostgreSQL di Aiven bersertifikasi SSL, deployment backend di Vercel Edge Network."),

          h2("3.5 Batasan Sistem (System Constraints)"),
          p("• Backend dibangun menggunakan Node.js (v20+) dan Express.js dalam bahasa TypeScript."),
          p("• Basis data relasional wajib menggunakan PostgreSQL di cloud Aiven."),
          p("• Client mobile dibangun menggunakan framework Google Flutter dengan desain Neo-Brutalism."),
          p("• Pembayaran menggunakan sistem invoice mandiri tanpa gateway pihak ketiga berbayar."),

          // BAB IV DEVELOPMENT
          h1("BAB IV DEVELOPMENT"),
          h2("4.1 Desain Sistem (UML)"),
          h3("A. Diagram Use Case"),
          p("Aktor Admin dan Client memiliki interaksi berikut:"),
          p("• Client: Registrasi Akun, Login, Lihat Katalog & Filter Spek Server, Buat Order Sewa, Simulasi Bayar, Lihat Node Server Aktif."),
          p("• Admin: Login, Kelola Kategori Layanan (CRUD), Kelola Paket Server (CRUD), Upload Foto Banner, Monitoring Seluruh Transaksi."),

          h3("B. Diagram Activity (Alur Tambah Paket Server)"),
          p("Mulai -> Admin mengirim request dengan Token JWT -> Validasi Token & Role Admin -> Pemeriksaan Unggahan Foto (<= 2MB) -> Upload ke Cloudinary -> Validasi Skema Zod Body -> Simpan ke Database Aiven PostgreSQL -> Respon HTTP 201 Created -> Selesai."),

          h3("C. Diagram Class"),
          p("Terdiri dari 4 kelas entitas utama: User, ServiceCategory, ServerPackage, dan Order yang saling berelasi melalui agregasi dan asosiasi relasional."),

          h2("4.2 Perancangan Basis Data (ERD & Table Schema)"),
          h3("A. Entity Relationship Diagram (ERD)"),
          p("Relasi antar tabel dalam basis data:"),
          p("• users (1) ke server_packages (N): Admin membuat banyak paket server."),
          p("• service_categories (1) ke server_packages (N): Satu kategori menaungi banyak paket server (RESTRICT)."),
          p("• users (1) ke orders (N): Satu pelanggan dapat memiliki banyak transaksi sewa (CASCADE)."),
          p("• server_packages (1) ke orders (N): Satu paket server dapat dipesan dalam banyak transaksi sewa (RESTRICT)."),

          h3("B. Table Schema"),
          p("1. Tabel users: id (PK), full_name, email (UK), password (Bcrypt), role, phone, created_at."),
          p("2. Tabel service_categories: id (PK), name, slug (UK), description, created_at."),
          p("3. Tabel server_packages: id (PK), category_id (FK), name, slug (UK), cpu_cores, ram_gb, storage_gb, bandwidth_tb, price_per_month, stock_available, image_url, description, created_by (FK), created_at, updated_at."),
          p("4. Tabel orders: id (PK), order_number (UK), user_id (FK), package_id (FK), duration_months, total_price, status, payment_method, payment_code, server_ip, created_at, paid_at."),

          h2("4.3 Struktur Project"),
          p("• backend/: Folder backend Node.js Express TypeScript (config, controllers, middlewares, routes, validators, database)."),
          p("• mobile/: Folder aplikasi Flutter (lib/config, lib/models, lib/services, lib/screens, lib/widgets)."),
          p("• docs/: Folder dokumentasi teknis (SRS, ERD, API Specification)."),

          h2("4.4 Quality Assurance (Blackbox Testing)"),
          new Table({
            width: { size: 100, type: WidthType.PERCENTAGE },
            rows: [
              new TableRow({
                children: [
                  createHeaderCell("SKENARIO PENGUJIAN", 35),
                  createHeaderCell("INPUT DATA", 25),
                  createHeaderCell("HASIL YANG DIHARAPKAN", 25),
                  createHeaderCell("STATUS", 15),
                ],
              }),
              new TableRow({
                children: [
                  createCell("1. Registrasi Akun Publik", 35),
                  createCell("Nama, Email, Pass, Phone", 25),
                  createCell("Akun terdaftar dengan role 'client'", 25),
                  createCell("BERHASIL", 15),
                ],
              }),
              new TableRow({
                children: [
                  createCell("2. Login Kredensial Valid", 35, true),
                  createCell("admin@servercloud.id / password123", 25, true),
                  createCell("HTTP 200 OK & Token JWT terbit", 25, true),
                  createCell("BERHASIL", 15, true),
                ],
              }),
              new TableRow({
                children: [
                  createCell("3. Validasi Zod Password Pendek", 35),
                  createCell("password: '123'", 25),
                  createCell("HTTP 400 Bad Request 'Min 6 char'", 25),
                  createCell("BERHASIL", 15),
                ],
              }),
              new TableRow({
                children: [
                  createCell("4. Hak Akses Admin Guard", 35, true),
                  createCell("Client token akses POST /categories", 25, true),
                  createCell("HTTP 403 Forbidden Access", 25, true),
                  createCell("BERHASIL", 15, true),
                ],
              }),
              new TableRow({
                children: [
                  createCell("5. Filter & Pencarian Paket", 35),
                  createCell("?category_id=1&search=nvme", 25),
                  createCell("Menampilkan daftar paket yang cocok", 25),
                  createCell("BERHASIL", 15),
                ],
              }),
              new TableRow({
                children: [
                  createCell("6. Upload Gambar ke Cloudinary", 35, true),
                  createCell("Form-data file banner JPG", 25, true),
                  createCell("Image URL tersimpan di Cloudinary CDN", 25, true),
                  createCell("BERHASIL", 15, true),
                ],
              }),
              new TableRow({
                children: [
                  createCell("7. Pembuatan Order Sewa", 35),
                  createCell("package_id: 1, duration: 3 bulan", 25),
                  createCell("Invoice terbit, stok paket berkurang 1", 25),
                  createCell("BERHASIL", 15),
                ],
              }),
              new TableRow({
                children: [
                  createCell("8. Simulasi Pembayaran", 35, true),
                  createCell("PATCH /api/orders/:id/pay", 25, true),
                  createCell("Status order menjadi ACTIVE & terbit IP", 25, true),
                  createCell("BERHASIL", 15, true),
                ],
              }),
            ],
          }),

          p("", { spacingAfter: 200 }),

          h2("4.5 Dokumentasi Deployment Cloud"),
          p("1. Backend API Live:"),
          p("• Platform: Vercel Cloud Serverless Framework"),
          p("• Base URL: https://tugas-as-umkm-vps-cloud-8hk2.vercel.app"),
          p("• API Docs Interaktif: https://tugas-as-umkm-vps-cloud-8hk2.vercel.app/api/docs"),
          p("2. Database Cloud Live:"),
          p("• Platform: Aiven Cloud Managed Database"),
          p("• Engine: PostgreSQL 16 (SSL Enforced)"),
          p("• Host: raffznyaauwia-raffznyaekin.g.aivencloud.com:10266"),
          p("3. Media Storage:"),
          p("• Platform: Cloudinary Media Network (Cloud Name: jiorqfrg)"),

          // BAB V PENUTUP
          h1("BAB V PENUTUP"),
          h2("5.1 Kesimpulan"),
          p("Sistem ServerCloud telah berhasil dirancang, dibangun, dan diuji secara komprehensif untuk menjawab kebutuhan digitalisasi UMKM penyedia jasa infrastruktur cloud hosting dan VPS mandiri. Dengan mengombinasikan backend Node.js Express TypeScript, basis data PostgreSQL Aiven, penyimpanan gambar Cloudinary, serta antarmuka Flutter Neo-Brutalism, sistem ini menjamin stabilitas performa, keamanan otorisasi bertingkat, serta kemudahan transaksi pemesanan sewa server secara transparan."),

          h2("5.2 Lampiran"),
          p("• Repositori GitHub: https://github.com/rafiarrasyid123/Tugas-as-umkm-vps-cloud.git"),
          p("• Branch Aktif: main (Production Live), backend (REST API), mobile (Flutter App)"),
          p("• Dokumentasi API Interaktif: https://tugas-as-umkm-vps-cloud-8hk2.vercel.app/api/docs"),
        ],
      },
    ],
  });

  const buffer = await Packer.toBuffer(doc);
  const outPath = path.resolve(process.cwd(), "..", "Dokumen_SRS_ServerCloud_Rafi_Arrasyid_XI_RPL_3.docx");
  fs.writeFileSync(outPath, buffer);
  console.log("SUCCESS: Word SRS document re-generated at:", outPath);
}

buildDocx();
