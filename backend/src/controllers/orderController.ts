import { type Request, type Response } from "express";
import pool from "../config/db.ts";

export const createOrder = async (req: Request, res: Response): Promise<any> => {
  try {
    const userId = (req as any).user?.id;
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Pengguna tidak terautentikasi",
      });
    }

    const { package_id, duration_months = 1, payment_method = "bca_va" } = req.body;

    // 1. Cek keberadaan paket dan stok
    const packageRes = await pool.query(
      "SELECT * FROM server_packages WHERE id = $1",
      [package_id]
    );

    if (packageRes.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Paket server tidak ditemukan",
      });
    }

    const serverPkg = packageRes.rows[0];

    if (serverPkg.stock_available <= 0) {
      return res.status(400).json({
        success: false,
        message: "Stok paket server sedang habis",
      });
    }

    // 2. Hitung total harga sewa
    const pricePerMonth = parseFloat(serverPkg.price_per_month);
    const totalPrice = (pricePerMonth * duration_months).toFixed(2);

    // 3. Generate nomor invoice & kode bayar VA
    const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, "");
    const randomSuffix = Math.floor(1000 + Math.random() * 9000);
    const orderNumber = `SC-INV-${dateStr}-${randomSuffix}`;
    const paymentCode = `88012${Math.floor(10000000 + Math.random() * 90000000)}`;

    // 4. Simpan ke database dalam transaksi
    const client = await pool.connect();
    try {
      await client.query("BEGIN");

      // Insert Order
      const insertRes = await client.query(
        `INSERT INTO orders (
          order_number, user_id, package_id, duration_months,
          total_price, status, payment_method, payment_code
        ) VALUES ($1, $2, $3, $4, $5, 'pending', $6, $7)
        RETURNING *`,
        [
          orderNumber,
          userId,
          package_id,
          duration_months,
          totalPrice,
          payment_method,
          paymentCode,
        ]
      );

      // Kurangi stok paket 1 unit
      await client.query(
        "UPDATE server_packages SET stock_available = stock_available - 1 WHERE id = $1",
        [package_id]
      );

      await client.query("COMMIT");

      return res.status(201).json({
        success: true,
        message: "Pesanan sewa berhasil dibuat",
        data: {
          ...insertRes.rows[0],
          package_name: serverPkg.name,
          package_image: serverPkg.image_url,
        },
      });
    } catch (err) {
      await client.query("ROLLBACK");
      throw err;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("Error creating order:", error);
    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan server saat membuat pesanan",
    });
  }
};

export const getMyOrders = async (req: Request, res: Response): Promise<any> => {
  try {
    const userId = (req as any).user?.id;
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Pengguna tidak terautentikasi",
      });
    }

    const result = await pool.query(
      `SELECT 
        o.*,
        p.name AS package_name,
        p.cpu_cores,
        p.ram_gb,
        p.storage_gb,
        p.bandwidth_tb,
        p.image_url AS package_image,
        c.name AS category_name
       FROM orders o
       JOIN server_packages p ON o.package_id = p.id
       JOIN service_categories c ON p.category_id = c.id
       WHERE o.user_id = $1
       ORDER BY o.created_at DESC`,
      [userId]
    );

    return res.status(200).json({
      success: true,
      message: "Berhasil mengambil riwayat pesanan sewa",
      total: result.rows.length,
      data: result.rows,
    });
  } catch (error) {
    console.error("Error fetching my orders:", error);
    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan server",
    });
  }
};

export const getOrderById = async (req: Request, res: Response): Promise<any> => {
  try {
    const user = (req as any).user;
    const orderId = parseInt(String(req.params.id));

    if (isNaN(orderId)) {
      return res.status(400).json({
        success: false,
        message: "ID pesanan tidak valid",
      });
    }

    const result = await pool.query(
      `SELECT 
        o.*,
        p.name AS package_name,
        p.cpu_cores,
        p.ram_gb,
        p.storage_gb,
        p.bandwidth_tb,
        p.image_url AS package_image,
        c.name AS category_name,
        u.full_name AS client_name,
        u.email AS client_email,
        u.phone AS client_phone
       FROM orders o
       JOIN server_packages p ON o.package_id = p.id
       JOIN service_categories c ON p.category_id = c.id
       JOIN users u ON o.user_id = u.id
       WHERE o.id = $1`,
      [orderId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Pesanan tidak ditemukan",
      });
    }

    const order = result.rows[0];

    // Otorisasi: hanya pemilik pesanan atau admin yang boleh melihat
    if (user.role !== "admin" && order.user_id !== user.id) {
      return res.status(403).json({
        success: false,
        message: "Akses ditolak: Anda tidak memiliki izin untuk pesanan ini",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Detail pesanan berhasil diambil",
      data: order,
    });
  } catch (error) {
    console.error("Error getting order by id:", error);
    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan server",
    });
  }
};

export const payOrder = async (req: Request, res: Response): Promise<any> => {
  try {
    const user = (req as any).user;
    const orderId = parseInt(String(req.params.id));

    if (isNaN(orderId)) {
      return res.status(400).json({
        success: false,
        message: "ID pesanan tidak valid",
      });
    }

    const checkRes = await pool.query("SELECT * FROM orders WHERE id = $1", [orderId]);
    if (checkRes.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Pesanan tidak ditemukan",
      });
    }

    const order = checkRes.rows[0];

    // Cek otorisasi
    if (user.role !== "admin" && order.user_id !== user.id) {
      return res.status(403).json({
        success: false,
        message: "Akses ditolak: Anda tidak berhak membayar pesanan ini",
      });
    }

    if (order.status === "active") {
      return res.status(400).json({
        success: false,
        message: "Pesanan ini sudah lunas dan server sudah aktif",
      });
    }

    // Alokasi IP Address server fiktif
    const serverIp = `103.187.${Math.floor(10 + Math.random() * 80)}.${Math.floor(2 + Math.random() * 250)}`;

    const updateRes = await pool.query(
      `UPDATE orders
       SET status = 'active',
           paid_at = NOW(),
           server_ip = $1
       WHERE id = $2
       RETURNING *`,
      [serverIp, orderId]
    );

    return res.status(200).json({
      success: true,
      message: "Pembayaran berhasil diverifikasi. Server cloud Anda telah aktif!",
      data: updateRes.rows[0],
    });
  } catch (error) {
    console.error("Error paying order:", error);
    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan server saat memproses pembayaran",
    });
  }
};

export const getAllOrders = async (req: Request, res: Response): Promise<any> => {
  try {
    const result = await pool.query(
      `SELECT 
        o.*,
        p.name AS package_name,
        p.cpu_cores,
        p.ram_gb,
        p.storage_gb,
        p.bandwidth_tb,
        u.full_name AS client_name,
        u.email AS client_email,
        c.name AS category_name
       FROM orders o
       JOIN server_packages p ON o.package_id = p.id
       JOIN service_categories c ON p.category_id = c.id
       JOIN users u ON o.user_id = u.id
       ORDER BY o.created_at DESC`
    );

    return res.status(200).json({
      success: true,
      message: "Seluruh riwayat transaksi berhasil diambil",
      total: result.rows.length,
      data: result.rows,
    });
  } catch (error) {
    console.error("Error getting all orders:", error);
    return res.status(500).json({
      success: false,
      message: "Terjadi kesalahan server",
    });
  }
};
