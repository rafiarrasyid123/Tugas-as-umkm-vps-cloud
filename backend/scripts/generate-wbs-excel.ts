import ExcelJS from "exceljs";
import path from "path";

interface WBSTask {
  level: number;
  wbs: string;
  description: string;
  assignedTo: string;
  start: Date;
  end: Date;
  notes: string;
}

// Gunakan Date.UTC pada jam 12:00 agar tidak tergeser zona waktu (-7 jam)
const d = (year: number, monthZeroBased: number, day: number) => {
  return new Date(Date.UTC(year, monthZeroBased, day, 12, 0, 0));
};

const TASKS: WBSTask[] = [
  // Phase 1
  {
    level: 1,
    wbs: "1",
    description: "Inisiasi & Analisis Kebutuhan Sistem",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 10), // 10 Nov 2026
    end: d(2026, 10, 11),
    notes: "Fase inisiasi, wawancara kebutuhan UMKM & studi pustaka layanan cloud",
  },
  {
    level: 2,
    wbs: "1.1",
    description: "Studi Kasus & Analisis Kebutuhan Cloud UMKM",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 10),
    end: d(2026, 10, 10),
    notes: "Identifikasi kendala biaya hosting konvensional bagi pelaku usaha kecil",
  },
  {
    level: 2,
    wbs: "1.2",
    description: "Penyusunan Kebutuhan Fungsional & Non-Fungsional (FR/NFR)",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 10),
    end: d(2026, 10, 11),
    notes: "Spesifikasi 8 Functional Requirements & 4 Non-Functional Requirements",
  },
  {
    level: 2,
    wbs: "1.3",
    description: "Penyusunan Dokumen Spesifikasi Kebutuhan Perangkat Lunak (SRS)",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 11),
    end: d(2026, 10, 11),
    notes: "Penyusunan dokumen SRS berstandar IEEE 830 dalam format Markdown & Word",
  },

  // Phase 2
  {
    level: 1,
    wbs: "2",
    description: "Perancangan Sistem & Arsitektur",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 11),
    end: d(2026, 10, 12),
    notes: "Perancangan skema data, diagram UML, UI/UX & spesifikasi antarmuka API",
  },
  {
    level: 2,
    wbs: "2.1",
    description: "Perancangan Basis Data Relasional (ERD 4 Tabel)",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 11),
    end: d(2026, 10, 11),
    notes: "Tabel users, service_categories, server_packages, dan orders (FK & Index)",
  },
  {
    level: 2,
    wbs: "2.2",
    description: "Pemodelan Diagram UML (Use Case & Activity Diagram)",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 11),
    end: d(2026, 10, 12),
    notes: "Visualisasi interaksi Client vs Admin serta alur transaksi penyewaan",
  },
  {
    level: 2,
    wbs: "2.3",
    description: "Desain Antarmuka Pengguna (UI/UX Mobile Neo-Brutalism)",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 12),
    end: d(2026, 10, 12),
    notes: "Desain gaya Neo-Brutalism: border 2.0 solid, shadow tegas, palet kontras",
  },
  {
    level: 2,
    wbs: "2.4",
    description: "Perancangan Kontrak REST API & Dokumentasi Interaktif",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 12),
    end: d(2026, 10, 12),
    notes: "Spesifikasi endpoint auth, packages, categories, orders, dan Swagger/Scalar",
  },

  // Phase 3
  {
    level: 1,
    wbs: "3",
    description: "Pengembangan Backend & Database (REST API)",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 12),
    end: d(2026, 10, 13),
    notes: "Implementasi server Express.js, TypeScript, PostgreSQL Aiven, dan Cloudinary",
  },
  {
    level: 2,
    wbs: "3.1",
    description: "Setup Database Cloud Aiven PostgreSQL (SSL) & Skrip Migrasi",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 12),
    end: d(2026, 10, 12),
    notes: "Provisioning database cloud Aiven PG 16, setup SSL mode, & migrasi DDL",
  },
  {
    level: 2,
    wbs: "3.2",
    description: "Implementasi Modul Autentikasi (JWT, Bcrypt & Role Guard)",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 12),
    end: d(2026, 10, 12),
    notes: "Enkripsi password 10 salt rounds, validasi token Bearer & otorisasi role",
  },
  {
    level: 2,
    wbs: "3.3",
    description: "Pengembangan Modul CRUD Kategori & Paket Server Cloud",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 12),
    end: d(2026, 10, 13),
    notes: "Query filter kategori, pencarian keyword paket, pagination, & validasi Zod",
  },
  {
    level: 2,
    wbs: "3.4",
    description: "Pengembangan Modul Transaksi Sewa Server & Invoicing Otomatis",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 13),
    end: d(2026, 10, 13),
    notes: "Format SC-INV-YYYYMMDD-XXXX, pengurangan stok, & simulasi aktivasi IP",
  },
  {
    level: 2,
    wbs: "3.5",
    description: "Integrasi Penyimpanan Media Cloudinary CDN & Multer Upload",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 13),
    end: d(2026, 10, 13),
    notes: "Upload gambar cover paket server via memoryStorage & transformasi CDN",
  },

  // Phase 4
  {
    level: 1,
    wbs: "4",
    description: "Pengembangan Aplikasi Mobile Client (Flutter)",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 13),
    end: d(2026, 10, 14),
    notes: "Pembangunan aplikasi cross-platform Flutter dengan arsitektur modular",
  },
  {
    level: 2,
    wbs: "4.1",
    description: "Setup Tema Neo-Brutalism & SharedPreferences Token Session",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 13),
    end: d(2026, 10, 13),
    notes: "Konfigurasi AppTheme neoDecoration, Google Fonts Inter, & persistensi sesi",
  },
  {
    level: 2,
    wbs: "4.2",
    description: "Pembuatan Modul Autentikasi (Splash, Login, Register & Shortcut)",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 13),
    end: d(2026, 10, 14),
    notes: "Tombol fast-fill demo client/admin & auto redirect splash screen",
  },
  {
    level: 2,
    wbs: "4.3",
    description: "Pembuatan Katalog Paket Server, Search Bar & Filter Kategori",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 14),
    end: d(2026, 10, 14),
    notes: "List interaktif kartu paket server, live debounced search & chips kategori",
  },
  {
    level: 2,
    wbs: "4.4",
    description: "Form Pengelolaan Paket Server & Image Picker (Kamera/Galeri)",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 14),
    end: d(2026, 10, 14),
    notes: "Multi-part form upload foto cover paket langsung dari perangkat (Khusus Admin)",
  },
  {
    level: 2,
    wbs: "4.5",
    description: "Modul Checkout Sewa, Invoice Virtual Account & Simulasi Bayar",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 14),
    end: d(2026, 10, 14),
    notes: "Modal bottom sheet durasi sewa, salin nomor VA, & aktivasi instan server",
  },

  // Phase 5
  {
    level: 1,
    wbs: "5",
    description: "Pengujian Sistem, Deployment & Finalisasi Proyek",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 14),
    end: d(2026, 10, 18),
    notes: "Validasi fungsional menyeluruh, deployment cloud, dan penyelesaian laporan",
  },
  {
    level: 2,
    wbs: "5.1",
    description: "Pengujian Sistem Menggunakan Metode Blackbox Testing",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 14),
    end: d(2026, 10, 14),
    notes: "Eksekusi 8 skenario pengujian fungsionalitas (Auth, CRUD, Sewa, Upload)",
  },
  {
    level: 2,
    wbs: "5.2",
    description: "Deployment Backend ke Vercel Serverless & Sinkronisasi DB",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 14),
    end: d(2026, 10, 14),
    notes: "Deploy production REST API publik & verifikasi endpoint live di Vercel",
  },
  {
    level: 2,
    wbs: "5.3",
    description: "Finalisasi Dokumen SRS (.docx), File WBS (.xlsx) & Presentasi",
    assignedTo: "Rafi Arrasyid",
    start: d(2026, 10, 18),
    end: d(2026, 10, 18),
    notes: "Penyusunan berkas kelengkapan ujian kompetensi keahlian XI RPL 3 SMK Taruna Bhakti",
  },
];

