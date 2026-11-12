import { type Request, type Response, type NextFunction } from "express";
import { ZodError, type ZodSchema } from "zod";

export const validateBody = (schema: ZodSchema) => {
  return async (req: Request, res: Response, next: NextFunction): Promise<any> => {
    try {
      req.body = await schema.parseAsync(req.body);
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const formattedErrors = error.errors.map((err) => ({
          field: err.path.join("."),
          message: err.message,
        }));

        return res.status(400).json({
          success: false,
          message: "Validasi data gagal",
          errors: formattedErrors,
        });
      }
      return res.status(400).json({
        success: false,
        message: "Data yang dikirim tidak valid",
      });
    }
  };
};
