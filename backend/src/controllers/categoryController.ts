import { type Request, type Response } from "express";
import pool from "../config/db.ts";

const generateSlug = (text: string) => {
  return text
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, "")
    .replace(/[\s_-]+/g, "-")
    .replace(/^-+|-+$/g, "");
};

export const getAllCategories = async (_req: Request, res: Response): Promise<any> => {
  try {
    const result = await pool.query(
      `SELECT c.id, c.name, c.slug, c.description, c.created_at,
              COUNT(p.id)::int AS total_packages
       FROM service_categories c
       LEFT JOIN server_packages p ON c.id = p.category_id
       GROUP BY c.id
       ORDER BY c.id ASC`
    );

    return res.status(200).json({
      success: true,
      message: "Berhasil mengambil daftar kategori layanan",
      data: result.rows,
    });
  } catch (error: any) {
    console.error("GET CATEGORIES ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Gagal mengambil daftar kategori",
      error: error.message,
    });
  }
};

export const getCategoryById = async (req: Request, res: Response): Promise<any> => {
  try {
    const categoryId = parseInt(String(req.params.id));
    if (isNaN(categoryId)) {
      return res.status(400).json({ success: false, message: "ID kategori tidak valid" });
    }

    const catResult = await pool.query(
      "SELECT * FROM service_categories WHERE id = $1",
      [categoryId]
    );

    if (catResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Kategori layanan tidak ditemukan",
      });
    }

    const pkgResult = await pool.query(
      "SELECT * FROM server_packages WHERE category_id = $1 ORDER BY price_per_month ASC",
      [categoryId]
    );

    return res.status(200).json({
      success: true,
      message: "Detail kategori berhasil diambil",
      data: {
        ...catResult.rows[0],
        packages: pkgResult.rows,
      },
    });
  } catch (error: any) {
    console.error("GET CATEGORY BY ID ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Gagal mengambil detail kategori",
      error: error.message,
    });
  }
};

export const createCategory = async (req: Request, res: Response): Promise<any> => {
  try {
    const { name, description } = req.body;
    const baseSlug = generateSlug(name);
    let slug = baseSlug;

    // Check slug uniqueness
    const existing = await pool.query("SELECT id FROM service_categories WHERE slug = $1", [slug]);
    if (existing.rows.length > 0) {
      slug = `${baseSlug}-${Date.now().toString().slice(-4)}`;
    }

    const result = await pool.query(
      `INSERT INTO service_categories (name, slug, description)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [name, slug, description || null]
    );

    return res.status(201).json({
      success: true,
      message: "Kategori layanan baru berhasil ditambahkan",
      data: result.rows[0],
    });
  } catch (error: any) {
    console.error("CREATE CATEGORY ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Gagal menambahkan kategori layanan",
      error: error.message,
    });
  }
};

export const updateCategory = async (req: Request, res: Response): Promise<any> => {
  try {
    const categoryId = parseInt(String(req.params.id));
    if (isNaN(categoryId)) {
      return res.status(400).json({ success: false, message: "ID kategori tidak valid" });
    }

    const { name, description } = req.body;

    const check = await pool.query("SELECT id FROM service_categories WHERE id = $1", [categoryId]);
    if (check.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Kategori layanan tidak ditemukan",
      });
    }

    const slug = generateSlug(name);

    const result = await pool.query(
      `UPDATE service_categories
       SET name = $1, slug = $2, description = $3
       WHERE id = $4
       RETURNING *`,
      [name, slug, description || null, categoryId]
    );

    return res.status(200).json({
      success: true,
      message: "Kategori layanan berhasil diperbarui",
      data: result.rows[0],
    });
  } catch (error: any) {
    console.error("UPDATE CATEGORY ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Gagal memperbarui kategori layanan",
      error: error.message,
    });
  }
};

export const deleteCategory = async (req: Request, res: Response): Promise<any> => {
  try {
    const categoryId = parseInt(String(req.params.id));
    if (isNaN(categoryId)) {
      return res.status(400).json({ success: false, message: "ID kategori tidak valid" });
    }

    // Cek apakah ada paket server yang menggunakan kategori ini
    const pkgCheck = await pool.query(
      "SELECT id FROM server_packages WHERE category_id = $1 LIMIT 1",
      [categoryId]
    );

    if (pkgCheck.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message:
          "Kategori tidak dapat dihapus karena masih digunakan oleh paket server aktif. Hapus atau pindahkan paket terlebih dahulu.",
      });
    }

    const deleteResult = await pool.query(
      "DELETE FROM service_categories WHERE id = $1 RETURNING id, name",
      [categoryId]
    );

    if (deleteResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Kategori layanan tidak ditemukan",
      });
    }

    return res.status(200).json({
      success: true,
      message: `Kategori '${deleteResult.rows[0].name}' berhasil dihapus`,
      data: deleteResult.rows[0],
    });
  } catch (error: any) {
    console.error("DELETE CATEGORY ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Gagal menghapus kategori layanan",
      error: error.message,
    });
  }
};
