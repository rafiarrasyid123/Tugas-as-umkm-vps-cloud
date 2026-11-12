import app from "./app.ts";
import pool from "./config/db.ts";
import "dotenv/config";

const PORT = process.env.PORT || 5000;

const startServer = async () => {
  try {
    // Uji koneksi ke PostgreSQL
    const dbTest = await pool.query("SELECT NOW() as current_time");
    console.log("--------------------------------------------------");
    console.log("🚀 ServerCloud Backend Started Successfully!");
    console.log(`📡 Server running at: http://localhost:${PORT}`);
    console.log(`🐘 Connected to PostgreSQL: ${dbTest.rows[0].current_time}`);
    console.log("--------------------------------------------------");

    app.listen(PORT, () => {
      console.log(`API Endpoints available at:`);
      console.log(` - Auth       : http://localhost:${PORT}/api/auth`);
      console.log(` - Categories : http://localhost:${PORT}/api/categories`);
      console.log(` - Packages   : http://localhost:${PORT}/api/packages`);
    });
  } catch (error: any) {
    console.error("❌ Failed to connect to PostgreSQL database:", error.message);
    console.error("Pastikan database sudah dibuat atau periksa konfigurasi .env!");
    
    // Tetap jalankan express server agar user bisa melihat status
    app.listen(PORT, () => {
      console.log(`⚠️ Server running with DB warning at: http://localhost:${PORT}`);
    });
  }
};

startServer();
