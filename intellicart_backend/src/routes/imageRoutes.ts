import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";
import { verifyToken } from "../middleware/authMiddleware";
import { ImageController } from "../controllers/ImageController";

export const imageRoutes = () => {
  const imageRoutes = new OpenAPIHono();

  const ImageUploadResponseSchema = z.object({
    success: z.boolean().openapi({
      example: true,
      description: "Indicates if the upload was successful",
    }),
    url: z.string().url().openapi({
      example: "http://localhost:3000/uploads/filename.jpg",
      description: "URL of the uploaded image",
    }),
    fileName: z.string().openapi({
      example: "filename.jpg",
      description: "Name of the uploaded file",
    }),
  });

  const MultipleImageUploadResponseSchema = z.object({
    success: z.boolean().openapi({
      example: true,
      description: "Indicates if the upload was successful",
    }),
    urls: z.array(z.string().url()).openapi({
      example: [
        "http://localhost:3000/uploads/filename1.jpg",
        "http://localhost:3000/uploads/filename2.jpg"
      ],
      description: "URLs of the uploaded images",
    }),
  });

  const uploadImageRoute = createRoute({
    method: "post",
    path: "/upload",
    tags: ["Images"],
    security: [{ BearerAuth: [] }],
    summary: "Upload a single image",
    description: "Upload an image file and get back a URL to access it",
    responses: {
      201: {
        description: "Image uploaded successfully",
        content: {
          "application/json": {
            schema: ImageUploadResponseSchema,
          },
        },
      },
      400: {
        description: "Invalid image file or type",
        content: {
          "application/json": {
            schema: z.object({
              error: z.string().openapi({
                example: "No image file provided",
              }),
            }),
          },
        },
      },
    },
  });

  imageRoutes.openapi(uploadImageRoute, async (c) => {
    await verifyToken(c, async () => {});
    return await ImageController.uploadImage(c);
  });

  const uploadMultipleImagesRoute = createRoute({
    method: "post",
    path: "/upload-multiple",
    tags: ["Images"],
    security: [{ BearerAuth: [] }],
    summary: "Upload multiple images",
    description: "Upload multiple image files and get back URLs for each",
    responses: {
      201: {
        description: "Images uploaded successfully",
        content: {
          "application/json": {
            schema: MultipleImageUploadResponseSchema,
          },
        },
      },
      400: {
        description: "Invalid image files or too many files",
        content: {
          "application/json": {
            schema: z.object({
              error: z.string().openapi({
                example: "Maximum 10 images allowed",
              }),
            }),
          },
        },
      },
    },
  });

  imageRoutes.openapi(uploadMultipleImagesRoute, async (c) => {
    await verifyToken(c, async () => {});
    return await ImageController.uploadMultipleImages(c);
  });

  return imageRoutes;
};