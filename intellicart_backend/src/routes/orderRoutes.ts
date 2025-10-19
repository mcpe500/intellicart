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
  responses: {
    200: {
      description: 'Returns orders for the authenticated seller',
      content: {
        'application/json': {
          schema: OrderSchema.array(),
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

// Update order status (requires authentication)
const updateOrderStatusRoute = createRoute({
  method: 'put',
  path: '/orders/{id}',
  tags: ['Orders'],
  middleware: [authMiddleware],
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