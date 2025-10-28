import { Context } from "hono";
import { v4 as uuidv4 } from "uuid";
import path from "path";
import { writeFile, mkdir } from "fs/promises";
import { logger } from "../utils/logger";

export class ImageController {
  static async uploadImage(c: Context) {
    try {
      const formData = await c.req.formData();
      const file = formData.get("image") as File | null;

      if (!file) {
        return c.json({ error: "No image file provided" }, 400);
      }

      // Validate file type
      const allowedTypes = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"];
      if (!allowedTypes.includes(file.type)) {
        return c.json({ error: "Invalid image type. Only JPEG, PNG, GIF, and WebP are allowed." }, 400);
      }

      // Create uploads directory if it doesn't exist
      const uploadsDir = path.join(process.cwd(), "public", "uploads");
      await mkdir(uploadsDir, { recursive: true }).catch(() => {
        // Directory might already exist, ignore error
      });

      // Generate unique filename
      const fileExtension = path.extname(file.name) || 
                           (file.type === "image/jpeg" ? ".jpg" : 
                           file.type === "image/png" ? ".png" : 
                           file.type === "image/gif" ? ".gif" : ".webp");
      const fileName = `${uuidv4()}${fileExtension}`;
      const filePath = path.join(uploadsDir, fileName);

      // Convert file to buffer and write to disk
      const arrayBuffer = await file.arrayBuffer();
      const buffer = Buffer.from(arrayBuffer);
      await writeFile(filePath, buffer);

      // Return the URL for the uploaded image
      // Extract the base URL from the request
      const baseUrl = `${c.req.url.split('/api')[0]}`;
      const imageUrl = `${baseUrl}/uploads/${fileName}`;
      
      logger.info("Image uploaded successfully", {
        fileName,
        imageUrl,
        size: file.size,
        type: file.type
      });

      return c.json({ 
        success: true, 
        url: imageUrl,
        fileName 
      }, 201);

    } catch (error: any) {
      logger.error("Error uploading image:", error);
      return c.json({ error: `Failed to upload image: ${error.message}` }, 500);
    }
  }

  static async uploadMultipleImages(c: Context) {
    try {
      const formData = await c.req.formData();
      const files = formData.getAll("images") as File[] | null;

      if (!files || files.length === 0) {
        return c.json({ error: "No image files provided" }, 400);
      }

      if (files.length > 10) {
        return c.json({ error: "Maximum 10 images allowed" }, 400);
      }

      const uploadPromises = files.map(async (file) => {
        // Validate file type
        const allowedTypes = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"];
        if (!allowedTypes.includes(file.type)) {
          throw new Error("Invalid image type. Only JPEG, PNG, GIF, and WebP are allowed.");
        }

        // Create uploads directory if it doesn't exist
        const uploadsDir = path.join(process.cwd(), "public", "uploads");
        await mkdir(uploadsDir, { recursive: true }).catch(() => {
          // Directory might already exist, ignore error
        });

        // Generate unique filename
        const fileExtension = path.extname(file.name) || 
                             (file.type === "image/jpeg" ? ".jpg" : 
                             file.type === "image/png" ? ".png" : 
                             file.type === "image/gif" ? ".gif" : ".webp");
        const fileName = `${uuidv4()}${fileExtension}`;
        const filePath = path.join(uploadsDir, fileName);

        // Convert file to buffer and write to disk
        const arrayBuffer = await file.arrayBuffer();
        const buffer = Buffer.from(arrayBuffer);
        await writeFile(filePath, buffer);

        // Extract the base URL from the request
        const baseUrl = `${c.req.url.split('/api')[0]}`;
        return `${baseUrl}/uploads/${fileName}`;
      });

      try {
        const imageUrls = await Promise.all(uploadPromises);
        
        logger.info("Multiple images uploaded successfully", {
          count: imageUrls.length
        });

        return c.json({ 
          success: true, 
          urls: imageUrls
        }, 201);
      } catch (error: any) {
        return c.json({ error: error.message }, 400);
      }

    } catch (error: any) {
      logger.error("Error uploading multiple images:", error);
      return c.json({ error: "Failed to upload images" }, 500);
    }
  }
}