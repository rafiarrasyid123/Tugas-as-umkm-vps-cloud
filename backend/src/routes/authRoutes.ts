import { Router } from "express";
import { register, login, getProfile } from "../controllers/authController.ts";
import { validateBody } from "../middlewares/validate.ts";
import { registerSchema, loginSchema } from "../validators/authValidator.ts";
import { authenticate } from "../middlewares/auth.ts";

const router = Router();

router.post("/register", validateBody(registerSchema), register);
router.post("/login", validateBody(loginSchema), login);
router.get("/profile", authenticate, getProfile);
router.get("/me", authenticate, getProfile);

export default router;
