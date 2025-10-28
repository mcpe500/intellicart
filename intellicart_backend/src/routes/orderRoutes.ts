/**
 * Order Routes Module
 *
 * This module defines all order-related API endpoints with proper validation
 * using Zod schemas. Each route is documented with OpenAPI specifications
 * that are automatically generated and displayed in Swagger UI.
 *
 * The routes follow RESTful conventions and include proper HTTP status codes,
 * request validation, and response schemas.
 *
 * @module orderRoutes
 * @description API routes for order management
 * @author Intellicart Team
 * @version 1.0.0
 */

import { OpenAPIHono, createRoute, z } from "@hono/zod-openapi";
import { zValidator } from "@hono/zod-validator";
import { verifyToken } from "../middleware/authMiddleware";
import { OrderHandler } from "../handlers/OrderHandler";

/**
 * Create a new OpenAPIHono instance for order routes
 * This allows automatic OpenAPI documentation generation from Zod schemas
 */
const orderRoutes = new OpenAPIHono();

/**
 * Zod schema defining the structure of an Order object
 * This schema is used for both request and response validation
 */
const OrderSchema = z.object({
  // Unique identifier for the order (auto-generated)
  id: z.number().openapi({
    example: 1,
    description: "Unique identifier for the order (auto-generated)",
  }),

  // Customer's name (required)
  customerName: z.string().openapi({
    example: "John Doe",
    description: "Customer's name",
  }),

  // Order's items (required)
  items: z
    .array(
      z.object({
        id: z.number().openapi({ example: 1 }),
        name: z.string().openapi({ example: "Wireless Headphones" }),
        description: z
          .string()
          .openapi({ example: "High-quality wireless headphones" }),
        price: z.string().openapi({ example: "$99.99" }),
        originalPrice: z.string().optional().openapi({ example: "$129.99" }),
        imageUrl: z
          .string()
          .url()
          .openapi({ example: "https://example.com/image.jpg" }),
        reviews: z
          .array(
            z.object({
              id: z.number().openapi({ example: 1 }),
              title: z.string().openapi({ example: "Great product!" }),
              reviewText: z
                .string()
                .openapi({ example: "This product is amazing!" }),
              rating: z.number().min(1).max(5).openapi({ example: 5 }),
              timeAgo: z.string().openapi({ example: "2 days ago" }),
            }),
          )
          .optional()
          .openapi({
            description: "Product's reviews",
          }),
        sellerId: z.number().openapi({ example: 1 }),
      }),
    )
    .openapi({
      description: "Order's items",
    }),

  // Order's total amount (required)
  total: z.number().openapi({
    example: 129.98,
    description: "Order's total amount",
  }),

  // Order's status (required)
  status: z.string().openapi({
    example: "Delivered",
    description: "Order's status (e.g., Pending, Shipped, Delivered)",
  }),

  // Order date (required)
  orderDate: z.string().datetime().openapi({
    example: new Date().toISOString(),
    description: "Order's creation date",
  }),

  // Seller ID (required, for associating orders with sellers)
  sellerId: z.number().openapi({
    example: 1,
    description: "ID of the seller associated with this order",
  }),

  // Creation timestamp (auto-generated)
  createdAt: z.string().datetime().optional().openapi({
    example: new Date().toISOString(),
    description: "Timestamp when the order was created",
  }),
});

/**
 * Zod schema defining the structure for updating an order status
 * Used for validation of PUT /api/orders/:id/status request body
 */
const UpdateOrderStatusSchema = z.object({
  // New status for the order (required)
  status: z.string().openapi({
    example: "Shipped",
    description: "New status for the order (e.g., Pending, Shipped, Delivered)",
  }),
});

/**
 * Route: GET /api/orders
 * Description: Retrieve orders for the authenticated seller
 *
 * Request:
 * - Method: GET
 * - Path: / (relative to /api/orders)
 * - Headers: Authorization: Bearer <token>
 * - Parameters: None
 * - Query: None
 * - Body: None
 *
 * Response:
 * - Status: 200 OK
 * - Content-Type: application/json
 * - Body: Array of Order objects
 */
const getSellerOrdersRoute = createRoute({
  method: "get",
  path: "/",
  tags: ["Orders"], // Add tags for grouping in Swagger UI
  security: [{ BearerAuth: [] }], // Require authentication
  // Documentation for the successful response
  responses: {
    200: {
      description: "Returns all orders for the authenticated seller",
      content: {
        "application/json": {
          // Response body schema
          schema: z.array(OrderSchema),
        },
      },
    },
  },
});

// Register the route with authentication middleware
orderRoutes.openapi(getSellerOrdersRoute, async (c) => {
  await verifyToken(c, async () => {});
  return OrderHandler.getSellerOrders(c);
});

/**
 * Route: PUT /api/orders/:id/status
 * Description: Update the status of an order
 *
 * Request:
 * - Method: PUT
 * - Path: /:id/status
 * - Headers: Authorization: Bearer <token>
 * - Parameters: id (number, required)
 * - Query: None
 * - Body: Status update object (validated against UpdateOrderStatusSchema)
 *
 * Response:
 * - Status: 200 OK
 * - Content-Type: application/json
 * - Body: Updated Order object
 */
const updateOrderStatusRoute = createRoute({
  method: "put",
  path: "/{id}/status",
  tags: ["Orders"], // Add tags for grouping in Swagger UI
  security: [{ BearerAuth: [] }], // Require authentication
  // Validate request parameters and body
  request: {
    params: z.object({
      // ID parameter: string that matches numeric pattern, transformed to number
      id: z
        .string()
        .regex(/^\d+$/, { message: "ID must be a positive number" })
        .transform(Number)
        .openapi({
          example: 1,
          description: "Unique identifier of the order to update",
        }),
    }),
    body: {
      content: {
        "application/json": {
          // Request body schema
          schema: UpdateOrderStatusSchema,
        },
      },
    },
  },
  // Documentation for possible responses
  responses: {
    200: {
      description: "Order status updated successfully",
      content: {
        "application/json": {
          // Response body schema
          schema: OrderSchema,
        },
      },
    },
    404: {
      description: "Order with the specified ID was not found",
      content: {
        "application/json": {
          // Error response schema
          schema: z.object({
            error: z.string().openapi({
              example: "Order not found",
              description: "Error message explaining why the request failed",
            }),
          }),
        },
      },
    },
  },
});

// Register the route with authentication middleware
orderRoutes.openapi(updateOrderStatusRoute, async (c) => {
  await verifyToken(c, async () => {});
  return OrderHandler.updateOrderStatus(c);
});

// Export the configured routes for use in the main application
export { orderRoutes };
