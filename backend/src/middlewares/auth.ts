import { type Request, type Response, type NextFunction } from "express";
import jwt from "jsonwebtoken";
import "dotenv/config";

export interface AuthUser {
  id: number;
  email: string;
  role: "admin" | "client";
  full_name: string;
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthUser;
    }
  }
}

const JWT_SECRET = process.env.JWT_SECRET || "supersecret_servercloud_jwt_token_key_2026";

export const authenticate = (req: Request, res: Response, next: NextFunction): any => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({
      success: false,
      message: "Akses ditolak: Token autentikasi tidak ditemukan",
    });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, JWT_SECRET) as AuthUser;
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: "Akses ditolak: Token tidak valid atau sudah kedaluwarsa",
    });
  }
};

export const authorizeRoles = (...roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction): any => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: "Pengguna belum terautentikasi",
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Akses ditolak: Hanya role [${roles.join(", ")}] yang diizinkan mengakses fitur ini`,
      });
    }

    next();
  };
};
