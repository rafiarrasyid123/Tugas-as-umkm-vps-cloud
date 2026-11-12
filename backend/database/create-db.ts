import pg from "pg";
import "dotenv/config";

const { Client } = pg;

const client = new Client({
  host: process.env.DB_HOST || "localhost",
  port: Number(process.env.DB_PORT) || 5432,
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD || "postgres",
  database: "postgres",
});

async function createDatabase() {
  try {
    await client.connect();
    console.log("Connected to PostgreSQL server!");

    const res = await client.query(
      "SELECT 1 FROM pg_database WHERE datname = 'db_servercloud'"
    );

    if (res.rows.length === 0) {
      console.log("Membuat database db_servercloud...");
      await client.query("CREATE DATABASE db_servercloud");
      console.log("✅ Database db_servercloud berhasil dibuat!");
    } else {
      console.log("ℹ️ Database db_servercloud sudah ada.");
    }

    await client.end();
  } catch (err: any) {
    console.error("❌ Gagal membuat database:", err.message);
    if (err.message.includes("password authentication failed")) {
      console.error("👉 TIP: Password PostgreSQL lokal kamu berbeda dengan 'postgres'.");
      console.error("👉 Ubah DB_PASSWORD di file backend/.env sesuai password PostgreSQL kamu, atau masukkan DATABASE_URL dari Aiven!");
    }
  }
}

createDatabase();
