import { z } from "zod";

export const categorySchema = z.object({
  name: z
    .string({ required_error: "Nama kategori wajib diisi" })
    .min(2, "Nama kategori minimal 2 karakter")
    .max(100, "Nama kategori maksimal 100 karakter"),
  description: z.string().optional(),
});

export type CategoryInput = z.infer<typeof categorySchema>;
