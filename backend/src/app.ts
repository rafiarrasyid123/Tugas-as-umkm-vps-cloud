import express from "express";
import cors from "cors";
import path from "path";
import authRoutes from "./routes/authRoutes.ts";
import categoryRoutes from "./routes/categoryRoutes.ts";
import packageRoutes from "./routes/packageRoutes.ts";
import { notFoundHandler, globalErrorHandler } from "./middlewares/errorHandler.ts";
import { getDocsHtml } from "./docs/apiDocsHtml.ts";

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

// Interactive API Documentation Page
app.get("/api/docs", (req, res) => {
  if (req.headers.accept && req.headers.accept.includes("application/json")) {
    return res.status(200).json({
      title: "ServerCloud REST API Documentation",
      version: "1.0.0",
      baseUrl: "https://tugas-as-umkm-vps-cloud-8hk2.vercel.app",
      auth: {
        register: "POST /api/auth/register",
        login: "POST /api/auth/login",
        profile: "GET /api/auth/profile",
      },
      categories: {
        getAll: "GET /api/categories",
        getById: "GET /api/categories/:id",
        create: "POST /api/categories",
        update: "PUT /api/categories/:id",
        delete: "DELETE /api/categories/:id",
      },
      packages: {
        getAll: "GET /api/packages",
        getById: "GET /api/packages/:id",
        create: "POST /api/packages",
        update: "PUT /api/packages/:id",
        delete: "DELETE /api/packages/:id",
      },
    });
  }
  res.setHeader("Content-Type", "text/html; charset=utf-8");
  return res.status(200).send(getDocsHtml());
});

// API Routes
app.use("/api/auth", authRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/packages", packageRoutes);

// Error Handling Middlewares
app.use(notFoundHandler);
app.use(globalErrorHandler);

export default app;
