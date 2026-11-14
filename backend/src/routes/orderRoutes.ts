import { Router } from "express";
import {
  createOrder,
  getMyOrders,
  getOrderById,
  payOrder,
  getAllOrders,
} from "../controllers/orderController.ts";
import { authenticate, authorizeRoles } from "../middlewares/auth.ts";
import { validateBody } from "../middlewares/validate.ts";
import { createOrderSchema } from "../validators/orderValidator.ts";

const router = Router();

// Semua rute order wajib login (memiliki Bearer token JWT)
router.use(authenticate);

// Client: Buat pesanan baru
router.post("/", validateBody(createOrderSchema), createOrder);

// Client: Ambil daftar server/pesanan saya
router.get("/my-orders", getMyOrders);

// Admin: Ambil semua pesanan dari semua client
router.get("/", authorizeRoles("admin"), getAllOrders);

// Ambil detail satu pesanan
router.get("/:id", getOrderById);

// Simulasi pelunasan / bayar pesanan
router.patch("/:id/pay", payOrder);

export default router;
