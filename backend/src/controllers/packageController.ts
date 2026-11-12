import { type Request, type Response } from "express";
import fs from "fs";
import pool from "../config/db.ts";
import cloudinary, { isCloudinaryConfigured } from "../config/cloudinary.ts";

const generateSlug = (text: string) => {
  return text
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, "")
    .replace(/[\s_-]+/g, "-")
    .replace(/^-+|-+$/g, "");
};

export const getAllPackages = async (req: Request, res: Response): Promise<any> => {
  try {
    const { category_id, search, sort } = req.query;

    let queryText = `
      SELECT p.*, 
             c.name AS category_name, 
             c.slug AS category_slug,
             u.full_name AS created_by_name
      FROM server_packages p
      JOIN service_categories c ON p.category_id = c.id
      LEFT JOIN users u ON p.created_by = u.id
      WHERE 1=1
    `;
    const params: any[] = [];
    let paramIndex = 1;

    if (category_id) {
      queryText += ` AND p.category_id = $${paramIndex}`;
      params.push(Number(category_id));
      paramIndex++;
    }

    if (search) {
      queryText += ` AND (p.name ILIKE $${paramIndex} OR p.description ILIKE $${paramIndex})`;
      params.push(`%${search}%`);
      paramIndex++;
    }

    if (sort === "price_asc") {
      queryText += ` ORDER BY p.price_per_month ASC`;
    } else if (sort === "price_desc") {
      queryText += ` ORDER BY p.price_per_month DESC`;
    } else {
      queryText += ` ORDER BY p.created_at DESC`;
    }

    const result = await pool.query(queryText, params);

    return res.status(200).json({
      success: true,
      message: "Berhasil mengambil daftar paket server",
      total: result.rows.length,
      data: result.rows,
    });
  } catch (error: any) {
    console.error("GET PACKAGES ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Gagal mengambil daftar paket server",
      error: error.message,
    });
  }
};

export const getPackageById = async (req: Request, res: Response): Promise<any> => {
  try {
    const packageId = parseInt(req.params.id);
    if (isNaN(packageId)) {
      return res.status(400).json({ success: false, message: "ID paket tidak valid" });
    }

    const result = await pool.query(
      `SELECT p.*, 
              c.name AS category_name, 
              c.slug AS category_slug,
              c.description AS category_description,
              u.full_name AS created_by_name
       FROM server_packages p
       JOIN service_categories c ON p.category_id = c.id
       LEFT JOIN users u ON p.created_by = u.id
       WHERE p.id = $1`,
      [packageId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Paket server tidak ditemukan",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Detail paket server berhasil diambil",
      data: result.rows[0],
    });
  } catch (error: any) {
    console.error("GET PACKAGE BY ID ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Gagal mengambil detail paket server",
      error: error.message,
    });
  }
};

export const createPackage = async (req: Request, res: Response): Promise<any> => {
  try {
    const adminId = req.user?.id || null;
    const {
      category_id,
      name,
      cpu_cores,
      ram_gb,
      storage_gb,
      bandwidth_tb,
      price_per_month,
      stock_available,
      description,
      image_url,
    } = req.body;

    // Verifikasi kategori ada
    const catCheck = await pool.query("SELECT id FROM service_categories WHERE id = $1", [
      category_id,
    ]);
    if (catCheck.rows.length === 0) {
      if (req.file && fs.existsSync(req.file.path)) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(400).json({
        success: false,
        message: "Kategori layanan yang dipilih tidak ditemukan",
      });
    }

    let finalImageUrl: string | null = image_url || null;

    // Proses upload gambar
    if (req.file) {
      if (isCloudinaryConfigured) {
        try {
          const uploadResult = await cloudinary.uploader.upload(req.file.path, {
            folder: "servercloud-packages",
            resource_type: "image",
          });
          finalImageUrl = uploadResult.secure_url;
        } catch (uploadErr) {
          console.warn("Cloudinary upload failed, falling back to local storage:", uploadErr);
          finalImageUrl = `/uploads/servers/${req.file.filename}`;
        }
        if (fs.existsSync(req.file.path)) {
          fs.unlinkSync(req.file.path);
        }
      } else {
        // Fallback local file URL
        finalImageUrl = `/uploads/servers/${req.file.filename}`;
      }
    }

    if (!finalImageUrl) {
      finalImageUrl = "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=800&q=80";
    }

    const baseSlug = generateSlug(name);
    let slug = baseSlug;
    const slugCheck = await pool.query("SELECT id FROM server_packages WHERE slug = $1", [slug]);
    if (slugCheck.rows.length > 0) {
      slug = `${baseSlug}-${Date.now().toString().slice(-4)}`;
    }

    const result = await pool.query(
      `INSERT INTO server_packages 
        (category_id, name, slug, cpu_cores, ram_gb, storage_gb, bandwidth_tb, price_per_month, stock_available, image_url, description, created_by)
       VALUES 
        ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
       RETURNING *`,
      [
        category_id,
        name,
        slug,
        cpu_cores,
        ram_gb,
        storage_gb,
        bandwidth_tb,
        price_per_month,
        stock_available ?? 10,
        finalImageUrl,
        description || null,
        adminId,
      ]
    );

    return res.status(201).json({
      success: true,
      message: "Paket server baru berhasil dibuat",
      data: result.rows[0],
    });
  } catch (error: any) {
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
    console.error("CREATE PACKAGE ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Gagal membuat paket server",
      error: error.message,
    });
  }
};

