import { z } from "zod";

export const registerSchema = z.object({
  full_name: z
    .string({ required_error: "Nama lengkap wajib diisi" })
    .min(3, "Nama lengkap minimal 3 karakter")
    .max(100, "Nama lengkap maksimal 100 karakter"),
  email: z
    .string({ required_error: "Email wajib diisi" })
    .email("Format email tidak valid"),
  password: z
    .string({ required_error: "Password wajib diisi" })
    .min(6, "Password minimal 6 karakter"),
  role: z.enum(["admin", "client"]).default("client").optional(),
  phone: z.string().max(30).optional(),
});

export const loginSchema = z.object({
  email: z
    .string({ required_error: "Email wajib diisi" })
    .email("Format email tidak valid"),
  password: z
    .string({ required_error: "Password wajib diisi" })
    .min(1, "Password tidak boleh kosong"),
});

export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
