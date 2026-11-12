import multer from "multer";
import path from "path";
import fs from "fs";

const uploadDir = path.resolve("uploads/servers");

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, uploadDir);
  },
  filename: (_req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `server-${uniqueSuffix}${ext}`);
  },
});

const fileFilter = (
  _req: any,
  file: Express.Multer.File,
  cb: multer.FileFilterCallback
) => {
  const allowedMimeTypes = ["image/jpeg", "image/png", "image/webp", "image/jpg"];
  if (allowedMimeTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error("Hanya file gambar (JPG, JPEG, PNG, WEBP) yang diperbolehkan!"));
  }
};

export const uploadServerBanner = multer({
  storage,
  limits: {
    fileSize: 2 * 1024 * 1024, // Maksimal 2MB sesuai rubrik penilaian
  },
  fileFilter,
});

export default uploadServerBanner;
