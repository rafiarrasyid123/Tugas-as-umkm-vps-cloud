import "dotenv/config";

const BASE_URL = process.env.BASE_URL || "http://localhost:5000";

interface TestResult {
  name: string;
  passed: boolean;
  details?: string;
}

const results: TestResult[] = [];

const runTests = async () => {
  console.log("==================================================");
  console.log(`🧪 Memulai Otomatisasi Pengujian API ServerCloud`);
  console.log(`🌐 Target: ${BASE_URL}`);
  console.log("==================================================\n");

  let adminToken = "";
  let clientToken = "";
  let createdCategoryId = 0;
  let createdPackageId = 0;

  // 1. Health Check
  try {
    const res = await fetch(`${BASE_URL}/`);
    const data = await res.json();
    if (res.status === 200 && data.success) {
      results.push({ name: "1. Health Check Endpoint", passed: true });
      console.log("✅ 1. Health Check: OK");
    } else {
      results.push({ name: "1. Health Check Endpoint", passed: false, details: JSON.stringify(data) });
      console.log("❌ 1. Health Check: FAILED");
    }
  } catch (err: any) {
    results.push({ name: "1. Health Check Endpoint", passed: false, details: err.message });
    console.log("❌ 1. Health Check: Connection Error -", err.message);
  }

  // 2. Login Admin
  try {
    const res = await fetch(`${BASE_URL}/api/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email: "admin@servercloud.id",
        password: "password123",
      }),
    });
    const data = await res.json();
    if (res.status === 200 && data.data?.token) {
      adminToken = data.data.token;
      results.push({ name: "2. Login Admin (JWT Token)", passed: true });
      console.log("✅ 2. Login Admin: Berhasil memperoleh token JWT");
    } else {
      results.push({ name: "2. Login Admin", passed: false, details: data.message });
      console.log("❌ 2. Login Admin: Gagal -", data.message);
    }
  } catch (err: any) {
    results.push({ name: "2. Login Admin", passed: false, details: err.message });
  }

  // 3. Login Client
  try {
    const res = await fetch(`${BASE_URL}/api/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email: "client@servercloud.id",
        password: "password123",
      }),
    });
    const data = await res.json();
    if (res.status === 200 && data.data?.token) {
      clientToken = data.data.token;
      results.push({ name: "3. Login Client (Role Otorisasi)", passed: true });
      console.log("✅ 3. Login Client: Berhasil");
    } else {
      results.push({ name: "3. Login Client", passed: false, details: data.message });
      console.log("❌ 3. Login Client: Gagal -", data.message);
    }
  } catch (err: any) {
    results.push({ name: "3. Login Client", passed: false, details: err.message });
  }

  // 4. Uji Validasi Zod (Input Salah -> Ekspektasi 400 Bad Request)
  try {
    const res = await fetch(`${BASE_URL}/api/auth/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        full_name: "X",
        email: "bukan_email_valid",
        password: "123",
      }),
    });
    const data = await res.json();
    if (res.status === 400 && data.errors && data.errors.length > 0) {
      results.push({ name: "4. Zod Schema Validation (400 Bad Request)", passed: true });
      console.log("✅ 4. Validasi Zod: Berhasil menangkap error dan mengembalikan HTTP 400");
    } else {
      results.push({ name: "4. Zod Schema Validation", passed: false, details: JSON.stringify(data) });
      console.log("❌ 4. Validasi Zod: Gagal mengembalikan 400");
    }
  } catch (err: any) {
    results.push({ name: "4. Zod Schema Validation", passed: false, details: err.message });
  }

  // 5. Uji Proteksi Role (Client mencoba Tambah Kategori -> Ekspektasi 403 Forbidden)
  try {
    const res = await fetch(`${BASE_URL}/api/categories`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${clientToken}`,
      },
      body: JSON.stringify({
        name: "Kategori Terlarang",
      }),
    });
    const data = await res.json();
    if (res.status === 403) {
      results.push({ name: "5. Role Authorization Guard (403 Forbidden)", passed: true });
      console.log("✅ 5. Proteksi Role: Client berhasil diblokir dari endpoint Admin (HTTP 403)");
    } else {
      results.push({ name: "5. Role Authorization Guard", passed: false, details: JSON.stringify(data) });
      console.log("❌ 5. Proteksi Role: Gagal memblokir client (Status:", res.status, ")");
    }
  } catch (err: any) {
    results.push({ name: "5. Role Authorization Guard", passed: false, details: err.message });
  }

  // 6. Admin Tambah Kategori Baru (201 Created)
  try {
    const res = await fetch(`${BASE_URL}/api/categories`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${adminToken}`,
      },
      body: JSON.stringify({
        name: `High-Mem Database Node ${Date.now().toString().slice(-4)}`,
        description: "Optimasi untuk PostgreSQL dan Redis cache in-memory.",
      }),
    });
    const data = await res.json();
    if (res.status === 201 && data.data?.id) {
      createdCategoryId = data.data.id;
      results.push({ name: "6. Admin Tambah Kategori Baru (201 Created)", passed: true });
      console.log("✅ 6. Tambah Kategori: Berhasil ID =", createdCategoryId);
    } else {
      results.push({ name: "6. Admin Tambah Kategori", passed: false, details: JSON.stringify(data) });
      console.log("❌ 6. Tambah Kategori Gagal:", data.message);
    }
  } catch (err: any) {
    results.push({ name: "6. Admin Tambah Kategori", passed: false, details: err.message });
  }

  // 7. Admin Tambah Paket Server (201 Created)
  try {
    const res = await fetch(`${BASE_URL}/api/packages`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${adminToken}`,
      },
      body: JSON.stringify({
        category_id: createdCategoryId || 1,
        name: `Node Cloud Ultra ${Date.now().toString().slice(-4)}`,
        cpu_cores: 4,
        ram_gb: 8,
        storage_gb: 120,
        bandwidth_tb: 4,
        price_per_month: 380000,
        stock_available: 5,
        description: "Server kecepatan tinggi untuk pemrosesan AI dan analitik data.",
        image_url: "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=800&q=80",
      }),
    });
    const data = await res.json();
    if (res.status === 201 && data.data?.id) {
      createdPackageId = data.data.id;
      results.push({ name: "7. Admin Tambah Paket Server (201 Created)", passed: true });
      console.log("✅ 7. Tambah Paket Server: Berhasil ID =", createdPackageId);
    } else {
      results.push({ name: "7. Admin Tambah Paket Server", passed: false, details: JSON.stringify(data) });
      console.log("❌ 7. Tambah Paket Server Gagal:", data.message);
    }
  } catch (err: any) {
    results.push({ name: "7. Admin Tambah Paket Server", passed: false, details: err.message });
  }

  // 8. Ambil Paket dengan Filter & Search (200 OK)
  try {
    const res = await fetch(`${BASE_URL}/api/packages?search=Ultra`);
    const data = await res.json();
    if (res.status === 200 && Array.isArray(data.data)) {
      results.push({ name: "8. Ambil Data Paket + Search Filter (200 OK)", passed: true });
      console.log("✅ 8. Search & Filter Paket: Ditemukan", data.data.length, "paket");
    } else {
      results.push({ name: "8. Ambil Data Paket", passed: false, details: JSON.stringify(data) });
      console.log("❌ 8. Search & Filter Paket Gagal");
    }
  } catch (err: any) {
    results.push({ name: "8. Ambil Data Paket", passed: false, details: err.message });
  }

  // 9. Admin Hapus Paket Server (200 OK)
  if (createdPackageId) {
    try {
      const res = await fetch(`${BASE_URL}/api/packages/${createdPackageId}`, {
        method: "DELETE",
        headers: {
          Authorization: `Bearer ${adminToken}`,
        },
      });
      const data = await res.json();
      if (res.status === 200) {
        results.push({ name: "9. Admin Hapus Paket Server (200 OK)", passed: true });
        console.log("✅ 9. Hapus Paket Server: Berhasil");
      } else {
        results.push({ name: "9. Admin Hapus Paket Server", passed: false, details: JSON.stringify(data) });
        console.log("❌ 9. Hapus Paket Server Gagal");
      }
    } catch (err: any) {
      results.push({ name: "9. Admin Hapus Paket Server", passed: false, details: err.message });
    }
  }

  console.log("\n==================================================");
  console.log("📊 HASIL PENGUJIAN API:");
  console.log("==================================================");
  const passedCount = results.filter((r) => r.passed).length;
  console.log(`Total: ${passedCount} / ${results.length} Pengujian Berhasil`);
  if (passedCount === results.length) {
    console.log("🎉 SEMUA TEST CASE LULUS 100%! REST API SIAP DINILAI PENGUJI!");
  }
  console.log("==================================================");
};

runTests();
