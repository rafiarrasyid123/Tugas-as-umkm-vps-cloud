import { Router } from "express";
import { register, login, getProfile, updateProfile } from "../controllers/authController.ts";
import { validateBody } from "../middlewares/validate.ts";
import { registerSchema, loginSchema } from "../validators/authValidator.ts";
import { authenticate } from "../middlewares/auth.ts";
import { uploadServerBanner } from "../middlewares/upload.ts";

const router = Router();

router.post("/register", validateBody(registerSchema), register);
router.post("/login", validateBody(loginSchema), login);
router.get("/profile", authenticate, getProfile);
router.get("/me", authenticate, getProfile);
router.put("/profile", authenticate, uploadServerBanner.single("avatar"), updateProfile);

export default router;
