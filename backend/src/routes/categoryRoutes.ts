import { Router } from "express";
import {
  getAllCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
} from "../controllers/categoryController.ts";
import { authenticate, authorizeRoles } from "../middlewares/auth.ts";
import { validateBody } from "../middlewares/validate.ts";
import { categorySchema } from "../validators/categoryValidator.ts";

const router = Router();

router.get("/", getAllCategories);
router.get("/:id", getCategoryById);

// Admin Only Routes
router.post(
  "/",
  authenticate,
  authorizeRoles("admin"),
  validateBody(categorySchema),
  createCategory
);

router.put(
  "/:id",
  authenticate,
  authorizeRoles("admin"),
  validateBody(categorySchema),
  updateCategory
);

router.delete("/:id", authenticate, authorizeRoles("admin"), deleteCategory);

export default router;
