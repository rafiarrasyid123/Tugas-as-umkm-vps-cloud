import express from "express";
import cors from "cors";
import path from "path";
import authRoutes from "./routes/authRoutes.ts";
import categoryRoutes from "./routes/categoryRoutes.ts";
import packageRoutes from "./routes/packageRoutes.ts";
import { notFoundHandler, globalErrorHandler } from "./middlewares/errorHandler.ts";

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files untuk uploads lokal
app.use("/uploads", express.static(path.resolve("uploads")));

// Root route / Health check
app.get("/", (_req, res) => {
  res.status(200).json({
    success: true,
    message: "ServerCloud REST API is Running (UMKM Cloud & VPS Hosting)",
    version: "1.0.0",
    docs: "/api/docs",
    author: "Rafi Arrasyid - SMK Taruna Bhakti",
  });
});

// API Routes
app.use("/api/auth", authRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/packages", packageRoutes);

// Error Handling Middlewares
app.use(notFoundHandler);
app.use(globalErrorHandler);

export default app;
