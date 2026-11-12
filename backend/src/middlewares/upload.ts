import multer from "multer";

const storage = multer.memoryStorage();

const fileFilter = (
  _req: any,
  file: Express.Multer.File,
  cb: multer.FileFilterCallback,
) => {
  const allowedMimeTypes = [
    "image/jpeg",
    "image/png",
    "image/webp",
    "image/jpg",
  ];
  if (allowedMimeTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(
      new Error("Hanya file gambar (JPG, JPEG, PNG, WEBP) yang diperbolehkan!"),
    );
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
