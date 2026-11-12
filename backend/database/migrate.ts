import fs from "fs";
import path from "path";
import pool from "../src/config/db.ts";

const runMigration = async () => {
  console.log("==================================================");
  console.log("📦 Memulai Migrasi Database ServerCloud (PostgreSQL)");
  console.log("==================================================");

  try {
    const schemaPath = path.resolve("database/schema.sql");
    const seedPath = path.resolve("database/seed.sql");

    const schemaSql = fs.readFileSync(schemaPath, "utf-8");
    const seedSql = fs.readFileSync(seedPath, "utf-8");

    console.log("1. Menjalankan DDL (Pembuatan Tabel)...");
    await pool.query(schemaSql);
    console.log("✅ Tabel users, service_categories, dan server_packages berhasil dibuat.");

    console.log("2. Menjalankan DML (Seeder Data Awal & Akun Pengujian)...");
    await pool.query(seedSql);
    console.log("✅ Data akun admin, client, kategori, dan paket server awal berhasil dimasukkan.");

    console.log("==================================================");
    console.log("🎉 Migrasi & Seeder Berhasil 100%!");
    console.log("==================================================");
    console.log("Akun Pengujian:");
    console.log(" - Admin  : admin@servercloud.id / password123");
    console.log(" - Client : client@servercloud.id / password123");
    console.log("==================================================");

    process.exit(0);
  } catch (error: any) {
    console.error("❌ Gagal menjalankan migrasi:", error.message);
    process.exit(1);
  }
};

runMigration();
