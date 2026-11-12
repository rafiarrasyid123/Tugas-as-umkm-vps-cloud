import { type Request, type Response } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import pool from "../config/db.ts";
import "dotenv/config";

const JWT_SECRET = process.env.JWT_SECRET || "supersecret_servercloud_jwt_token_key_2026";

export const register = async (req: Request, res: Response): Promise<any> => {
  try {
    const { full_name, email, password, role, phone } = req.body;

    const existingUser = await pool.query("SELECT id FROM users WHERE email = $1", [email]);
    if (existingUser.rows.length > 0) {
      return res.status(409).json({
        success: false,
        message: "Email sudah terdaftar. Silakan gunakan email lain atau login.",
      });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    const userRole = role === "admin" ? "admin" : "client";

    const result = await pool.query(
      `INSERT INTO users (full_name, email, password, role, phone)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, full_name, email, role, phone, created_at`,
      [full_name, email, hashedPassword, userRole, phone || null]
    );

    const newUser = result.rows[0];

    const token = jwt.sign(
      {
        id: newUser.id,
        email: newUser.email,
        role: newUser.role,
        full_name: newUser.full_name,
      },
      JWT_SECRET,
      { expiresIn: "24h" }
    );

    return res.status(201).json({
      success: true,
      message: "Registrasi pengguna berhasil",
      data: {
        user: newUser,
        token,
      },
    });
  } catch (error: any) {
    console.error("REGISTER ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Gagal memproses registrasi pengguna",
      error: error.message,
    });
  }
};

export const login = async (req: Request, res: Response): Promise<any> => {
  try {
    const { email, password } = req.body;

    const result = await pool.query(
      "SELECT id, full_name, email, password, role, phone, created_at FROM users WHERE email = $1",
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: "Kombinasi email atau password salah",
      });
    }

    const user = result.rows[0];
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: "Kombinasi email atau password salah",
      });
    }

    const token = jwt.sign(
      {
        id: user.id,
        email: user.email,
        role: user.role,
        full_name: user.full_name,
      },
      JWT_SECRET,
      { expiresIn: "24h" }
    );

    const { password: _pw, ...userData } = user;

    return res.status(200).json({
      success: true,
      message: "Login berhasil",
      data: {
        user: userData,
        token,
      },
    });
  } catch (error: any) {
    console.error("LOGIN ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Gagal memproses login",
      error: error.message,
    });
  }
};

export const getProfile = async (req: Request, res: Response): Promise<any> => {
  try {
    const userId = req.user?.id;

    const result = await pool.query(
      "SELECT id, full_name, email, role, phone, created_at FROM users WHERE id = $1",
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Pengguna tidak ditemukan",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Profil pengguna berhasil diambil",
      data: result.rows[0],
    });
  } catch (error: any) {
    console.error("GET PROFILE ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Gagal mengambil data profil",
      error: error.message,
    });
  }
};
