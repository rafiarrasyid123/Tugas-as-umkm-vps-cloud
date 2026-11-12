import { z } from "zod";

export const packageSchema = z.object({
  category_id: z.coerce
    .number({ required_error: "Kategori wajib dipilih" })
    .int("ID Kategori harus bilangan bulat")
    .positive("Kategori tidak valid"),
  name: z
    .string({ required_error: "Nama paket server wajib diisi" })
    .min(3, "Nama paket minimal 3 karakter")
    .max(150, "Nama paket maksimal 150 karakter"),
  cpu_cores: z.coerce
    .number({ required_error: "Jumlah vCPU wajib diisi" })
    .int("vCPU harus berupa angka bulat")
    .min(1, "Jumlah CPU core minimal 1 core"),
  ram_gb: z.coerce
    .number({ required_error: "Kapasitas RAM wajib diisi" })
    .int("RAM harus berupa angka bulat")
    .min(1, "RAM minimal 1 GB"),
  storage_gb: z.coerce
    .number({ required_error: "Kapasitas storage wajib diisi" })
    .int("Storage harus berupa angka bulat")
    .min(1, "Penyimpanan minimal 1 GB"),
  bandwidth_tb: z.coerce
    .number({ required_error: "Bandwidth wajib diisi" })
    .int("Bandwidth harus berupa angka bulat")
    .min(1, "Bandwidth minimal 1 TB"),
  price_per_month: z.coerce
    .number({ required_error: "Harga sewa bulanan wajib diisi" })
    .min(0, "Harga sewa per bulan tidak boleh negatif"),
  stock_available: z.coerce
    .number()
    .int("Stok harus berupa angka bulat")
    .min(0, "Stok tidak boleh negatif")
    .default(10),
  description: z.string().optional(),
  image_url: z.string().optional(),
});

export type PackageInput = z.infer<typeof packageSchema>;