async function generateWBS() {
  const filePath = path.resolve(process.cwd(), "..", "WBS_ServerCloud_Rafi_Arrasyid_XI_RPL_3.xlsx");
  console.log("Loading workbook from:", filePath);

  const wb = new ExcelJS.Workbook();
  await wb.xlsx.readFile(filePath);

  const sheet = wb.getWorksheet("WBS");
  if (!sheet) {
    throw new Error("Sheet 'WBS' tidak ditemukan dalam file Excel!");
  }

  // 1. Perlebar kolom agar TIDAK terpotong dan TIDAK tabrakan
  sheet.getColumn("A").width = 3;
  sheet.getColumn("B").width = 9;   // Level
  sheet.getColumn("C").width = 12;  // WBS
  sheet.getColumn("D").width = 62;  // Task Description (luas agar kalimat panjang muat tanpa terpotong)
  sheet.getColumn("E").width = 20;  // Assigned To ("Rafi Arrasyid" leluasa)
  sheet.getColumn("F").width = 15;  // Start Date
  sheet.getColumn("G").width = 15;  // End Date
  sheet.getColumn("H").width = 75;  // Notes (luas agar catatan lengkap terbaca rapi)

  // 2. Rapikan Header Baris 1 & Baris 3
  // B1 tetap "Work Breakdown Structure"
  // H1 dibuat proporsional dan tidak tabrakan dengan B1
  sheet.getCell("B1").value = "Work Breakdown Structure";
  sheet.getCell("H1").value = "Project: ServerCloud (UMKM Cloud & VPS)";
  sheet.getCell("H1").alignment = { horizontal: "right", vertical: "middle" };

  // Set Project Start (Tue, Nov 10, 2026)
  sheet.getCell("D3").value = d(2026, 10, 10);

  // Bersihkan teks watermark/help template di kolom K
  sheet.getCell("K2").value = null;
  sheet.getCell("K3").value = null;
  sheet.getCell("K6").value = null;

  // 3. Isi Setiap Baris Task (Row 6 s.d. 30)
  TASKS.forEach((task, index) => {
    const rowNumber = 6 + index;
    const row = sheet.getRow(rowNumber);

    // Ketinggian baris lebih lega (24pt)
    row.height = 24;

    // Kolom B: Level
    row.getCell("B").value = task.level;

    // Kolom C: Formula WBS bawaan template dengan result yang sudah dihitung
    if (index === 0) {
      row.getCell("C").value = {
        formula: 'IF(B6="","",IF(B6>OFFSET(B6,-1,0,1,1),IF(OFFSET(C6,-1,0,1,1)="","1",OFFSET(C6,-1,0,1,1))&REPT(".1",B6-MAX(OFFSET(B6,-1,0,1,1),1)),IF(ISERROR(FIND(".",OFFSET(C6,-1,0,1,1))),REPT("1.",B6-1)&IFERROR(VALUE(OFFSET(C6,-1,0,1,1))+1,"1"),IF(B6=1,"",IFERROR(LEFT(OFFSET(C6,-1,0,1,1),FIND("^",SUBSTITUTE(OFFSET(C6,-1,0,1,1),".","^",B6-1))),""))&VALUE(TRIM(MID(SUBSTITUTE(OFFSET(C6,-1,0,1,1),".",REPT(" ",LEN(OFFSET(C6,-1,0,1,1)))),(B6-1)*LEN(OFFSET(C6,-1,0,1,1))+1,LEN(OFFSET(C6,-1,0,1,1)))))+1)))',
        result: task.wbs,
      };
    } else if (index === 1) {
      row.getCell("C").value = {
        formula: 'IF(B7="","",IF(B7>OFFSET(B7,-1,0,1,1),IF(OFFSET(C7,-1,0,1,1)="","1",OFFSET(C7,-1,0,1,1))&REPT(".1",B7-MAX(OFFSET(B7,-1,0,1,1),1)),IF(ISERROR(FIND(".",OFFSET(C7,-1,0,1,1))),REPT("1.",B7-1)&IFERROR(VALUE(OFFSET(C7,-1,0,1,1))+1,"1"),IF(B7=1,"",IFERROR(LEFT(OFFSET(C7,-1,0,1,1),FIND("^",SUBSTITUTE(OFFSET(C7,-1,0,1,1),".","^",B7-1))),""))&VALUE(TRIM(MID(SUBSTITUTE(OFFSET(C7,-1,0,1,1),".",REPT(" ",LEN(OFFSET(C7,-1,0,1,1)))),(B7-1)*LEN(OFFSET(C7,-1,0,1,1))+1,LEN(OFFSET(C7,-1,0,1,1)))))+1)))',
        result: task.wbs,
        ref: "C7:C30",
        shareType: "shared",
      };
    } else {
      row.getCell("C").value = {
        sharedFormula: "C7",
        result: task.wbs,
      };
    }

    // Kolom D: Task Description
    const cellD = row.getCell("D");
    cellD.value = task.description;
    // Indentasi: Level 1 indent 1, Level 2 indent 2
    cellD.alignment = {
      horizontal: "left",
      vertical: "middle",
      indent: task.level === 1 ? 1 : 2,
    };
    if (task.level === 1) {
      cellD.font = {
        name: "Calibri",
        size: 11,
        bold: true,
      };
    }

    // Kolom E: Assigned To
    const cellE = row.getCell("E");
    cellE.value = task.assignedTo;
    cellE.alignment = {
      horizontal: "left",
      vertical: "middle",
      indent: 1,
    };

    // Kolom F: Start Date
    const cellF = row.getCell("F");
    cellF.value = task.start;
    cellF.numFmt = "yyyy-mm-dd";
    cellF.alignment = {
      horizontal: "center",
      vertical: "middle",
    };

    // Kolom G: End Date
    const cellG = row.getCell("G");
    cellG.value = task.end;
    cellG.numFmt = "yyyy-mm-dd";
    cellG.alignment = {
      horizontal: "center",
      vertical: "middle",
    };

    // Kolom H: Notes
    const cellH = row.getCell("H");
    cellH.value = task.notes;
    cellH.alignment = {
      horizontal: "left",
      vertical: "middle",
      indent: 1,
    };

    row.commit();
  });

  // 4. Pastikan baris setelah 30 bersih dari sisa template jika ada
  for (let r = 31; r <= 35; r++) {
    const row = sheet.getRow(r);
    for (let c = 1; c <= 12; c++) {
      row.getCell(c).value = null;
    }
  }

  // Simpan file
  try {
    await wb.xlsx.writeFile(filePath);
    console.log("Successfully refined WBS Excel at:", filePath);
  } catch (err: any) {
    if (err.code === "EBUSY") {
      const fallbackPath = path.resolve(process.cwd(), "..", "WBS_ServerCloud_Rafi_Arrasyid_XI_RPL_3_Fixed.xlsx");
      console.warn("File utama sedang dibuka di Excel. Menyimpan ke fallback:", fallbackPath);
      await wb.xlsx.writeFile(fallbackPath);
      console.log("Successfully refined WBS Excel at:", fallbackPath);
    } else {
      throw err;
    }
  }
}

generateWBS().catch((err) => {
  console.error("Error generating WBS:", err);
  process.exit(1);
});
