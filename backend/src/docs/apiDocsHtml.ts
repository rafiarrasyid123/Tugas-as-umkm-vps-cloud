export const getDocsHtml = (): string => {
  return `<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ServerCloud REST API Documentation</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
  <style>
    body { font-family: 'Inter', sans-serif; }
    code, pre { font-family: 'JetBrains Mono', monospace; }
  </style>
</head>
<body class="bg-slate-950 text-slate-100 min-h-screen">
  <!-- Header -->
  <header class="border-b border-slate-800 bg-slate-900/60 backdrop-blur sticky top-0 z-50">
    <div class="max-w-6xl mx-auto px-4 py-4 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
      <div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">☁️</span>
          <h1 class="text-xl font-bold tracking-tight text-white">ServerCloud REST API Docs</h1>
          <span class="px-2 py-0.5 text-xs font-semibold bg-indigo-500/20 text-indigo-400 border border-indigo-500/30 rounded-full">v1.0.0</span>
        </div>
        <p class="text-xs text-slate-400 mt-1">Layanan Cloud Hosting & VPS Mandiri untuk UMKM • Uji Level RPL SMK Taruna Bhakti</p>
      </div>
      <div class="flex items-center gap-3 text-xs">
        <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
          <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
          Aiven PostgreSQL Live
        </span>
        <span class="text-slate-400">Oleh: <strong class="text-white">Rafi Arrasyid</strong> (XI RPL 3)</span>
      </div>
    </div>
  </header>

  <main class="max-w-6xl mx-auto px-4 py-8 space-y-10">
    <!-- Quick Info Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <div class="bg-slate-900/80 border border-slate-800 rounded-xl p-4">
        <div class="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-1">Base URL</div>
        <code class="text-sm font-semibold text-indigo-400 select-all break-all">https://tugas-as-umkm-vps-cloud-8hk2.vercel.app</code>
      </div>
      <div class="bg-slate-900/80 border border-slate-800 rounded-xl p-4">
        <div class="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-1">Akun Uji: Admin</div>
        <div class="text-sm text-slate-200"><span class="text-slate-400">Email:</span> admin@servercloud.id</div>
        <div class="text-xs text-slate-400"><span class="text-slate-500">Password:</span> password123</div>
      </div>
      <div class="bg-slate-900/80 border border-slate-800 rounded-xl p-4">
        <div class="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-1">Akun Uji: Client</div>
        <div class="text-sm text-slate-200"><span class="text-slate-400">Email:</span> client@servercloud.id</div>
        <div class="text-xs text-slate-400"><span class="text-slate-500">Password:</span> password123</div>
      </div>
    </div>

    <!-- Section 1: Auth -->
    <section class="space-y-4">
      <div class="flex items-center gap-2 border-b border-slate-800 pb-2">
        <span class="text-lg">🔐</span>
        <h2 class="text-lg font-bold text-white">1. Autentikasi Pengguna (/api/auth)</h2>
      </div>

      <!-- Endpoint: Register -->
      <div class="bg-slate-900/60 border border-slate-800 rounded-xl p-5 space-y-3">
        <div class="flex flex-wrap items-center justify-between gap-2">
          <div class="flex items-center gap-2.5">
            <span class="px-2.5 py-1 text-xs font-bold bg-blue-500/20 text-blue-400 border border-blue-500/30 rounded">POST</span>
            <code class="text-sm font-semibold text-white">/api/auth/register</code>
          </div>
          <span class="text-xs px-2.5 py-0.5 rounded-full bg-slate-800 text-slate-400">Public</span>
        </div>
        <p class="text-sm text-slate-300">Mendaftarkan pengguna baru dengan validasi skema Zod (nama min 3 huruf, email valid, password min 6).</p>
        <div>
          <div class="text-xs font-semibold text-slate-400 mb-1">Request Body (JSON):</div>
          <pre class="bg-slate-950 p-3 rounded-lg text-xs text-slate-300 overflow-x-auto border border-slate-800/80"><code>{
  "full_name": "Rafi Arrasyid",
  "email": "user@servercloud.id",
  "password": "password123",
  "phone": "081234567890",
  "role": "client" // "client" atau "admin"
}</code></pre>
        </div>
        <div class="text-xs text-slate-400">Response: <span class="text-emerald-400 font-semibold">201 Created</span> (beserta token JWT) | <span class="text-amber-400 font-semibold">400 Bad Request</span> (Zod error) | <span class="text-rose-400 font-semibold">409 Conflict</span></div>
      </div>

      <!-- Endpoint: Login -->
      <div class="bg-slate-900/60 border border-slate-800 rounded-xl p-5 space-y-3">
        <div class="flex flex-wrap items-center justify-between gap-2">
          <div class="flex items-center gap-2.5">
            <span class="px-2.5 py-1 text-xs font-bold bg-blue-500/20 text-blue-400 border border-blue-500/30 rounded">POST</span>
            <code class="text-sm font-semibold text-white">/api/auth/login</code>
          </div>
          <span class="text-xs px-2.5 py-0.5 rounded-full bg-slate-800 text-slate-400">Public</span>
        </div>
        <p class="text-sm text-slate-300">Autentikasi akun dan menerbitkan token JWT berdurasi 24 jam.</p>
        <div>
          <div class="text-xs font-semibold text-slate-400 mb-1">Request Body (JSON):</div>
          <pre class="bg-slate-950 p-3 rounded-lg text-xs text-slate-300 overflow-x-auto border border-slate-800/80"><code>{
  "email": "admin@servercloud.id",
  "password": "password123"
}</code></pre>
        </div>
        <div class="text-xs text-slate-400">Response: <span class="text-emerald-400 font-semibold">200 OK</span> (token & user data) | <span class="text-rose-400 font-semibold">401 Unauthorized</span></div>
      </div>

      <!-- Endpoint: Profile -->
      <div class="bg-slate-900/60 border border-slate-800 rounded-xl p-5 space-y-3">
        <div class="flex flex-wrap items-center justify-between gap-2">
          <div class="flex items-center gap-2.5">
            <span class="px-2.5 py-1 text-xs font-bold bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 rounded">GET</span>
            <code class="text-sm font-semibold text-white">/api/auth/profile</code>
          </div>
          <span class="text-xs px-2.5 py-0.5 rounded-full bg-indigo-500/20 text-indigo-400 border border-indigo-500/30">Bearer Token</span>
        </div>
        <p class="text-sm text-slate-300">Mengambil data profil user yang sedang aktif.</p>
        <div class="text-xs text-slate-400">Header: <code class="text-indigo-400">Authorization: Bearer &lt;token&gt;</code> • Response: <span class="text-emerald-400 font-semibold">200 OK</span></div>
      </div>
    </section>

    <!-- Section 2: Categories -->
    <section class="space-y-4">
      <div class="flex items-center gap-2 border-b border-slate-800 pb-2">
        <span class="text-lg">📁</span>
        <h2 class="text-lg font-bold text-white">2. Kategori Layanan (/api/categories)</h2>
      </div>

      <!-- GET Categories -->
      <div class="bg-slate-900/60 border border-slate-800 rounded-xl p-5 space-y-3">
        <div class="flex flex-wrap items-center justify-between gap-2">
          <div class="flex items-center gap-2.5">
            <span class="px-2.5 py-1 text-xs font-bold bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 rounded">GET</span>
            <code class="text-sm font-semibold text-white">/api/categories</code>
          </div>
          <span class="text-xs px-2.5 py-0.5 rounded-full bg-slate-800 text-slate-400">Public</span>
        </div>
        <p class="text-sm text-slate-300">Menampilkan daftar kategori layanan (Cloud VPS, Shared Hosting, Dedicated Server) beserta jumlah paket aktif.</p>
        <div class="text-xs text-slate-400">Response: <span class="text-emerald-400 font-semibold">200 OK</span></div>
      </div>

      <!-- POST Category -->
      <div class="bg-slate-900/60 border border-slate-800 rounded-xl p-5 space-y-3">
        <div class="flex flex-wrap items-center justify-between gap-2">
          <div class="flex items-center gap-2.5">
            <span class="px-2.5 py-1 text-xs font-bold bg-blue-500/20 text-blue-400 border border-blue-500/30 rounded">POST</span>
            <code class="text-sm font-semibold text-white">/api/categories</code>
          </div>
          <span class="text-xs px-2.5 py-0.5 rounded-full bg-rose-500/20 text-rose-400 border border-rose-500/30">Admin Only</span>
        </div>
        <p class="text-sm text-slate-300">Menambahkan kategori layanan baru.</p>
        <pre class="bg-slate-950 p-3 rounded-lg text-xs text-slate-300 border border-slate-800/80"><code>{
  "name": "Database Cluster Managed",
  "description": "Layanan database terkelola dengan auto backup dan high-availability."
}</code></pre>
        <div class="text-xs text-slate-400">Response: <span class="text-emerald-400 font-semibold">201 Created</span> | <span class="text-rose-400 font-semibold">403 Forbidden</span> (Jika bukan admin)</div>
      </div>

      <!-- PUT & DELETE Category -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="bg-slate-900/60 border border-slate-800 rounded-xl p-4 space-y-2">
          <div class="flex items-center gap-2">
            <span class="px-2 py-0.5 text-xs font-bold bg-amber-500/20 text-amber-400 border border-amber-500/30 rounded">PUT</span>
            <code class="text-xs font-semibold text-white">/api/categories/:id</code>
          </div>
          <p class="text-xs text-slate-400">Memperbarui nama & deskripsi kategori (Admin Only).</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 rounded-xl p-4 space-y-2">
          <div class="flex items-center gap-2">
            <span class="px-2 py-0.5 text-xs font-bold bg-rose-500/20 text-rose-400 border border-rose-500/30 rounded">DELETE</span>
            <code class="text-xs font-semibold text-white">/api/categories/:id</code>
          </div>
          <p class="text-xs text-slate-400">Menghapus kategori (Admin Only). Dilindungi jika ada paket aktif.</p>
        </div>
      </div>
    </section>

    <!-- Section 3: Packages -->
    <section class="space-y-4">
      <div class="flex items-center gap-2 border-b border-slate-800 pb-2">
        <span class="text-lg">🖥️</span>
        <h2 class="text-lg font-bold text-white">3. Paket Layanan Server (/api/packages)</h2>
      </div>

      <!-- GET Packages -->
      <div class="bg-slate-900/60 border border-slate-800 rounded-xl p-5 space-y-3">
        <div class="flex flex-wrap items-center justify-between gap-2">
          <div class="flex items-center gap-2.5">
            <span class="px-2.5 py-1 text-xs font-bold bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 rounded">GET</span>
            <code class="text-sm font-semibold text-white">/api/packages</code>
          </div>
          <span class="text-xs px-2.5 py-0.5 rounded-full bg-slate-800 text-slate-400">Public</span>
        </div>
        <p class="text-sm text-slate-300">Mengambil daftar seluruh paket server. Mendukung query filter & search:</p>
        <div class="text-xs space-y-1 text-slate-400 bg-slate-950 p-3 rounded-lg border border-slate-800/80">
          <div>• Filter Kategori: <code class="text-indigo-400">?category_id=1</code></div>
          <div>• Pencarian Teks: <code class="text-indigo-400">?search=starter</code></div>
          <div>• Urutan Harga: <code class="text-indigo-400">?sort=price_asc</code> (termurah) atau <code class="text-indigo-400">?sort=price_desc</code> (termahal)</div>
        </div>
        <div class="text-xs text-slate-400">Response: <span class="text-emerald-400 font-semibold">200 OK</span></div>
      </div>

      <!-- POST Package -->
      <div class="bg-slate-900/60 border border-slate-800 rounded-xl p-5 space-y-3">
        <div class="flex flex-wrap items-center justify-between gap-2">
          <div class="flex items-center gap-2.5">
            <span class="px-2.5 py-1 text-xs font-bold bg-blue-500/20 text-blue-400 border border-blue-500/30 rounded">POST</span>
            <code class="text-sm font-semibold text-white">/api/packages</code>
          </div>
          <span class="text-xs px-2.5 py-0.5 rounded-full bg-rose-500/20 text-rose-400 border border-rose-500/30">Admin Only</span>
        </div>
        <p class="text-sm text-slate-300">Menambahkan paket server baru beserta upload gambar banner (Maks 2MB). Mendukung JSON maupun <code class="text-indigo-400">multipart/form-data</code>.</p>
        <pre class="bg-slate-950 p-3 rounded-lg text-xs text-slate-300 border border-slate-800/80"><code>{
  "category_id": 1,
  "name": "VPS NVMe Ultra 8G",
  "cpu_cores": 4,
  "ram_gb": 8,
  "storage_gb": 160,
  "bandwidth_tb": 5,
  "price_per_month": 450000,
  "stock_available": 10,
  "description": "Server kecepatan tinggi untuk aplikasi e-commerce dan database.",
  "image": [File Gambar] // atau kirim field image_url
}</code></pre>
        <div class="text-xs text-slate-400">Response: <span class="text-emerald-400 font-semibold">201 Created</span> | <span class="text-amber-400 font-semibold">400 Bad Request</span> | <span class="text-rose-400 font-semibold">403 Forbidden</span></div>
      </div>

      <!-- PUT & DELETE Package -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="bg-slate-900/60 border border-slate-800 rounded-xl p-4 space-y-2">
          <div class="flex items-center gap-2">
            <span class="px-2 py-0.5 text-xs font-bold bg-amber-500/20 text-amber-400 border border-amber-500/30 rounded">PUT</span>
            <code class="text-xs font-semibold text-white">/api/packages/:id</code>
          </div>
          <p class="text-xs text-slate-400">Memperbarui paket server dan opsi ganti banner gambar (Admin Only).</p>
        </div>
        <div class="bg-slate-900/60 border border-slate-800 rounded-xl p-4 space-y-2">
          <div class="flex items-center gap-2">
            <span class="px-2 py-0.5 text-xs font-bold bg-rose-500/20 text-rose-400 border border-rose-500/30 rounded">DELETE</span>
            <code class="text-xs font-semibold text-white">/api/packages/:id</code>
          </div>
          <p class="text-xs text-slate-400">Menghapus paket server dari katalog (Admin Only).</p>
        </div>
      </div>
    </section>
  </main>

  <footer class="border-t border-slate-800 py-6 text-center text-xs text-slate-500">
    ServerCloud API • Uji Level Kompetensi Keahlian RPL 2026/2027 • SMK Taruna Bhakti
  </footer>
</body>
</html>`;
};
