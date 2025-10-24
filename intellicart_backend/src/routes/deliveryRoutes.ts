import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import { DeliveryController } from '../controllers/DeliveryController';
import { 
  DeliverySchema, 
  CreateDeliverySchema, 
  UserIdParamSchema, 
  ErrorSchema,
  DeleteDeliveryResponseSchema
} from '../schemas/DeliverySchemas';
import { authMiddleware } from '../middleware/auth';
import { z } from 'zod';

const deliveryRoutes = new OpenAPIHono();

// Get all deliveries for a specific user
const getUserDeliveriesRoute = createRoute({
  method: 'get',
  path: '/user/{userId}',
  tags: ['Deliveries'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    params: UserIdParamSchema,
  },
  responses: {
    200: {
      description: 'Returns all deliveries for the specified user',
      content: {
        'application/json': {
          schema: DeliverySchema.array(),
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
      description: 'Forbidden: You are not authorized to access these deliveries',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'User not found or has no deliveries',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

deliveryRoutes.openapi(getUserDeliveriesRoute, DeliveryController.getUserDeliveries);

// Get delivery information by tracking number
const getDeliveryByTrackingNumberRoute = createRoute({
  method: 'get',
  path: '/tracking/{trackingNumber}',
  tags: ['Deliveries'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    params: z.object({
      trackingNumber: z.string().min(1).max(100).openapi({
        example: 'TRK123456789',
        description: 'Tracking number for the shipment'
      })
    }),
  },
  responses: {
    200: {
      description: 'Returns delivery information for the specified tracking number',
      content: {
        'application/json': {
          schema: DeliverySchema,
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
      description: 'Forbidden: You are not authorized to access this delivery',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'Delivery not found',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

deliveryRoutes.openapi(getDeliveryByTrackingNumberRoute, DeliveryController.getDeliveryByTrackingNumber);

// Create a new delivery
const createDeliveryRoute = createRoute({
  method: 'post',
  path: '/',
  tags: ['Deliveries'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    body: {
      content: {
        'application/json': {
          schema: CreateDeliverySchema,
        },
      },
    },
  },
  responses: {
    201: {
      description: 'Delivery created successfully',
      content: {
        'application/json': {
          schema: DeliverySchema,
        },
      },
    },
    400: {
      description: 'Invalid input',
      content: {
        'application/json': {
          schema: ErrorSchema,
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
      description: 'Forbidden: You are not authorized to create a delivery',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    409: {
      description: 'Delivery with this tracking number already exists',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

deliveryRoutes.openapi(createDeliveryRoute, DeliveryController.createDelivery);

// Update a delivery
const updateDeliveryRoute = createRoute({
  method: 'put',
  path: '/{id}',
  tags: ['Deliveries'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    params: z.object({
      id: z.string().min(1).openapi({
        example: 'delivery-1234567890',
        description: 'Unique identifier of the delivery'
      })
    }),
    body: {
      content: {
        'application/json': {
          schema: z.object({
            status: z.string().min(1).max(50).optional().openapi({
              example: 'delivered',
              description: 'New status for the delivery'
            }),
            actualDelivery: z.string().datetime().optional().openapi({
              example: '2023-10-19T15:30:00.000Z',
              description: 'Actual delivery date'
            }),
            updates: z.array(z.object({
              status: z.string().min(1).max(50).openapi({
                example: 'shipped',
                description: 'Status for this update'
              }),
              location: z.string().max(255).optional().openapi({
                example: 'New York Distribution Center',
                description: 'Location for this update'
              }),
              timestamp: z.string().datetime().openapi({
                example: '2023-10-15T10:30:00.000Z',
                description: 'Timestamp of the update'
              }),
              description: z.string().max(500).optional().openapi({
                example: 'Package has been shipped from distribution center',
                description: 'Description of the update'
              })
            })).optional().openapi({
              description: 'Array of delivery updates'
            })
          })
        },
      },
    },
  },
  responses: {
    200: {
      description: 'Delivery updated successfully',
      content: {
        'application/json': {
          schema: DeliverySchema,
        },
      },
    },
    400: {
      description: 'Invalid input',
      content: {
        'application/json': {
          schema: ErrorSchema,
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
      description: 'Forbidden: You are not authorized to update this delivery',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'Delivery not found',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

deliveryRoutes.openapi(updateDeliveryRoute, DeliveryController.updateDelivery);

// Delete a delivery
const deleteDeliveryRoute = createRoute({
  method: 'delete',
  path: '/{id}',
  tags: ['Deliveries'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    params: z.object({
      id: z.string().min(1).openapi({
        example: 'delivery-1234567890',
        description: 'Unique identifier of the delivery'
      })
    }),
  },
  responses: {
    204: {
      description: 'Delivery deleted successfully',
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
      description: 'Forbidden: You are not authorized to delete this delivery',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'Delivery not found',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

deliveryRoutes.openapi(deleteDeliveryRoute, DeliveryController.deleteDelivery);

export { deliveryRoutes };