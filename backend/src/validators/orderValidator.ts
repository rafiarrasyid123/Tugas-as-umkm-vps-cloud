import { z } from "zod";

export const createOrderSchema = z.object({
  package_id: z.coerce
    .number({ required_error: "ID paket server wajib diisi" })
    .int("ID paket harus berupa bilangan bulat")
    .positive("ID paket tidak valid"),
  duration_months: z.coerce
    .number()
    .int("Durasi sewa harus berupa angka bulan")
    .min(1, "Durasi sewa minimal 1 bulan")
    .max(36, "Durasi sewa maksimal 36 bulan")
    .default(1),
  payment_method: z
    .enum(["bca_va", "mandiri_va", "bni_va", "bri_va", "qris"])
    .default("bca_va"),
});

export type CreateOrderInput = z.infer<typeof createOrderSchema>;
