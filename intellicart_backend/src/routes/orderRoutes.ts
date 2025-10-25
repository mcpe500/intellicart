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

import { OpenAPIHono, createRoute, z } from '@hono/zod-openapi';
import { verifyToken } from '../middleware/authMiddleware';

/**
 * Create a new OpenAPIHono instance for order routes
 * This allows automatic OpenAPI documentation generation from Zod schemas
 */
const orderRoutes = new OpenAPIHono();

// Mock data for orders (in a real app, this would be a database)
let orders: Array<{
  id: number;
  customerName: string;
  items: Array<{
    id: number;
    name: string;
    description: string;
    price: string;
    originalPrice?: string;
    imageUrl: string;
    reviews: Array<{
      id: number;
      title: string;
      reviewText: string;
      rating: number;
      timeAgo: string;
    }>;
    sellerId: number;
  }>;
  total: number;
  status: string; // e.g., "Pending", "Shipped", "Delivered"
  orderDate: string;
  sellerId: number; // ID of the seller associated with this order
}> = [
  {
    id: 1,
    customerName: 'John Doe',
    items: [
      {
        id: 1,
        name: 'Stylish Headphones',
        description: 'For immersive audio',
        price: '$49.99',
        originalPrice: '$60.00',
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDMDDt1s-XFmFZSH0ueZa_h2OY0-wSr0PwaY4s6z7CWYwY15RQ84AFwOUPae2BDOXI73lUD5rch6jWyiRaX4V84CzDJNkS3ZrCKWSrXRRGo1kJXmnoyVW2LqNBZ62Uf7k5j3ekVHTTDd6a5cxMqwDbZ1UGyXbMrEAX8U-B1hVJpAuVefrbzAd3ewrAojReuO9pG2MmbKxoYD4oiedLQvR5H7RKR-8vKdVE0NJSNpysXDQ4BgY0CwHSmFB99DMdnU6fIGsftaer72icT',
        reviews: [
          {
            id: 1,
            title: 'Absolutely beautiful!',
            reviewText: "The quality is amazing, and the sound is so immersive. It's the perfect size and looks even better in person.",
            rating: 5,
            timeAgo: '2 days ago',
          },
          {
            id: 2,
            title: 'Great headphones, but a bit tight.',
            reviewText: "I love the design and the material. It's a bit tight at first, but I'm sure it will loosen up with use. Very happy with my purchase.",
            rating: 4,
            timeAgo: '1 week ago',
          },
        ],
        sellerId: 2,
      },
      {
        id: 2,
        name: 'Wireless Earbuds',
        description: 'Compact and convenient',
        price: '$79.99',
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAU7U_kS6_gA60CXLu3bQedKs7gieDR-Od4nf01tYU1wiMTn7rnT9gQjZJrXCWSbd3qSnnAb4ohNgEe6Rqkme_SFVx3pdpdg7dDl2RXverxSCbNfl06zi79wznmywgEy2tjT0vzBqLgdBrNAeOzxMZTVrYva74Y2ClHL8Nm9HUM4xqsf_MkIdsQAJntvJyEyYwBki7Vsq1huMtI8DDohIKbLItAlgtMAfQNC14jLnulQjuc74GOglQOVmneWnEV6ieRiEQrTXOZM_Sr',
        reviews: [
          {
            id: 1,
            title: 'Fantastic sound!',
            reviewText: "These earbuds have incredible sound quality for their size. The battery life is also impressive.",
            rating: 5,
            timeAgo: '5 days ago',
          },
        ],
        sellerId: 2,
      },
    ],
    total: 129.98,
    status: 'Delivered',
    orderDate: new Date().toISOString(),
    sellerId: 2, // This order belongs to seller id 2
  },
  {
    id: 2,
    customerName: 'Jane Smith',
    items: [
      {
        id: 3,
        name: 'Smartwatch Series 7',
        description: 'Track your fitness',
        price: '$199.99',
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBlvRiH9bIWU65_lBYwcvJO1PygVoEkI9g5iQGwZ-UeO0crUGl_2wmFVd1ToWuy4tEoM9sxIwOLVk7TVgfA-wDl6t3Fo0QbEU71iYp-3wlAofhrlSh8Oc4jDxrXqfs73jxvkOy0li3v2FWOoieKf3H4nxdqdXu4ofYUV3YUbyb4kwg_uwnJTrLDSDDsP4u8tBvye717EZWj5mO7cVjP4_TCSuuPLqIXFO7t6SivfMVOZtxFykm2_wP54OteOyjVQuFFVyamWCzPsTiC',
        reviews: [],
        sellerId: 2,
      },
    ],
    total: 199.99,
    status: 'Shipped',
    orderDate: new Date().toISOString(),
    sellerId: 2,
  },
];

/**
 * Zod schema defining the structure of an Order object
 * This schema is used for both request and response validation
 */
