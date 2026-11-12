import pg from "pg";
import "dotenv/config";

const { Pool } = pg;

const connectionString = process.env.DATABASE_URL;
const isRemoteHost =
  process.env.DB_HOST &&
  process.env.DB_HOST !== "localhost" &&
  process.env.DB_HOST !== "127.0.0.1";

export const pool = new Pool(
  connectionString
    ? {
        connectionString,
        ssl: {
          rejectUnauthorized: false,
        },
      }
    : {
        host: process.env.DB_HOST || "localhost",
        port: Number(process.env.DB_PORT) || 5432,
        user: process.env.DB_USER || "postgres",
        password: process.env.DB_PASSWORD || "postgres",
        database: process.env.DB_NAME || "db_servercloud",
        ssl: isRemoteHost ? { rejectUnauthorized: false } : undefined,
      }
);

pool.on("error", (err) => {
  console.error("Unexpected error on idle database client", err);
});

export const query = (text: string, params?: any[]) => pool.query(text, params);

export default pool;
