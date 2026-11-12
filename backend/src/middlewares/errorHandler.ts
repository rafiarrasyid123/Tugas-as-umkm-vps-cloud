import { type Request, type Response, type NextFunction } from "express";
import multer from "multer";

export const notFoundHandler = (req: Request, res: Response): any => {
  return res.status(404).json({
    success: false,
    message: `Endpoint ${req.method} ${req.originalUrl} tidak ditemukan`,
  });
};

export const globalErrorHandler = (
  err: any,
  _req: Request,
  res: Response,
  _next: NextFunction
): any => {
  console.error("SERVER ERROR:", err);

  if (err instanceof multer.MulterError) {
    if (err.code === "LIMIT_FILE_SIZE") {
      return res.status(400).json({
        success: false,
        message: "Ukuran file terlalu besar! Maksimal ukuran file adalah 2MB",
      });
    }
    return res.status(400).json({
      success: false,
      message: `Error upload file: ${err.message}`,
    });
  }

  if (err.message && err.message.includes("Hanya file gambar")) {
    return res.status(400).json({
      success: false,
      message: err.message,
    });
  }

  return res.status(500).json({
    success: false,
    message: "Terjadi kesalahan pada internal server",
    error: process.env.NODE_ENV === "development" ? err.message : undefined,
  });
};
