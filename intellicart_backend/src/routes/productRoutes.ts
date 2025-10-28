/**
 * Product Routes Module
 *
 * This module defines all product-related API endpoints with proper validation
 * using Zod schemas. Each route is documented with OpenAPI specifications
 * that are automatically generated and displayed in Swagger UI.
 *
 * The routes follow RESTful conventions and include proper HTTP status codes,
 * request validation, and response schemas.
 *
 * @module productRoutes
 * @description API routes for product management
 * @author Intellicart Team
 * @version 1.0.0
 */

import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";
import { verifyToken } from "../middleware/authMiddleware";
import { ProductHandler } from "../handlers/ProductHandler";

export const productRoutes = () => {
  const productRoutes = new OpenAPIHono();

  const ReviewSchema = z.object({
    id: z.number().openapi({
      example: 1,
      description: "Unique identifier for the review (auto-generated)",
    }),
    title: z.string().openapi({
      example: "Great product!",
      description: "Review title",
    }),
    reviewText: z.string().openapi({
      example: "This product is amazing!",
      description: "Review content",
    }),
    rating: z.number().min(1).max(5).openapi({
      example: 5,
      description: "Rating from 1 to 5",
    }),
    timeAgo: z.string().openapi({
      example: "2 days ago",
      description: "Time string (e.g., '2 days ago', 'Just now')",
    }),
    images: z.array(z.string()).max(10, { message: "Maximum 10 images allowed" }).optional().nullable().openapi({
      example: ["https://example.com/image1.jpg", "https://example.com/image2.jpg", "/path/to/local/image.jpg"],
      description: "Array of image URLs or file paths for the review (optional, max 10)",
    }),
    userId: z.number().optional().openapi({
      example: 1,
      description: "ID of the user who submitted the review (optional)",
    }),
  });

  const AddReviewSchema = z.object({
    title: z
      .string()
      .min(1, { message: "Title is required" })
      .max(100, { message: "Title cannot exceed 100 characters" })
      .openapi({
        example: "Great product!",
        description: "Review title (required, 1-100 characters)",
      }),
    reviewText: z
      .string()
      .min(1, { message: "Review text is required" })
      .max(1000, { message: "Review text cannot exceed 1000 characters" })
      .openapi({
        example: "This product is amazing!",
        description: "Review content (required, 1-1000 characters)",
      }),
    rating: z
      .number()
      .int()
      .min(1, { message: "Rating must be at least 1" })
      .max(5, { message: "Rating must be at most 5" })
      .openapi({
        example: 5,
        description: "Rating from 1 to 5 (required)",
      }),
    images: z.array(z.string()).max(10, { message: "Maximum 10 images allowed" }).optional().nullable().openapi({
      example: ["https://example.com/image1.jpg", "https://example.com/image2.jpg", "/path/to/local/image.jpg"],
      description: "Array of image URLs or file paths for the review (optional, max 10)",
    }),
  });

  const ProductSchema = z.object({
    id: z.number().openapi({
      example: 1,
      description: "Unique identifier for the product (auto-generated)",
    }),
    name: z.string().openapi({
      example: "Wireless Headphones",
      description: "Product's name",
    }),
    description: z.string().openapi({
      example: "High-quality wireless headphones with noise cancellation",
      description: "Product's description",
    }),
    price: z.string().openapi({
      example: "$99.99",
      description: "Product's price",
    }),
    originalPrice: z.string().optional().openapi({
      example: "$129.99",
      description: "Product's original price (optional, for discount display)",
    }),
    imageUrl: z.string().url().openapi({
      example: "https://example.com/product-image.jpg",
      description: "Product's image URL",
    }),
    reviews: z.array(ReviewSchema).optional().openapi({
      description: "Product's reviews",
    }),
    sellerId: z.number().openapi({
      example: 1,
      description: "ID of the seller who added this product",
    }),
    createdAt: z.string().datetime().optional().openapi({
      example: new Date().toISOString(),
      description: "Timestamp when the product was created",
    }),
  });

  const CreateProductSchema = z.object({
    name: z.string().min(1, { message: "Name is required" }).openapi({
      example: "Wireless Headphones",
      description: "Product's name (required, minimum 1 character)",
    }),
    description: z
      .string()
      .min(1, { message: "Description is required" })
      .openapi({
        example: "High-quality wireless headphones with noise cancellation",
        description: "Product's description (required)",
      }),
    price: z.string().min(1, { message: "Price is required" }).openapi({
      example: "$99.99",
      description: "Product's price (required)",
    }),
    originalPrice: z.string().optional().openapi({
      example: "$129.99",
      description: "Product's original price (optional, for discount display)",
    }),
    imageUrl: z.string().url({ message: "Must be a valid URL" }).openapi({
      example: "https://example.com/product-image.jpg",
      description: "Product's image URL (required, must be valid URL)",
    }),
  });

  const UpdateProductSchema = z.object({
    name: z
      .string()
      .min(1, { message: "Name must be at least 1 character" })
      .optional()
      .openapi({
        example: "Wireless Headphones",
        description:
          "Product's name (optional, minimum 1 character if provided)",
      }),
    description: z.string().optional().openapi({
      example: "High-quality wireless headphones with noise cancellation",
      description: "Product's description (optional)",
    }),
    price: z.string().optional().openapi({
      example: "$99.99",
      description: "Product's price (optional)",
    }),
    originalPrice: z.string().optional().openapi({
      example: "$129.99",
      description: "Product's original price (optional, for discount display)",
    }),
    imageUrl: z
      .string()
      .url({ message: "Must be a valid URL" })
      .optional()
      .openapi({
        example: "https://example.com/product-image.jpg",
        description:
          "Product's image URL (optional, must be valid URL if provided)",
      }),
    reviews: z.array(z.any()).optional().openapi({
      description: "Product's reviews (optional)",
    }),
  });

  const getAllProductsRoute = createRoute({
    method: "get",
    path: "",
    tags: ["Products"],
    responses: {
      200: {
        description: "Returns all products in the system",
        content: {
          "application/json": {
            schema: z.array(ProductSchema),
          },
        },
      },
    },
  });

  productRoutes.openapi(
    getAllProductsRoute,
    (c) => ProductHandler.getAllProducts(c) as any,
  );

  const getProductByIdRoute = createRoute({
    method: "get",
    path: "/{id}",
    tags: ["Products"],
    request: {
      params: z.object({
        id: z
          .string()
          .regex(/^\d+$/, { message: "ID must be a positive number" })
          .transform(Number)
          .openapi({
            example: 1,
            description: "Unique identifier of the product to retrieve",
          }),
      }),
    },
    responses: {
      200: {
        description: "Returns the requested product by ID",
        content: {
          "application/json": {
            schema: ProductSchema,
          },
        },
      },
      404: {
        description: "Product with the specified ID was not found",
        content: {
          "application/json": {
            schema: z.object({
              error: z.string().openapi({
                example: "Product not found",
                description: "Error message explaining why the request failed",
              }),
            }),
          },
        },
      },
    },
  });

  productRoutes.openapi(getProductByIdRoute, (c) =>
    ProductHandler.getProductById(c),
  );

  const createProductRoute = createRoute({
    method: "post",
    path: "",
    tags: ["Products"],
    security: [{ BearerAuth: [] }],
    request: {
      body: {
        content: {
          "application/json": {
            schema: CreateProductSchema,
          },
        },
      },
    },
    responses: {
      201: {
        description: "Product created successfully",
        content: {
          "application/json": {
            schema: ProductSchema,
          },
        },
      },
    },
  });

  productRoutes.openapi(createProductRoute, async (c) => {
    await verifyToken(c, async () => {});
    return (await ProductHandler.createProduct(c)) as any;
  });

  const updateProductRoute = createRoute({
    method: "put",
    path: "/{id}",
    tags: ["Products"],
    security: [{ BearerAuth: [] }],
    request: {
      params: z.object({
        id: z
          .string()
          .regex(/^\d+$/, { message: "ID must be a positive number" })
          .transform(Number)
          .openapi({
            example: 1,
            description: "Unique identifier of the product to update",
          }),
      }),
      body: {
        content: {
          "application/json": {
            schema: UpdateProductSchema,
          },
        },
      },
    },
    responses: {
      200: {
        description: "Product updated successfully",
        content: {
          "application/json": {
            schema: ProductSchema,
          },
        },
      },
      404: {
        description: "Product with the specified ID was not found",
        content: {
          "application/json": {
            schema: z.object({
              error: z.string().openapi({
                example: "Product not found",
                description: "Error message explaining why the request failed",
              }),
            }),
          },
        },
      },
    },
  });

  productRoutes.openapi(updateProductRoute, async (c) => {
    await verifyToken(c, async () => {});
    return await ProductHandler.updateProduct(c);
  });

  const deleteProductRoute = createRoute({
    method: "delete",
    path: "/{id}",
    tags: ["Products"],
    security: [{ BearerAuth: [] }],
    request: {
      params: z.object({
        id: z
          .string()
          .regex(/^\d+$/, { message: "ID must be a positive number" })
          .transform(Number)
          .openapi({
            example: 1,
            description: "Unique identifier of the product to delete",
          }),
      }),
    },
    responses: {
      200: {
        description: "Product deleted successfully",
        content: {
          "application/json": {
            schema: z.object({
              message: z.string().openapi({
                example: "Product deleted successfully",
                description: "Confirmation message",
              }),
              item: ProductSchema,
            }),
          },
        },
      },
      404: {
        description: "Product with the specified ID was not found",
        content: {
          "application/json": {
            schema: z.object({
              error: z.string().openapi({
                example: "Product not found",
                description: "Error message explaining why the request failed",
              }),
            }),
          },
        },
      },
    },
  });

  productRoutes.openapi(deleteProductRoute, async (c) => {
    await verifyToken(c, async () => {});
    return await ProductHandler.deleteProduct(c);
  });

  const getSellerProductsRoute = createRoute({
    method: "get",
    path: "/seller/{sellerId}",
    tags: ["Products"],
    security: [{ BearerAuth: [] }],
    request: {
      params: z.object({
        sellerId: z
          .string()
          .regex(/^\d+$/, { message: "Seller ID must be a positive number" })
          .transform(Number)
          .openapi({
            example: 1,
            description: "Unique identifier of the seller",
          }),
      }),
    },
    responses: {
      200: {
        description: "Returns all products created by the specified seller",
        content: {
          "application/json": {
            schema: z.array(ProductSchema),
          },
        },
      },
    },
  });

  productRoutes.openapi(getSellerProductsRoute, async (c) => {
    await verifyToken(c, async () => {});
    return (await ProductHandler.getSellerProducts(c)) as any;
  });

  const addReviewRoute = createRoute({
    method: "post",
    path: "/{id}/reviews",
    tags: ["Products"],
    security: [{ BearerAuth: [] }],
    summary: "Add a review to a product",
    request: {
      params: z.object({
        id: z
          .string()
          .regex(/^\d+$/, { message: "Product ID must be a positive number" })
          .transform(Number)
          .openapi({
            param: { name: "id", in: "path" },
            example: 1,
            description: "Unique identifier of the product to review",
          }),
      }),
      body: {
        content: {
          "application/json": {
            schema: AddReviewSchema,
          },
        },
        description: "Review data (title, text, rating)",
        required: true,
      },
    },
    responses: {
      201: {
        description: "Review added successfully",
        content: {
          "application/json": {
            schema: z.object({
              message: z.string().openapi({
                example: "Review added successfully",
                description: "Success message",
              }),
              review: ReviewSchema,
            }),
          },
        },
      },
      400: {
        description: "Invalid input data",
        content: {
          "application/json": {
            schema: z.object({
              error: z.string().openapi({
                example: "Title, reviewText, and rating (1-5) are required",
              }),
            }),
          },
        },
      },
      404: {
        description: "Product not found",
        content: {
          "application/json": {
            schema: z.object({
              error: z.string().openapi({ example: "Product not found" }),
            }),
          },
        },
      },
    },
  });

  productRoutes.openapi(addReviewRoute, async (c) => {
    await verifyToken(c, async () => {});
    return await ProductHandler.addReview(c);
  });

  return productRoutes;
};