const OrderSchema = z.object({
  // Unique identifier for the order (auto-generated)
  id: z.number().openapi({ 
    example: 1,
    description: 'Unique identifier for the order (auto-generated)'
  }),
  
  // Customer's name (required)
  customerName: z.string().openapi({ 
    example: 'John Doe',
    description: 'Customer\'s name'
  }),
  
  // Order's items (required)
  items: z.array(z.object({
    id: z.number().openapi({ example: 1 }),
    name: z.string().openapi({ example: 'Wireless Headphones' }),
    description: z.string().openapi({ example: 'High-quality wireless headphones' }),
    price: z.string().openapi({ example: '$99.99' }),
    originalPrice: z.string().optional().openapi({ example: '$129.99' }),
    imageUrl: z.string().url().openapi({ example: 'https://example.com/image.jpg' }),
    reviews: z.array(z.object({
      id: z.number().openapi({ example: 1 }),
      title: z.string().openapi({ example: 'Great product!' }),
      reviewText: z.string().openapi({ example: 'This product is amazing!' }),
      rating: z.number().min(1).max(5).openapi({ example: 5 }),
      timeAgo: z.string().openapi({ example: '2 days ago' })
    })).optional().openapi({ 
      description: 'Product\'s reviews'
    }),
    sellerId: z.number().openapi({ example: 1 }),
  })).openapi({ 
    description: 'Order\'s items'
  }),
  
  // Order's total amount (required)
  total: z.number().openapi({ 
    example: 129.98,
    description: 'Order\'s total amount'
  }),
  
  // Order's status (required)
  status: z.string().openapi({ 
    example: 'Delivered',
    description: 'Order\'s status (e.g., Pending, Shipped, Delivered)'
  }),
  
  // Order date (required)
  orderDate: z.string().datetime().openapi({ 
    example: new Date().toISOString(),
    description: 'Order\'s creation date'
  }),
  
  // Seller ID (required, for associating orders with sellers)
  sellerId: z.number().openapi({ 
    example: 1,
    description: 'ID of the seller associated with this order'
  }),
});

/**
 * Zod schema defining the structure for updating an order status
 * Used for validation of PUT /api/orders/:id/status request body
 */
const UpdateOrderStatusSchema = z.object({
  // New status for the order (required)
  status: z.string().openapi({ 
    example: 'Shipped',
    description: 'New status for the order (e.g., Pending, Shipped, Delivered)'
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
  method: 'get',
  path: '/',
  // Documentation for the successful response
  responses: {
    200: {
      description: 'Returns all orders for the authenticated seller',
      content: {
        'application/json': {
          // Response body schema
          schema: z.array(OrderSchema),
        },
      },
    },
  },
});

// Register the route with authentication middleware
orderRoutes.openapi(getSellerOrdersRoute, verifyToken, async (c) => {
  const user = c.get('user');
  
  // Filter orders for the authenticated seller
  const sellerOrders = orders.filter(order => order.sellerId === user.userId);
  
  return c.json(sellerOrders);
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
  method: 'put',
  path: '/{id}/status',
  // Validate request parameters and body
  request: {
    params: z.object({
      // ID parameter: string that matches numeric pattern, transformed to number
      id: z
        .string()
        .regex(/^\d+$/, { message: 'ID must be a positive number' })
        .transform(Number)
        .openapi({ 
          example: 1,
          description: 'Unique identifier of the order to update'
        }),
    }),
    body: {
      content: {
        'application/json': {
          // Request body schema
          schema: UpdateOrderStatusSchema,
        },
      },
    },
  },
  // Documentation for possible responses
  responses: {
    200: {
      description: 'Order status updated successfully',
      content: {
        'application/json': {
          // Response body schema
          schema: OrderSchema,
        },
      },
    },
    404: {
      description: 'Order with the specified ID was not found',
      content: {
        'application/json': {
          // Error response schema
          schema: z.object({
            error: z.string().openapi({ 
              example: 'Order not found',
              description: 'Error message explaining why the request failed'
            }),
          }),
        },
      },
    },
  },
});

// Register the route with authentication middleware
orderRoutes.openapi(updateOrderStatusRoute, verifyToken, async (c) => {
  const id = Number(c.req.param('id'));
  const { status } = c.req.valid('json') as { status: string };
  const user = c.get('user');
  
  const index = orders.findIndex(order => order.id === id);
  
  if (index === -1) {
    return c.json({ error: 'Order not found' }, 404);
  }
  
  // Check if the user is the seller of this order
  if (orders[index].sellerId !== user.userId) {
    return c.json({ error: 'You can only update orders associated with your products' }, 403);
  }
  
  orders[index] = { ...orders[index], status };
  
  return c.json(orders[index]);
});

// Export the configured routes for use in the main application
export { orderRoutes };