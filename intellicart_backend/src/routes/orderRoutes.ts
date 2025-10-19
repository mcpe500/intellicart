import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import { OrderController } from '../controllers/OrderController';
import { 
  OrderSchema, 
  UpdateOrderSchema, 
  OrderIdParamSchema, 
  ErrorSchema 
} from '../schemas/OrderSchemas';
import { authMiddleware } from '../middleware/auth';
import { z } from 'zod';

const orderRoutes = new OpenAPIHono();

// Get orders by seller (requires authentication)
const getOrdersBySellerRoute = createRoute({
  method: 'get',
  path: '/orders',
  tags: ['Orders'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    query: z.object({
      status: z.string().optional(),
      page: z.string().regex(/^\d+$/).transform(Number).optional().default('1'),
      limit: z.string().regex(/^\d+$/).transform(Number).optional().default('10'),
    })
  },
  responses: {
    200: {
      description: 'Returns orders for the authenticated seller',
      content: {
        'application/json': {
          schema: z.object({
            orders: OrderSchema.array(),
            pagination: z.object({
              page: z.number(),
              limit: z.number(),
              total: z.number(),
              totalPages: z.number()
            })
          }),
        },
      },
    },
    401: {
      description: 'Unauthorized: Invalid or missing token',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

orderRoutes.openapi(getOrdersBySellerRoute, OrderController.getOrdersBySeller);

// Get orders by user (requires authentication)
const getOrdersByUserRoute = createRoute({
  method: 'get',
  path: '/user',
  tags: ['Orders'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    query: z.object({
      status: z.string().optional(),
      page: z.string().regex(/^\d+$/).transform(Number).optional().default('1'),
      limit: z.string().regex(/^\d+$/).transform(Number).optional().default('10'),
    })
  },
  responses: {
    200: {
      description: 'Returns orders for the authenticated user',
      content: {
        'application/json': {
          schema: z.object({
            orders: OrderSchema.array(),
            pagination: z.object({
              page: z.number(),
              limit: z.number(),
              total: z.number(),
              totalPages: z.number()
            })
          }),
        },
      },
    },
    401: {
      description: 'Unauthorized: Invalid or missing token',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

orderRoutes.openapi(getOrdersByUserRoute, OrderController.getOrdersByUser);

// Update order status (requires authentication)
const updateOrderStatusRoute = createRoute({
  method: 'put',
  path: '/orders/{id}',
  tags: ['Orders'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    params: OrderIdParamSchema,
    body: {
      content: {
        'application/json': {
          schema: UpdateOrderSchema,
        },
      },
    },
  },
  responses: {
    200: {
      description: 'Order status updated successfully',
      content: {
        'application/json': {
          schema: OrderSchema,
        },
      },
    },
    401: {
      description: 'Unauthorized: Invalid or missing token',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    403: {
      description: 'Forbidden: You are not authorized to update this order',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'Order with the specified ID was not found',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

orderRoutes.openapi(updateOrderStatusRoute, OrderController.updateOrderStatus);

export { orderRoutes };