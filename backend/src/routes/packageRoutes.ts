import { Router } from "express";
import {
  getAllPackages,
  getPackageById,
  createPackage,
  updatePackage,
  deletePackage,
} from "../controllers/packageController.ts";
import { authenticate, authorizeRoles } from "../middlewares/auth.ts";
import { uploadServerBanner } from "../middlewares/upload.ts";
import { validateBody } from "../middlewares/validate.ts";
import { packageSchema } from "../validators/packageValidator.ts";

const router = Router();

router.get("/", getAllPackages);
router.get("/:id", getPackageById);

// Admin Only Routes (with image upload + zod validation)
router.post(
  "/",
  authenticate,
  authorizeRoles("admin"),
  uploadServerBanner.single("image"),
  validateBody(packageSchema),
  createPackage
);

router.put(
  "/:id",
  authenticate,
  authorizeRoles("admin"),
  uploadServerBanner.single("image"),
  validateBody(packageSchema),
  updatePackage
);

router.delete("/:id", authenticate, authorizeRoles("admin"), deletePackage);

export default router;