export const updatePackage = async (req: Request, res: Response): Promise<any> => {
  try {
    const packageId = parseInt(req.params.id);
    if (isNaN(packageId)) {
      if (req.file && fs.existsSync(req.file.path)) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(400).json({ success: false, message: "ID paket tidak valid" });
    }

    const check = await pool.query("SELECT * FROM server_packages WHERE id = $1", [packageId]);
    if (check.rows.length === 0) {
      if (req.file && fs.existsSync(req.file.path)) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(404).json({
        success: false,
        message: "Paket server tidak ditemukan",
      });
    }

    const currentPackage = check.rows[0];
    const {
      category_id,
      name,
      cpu_cores,
      ram_gb,
      storage_gb,
      bandwidth_tb,
      price_per_month,
      stock_available,
      description,
      image_url,
    } = req.body;

    let finalImageUrl = image_url || currentPackage.image_url;

    if (req.file) {
      if (isCloudinaryConfigured) {
        try {
          const uploadResult = await cloudinary.uploader.upload(req.file.path, {
            folder: "servercloud-packages",
            resource_type: "image",
          });
          finalImageUrl = uploadResult.secure_url;
        } catch (uploadErr) {
          console.warn("Cloudinary upload failed, falling back to local storage:", uploadErr);
          finalImageUrl = `/uploads/servers/${req.file.filename}`;
        }
        if (fs.existsSync(req.file.path)) {
          fs.unlinkSync(req.file.path);
        }
      } else {
        finalImageUrl = `/uploads/servers/${req.file.filename}`;
      }
    }

    const slug = name !== currentPackage.name ? generateSlug(name) : currentPackage.slug;

    const result = await pool.query(
      `UPDATE server_packages
       SET category_id = $1,
           name = $2,
           slug = $3,
           cpu_cores = $4,
           ram_gb = $5,
           storage_gb = $6,
           bandwidth_tb = $7,
           price_per_month = $8,
           stock_available = $9,
           image_url = $10,
           description = $11,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $12
       RETURNING *`,
      [
        category_id,
        name,
        slug,
        cpu_cores,
        ram_gb,
        storage_gb,
        bandwidth_tb,
        price_per_month,
        stock_available,
        finalImageUrl,
        description || null,
        packageId,
      ]
    );

    return res.status(200).json({
      success: true,
      message: "Paket server berhasil diperbarui",
      data: result.rows[0],
    });
  } catch (error: any) {
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
    console.error("UPDATE PACKAGE ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Gagal memperbarui paket server",
      error: error.message,
    });
  }
};

export const deletePackage = async (req: Request, res: Response): Promise<any> => {
  try {
    const packageId = parseInt(req.params.id);
    if (isNaN(packageId)) {
      return res.status(400).json({ success: false, message: "ID paket tidak valid" });
    }

    const result = await pool.query(
      "DELETE FROM server_packages WHERE id = $1 RETURNING id, name",
      [packageId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Paket server tidak ditemukan",
      });
    }

    return res.status(200).json({
      success: true,
      message: `Paket '${result.rows[0].name}' berhasil dihapus`,
      data: result.rows[0],
    });
  } catch (error: any) {
    console.error("DELETE PACKAGE ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Gagal menghapus paket server",
      error: error.message,
    });
  }
};
