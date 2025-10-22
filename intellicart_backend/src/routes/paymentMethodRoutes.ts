import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import { PaymentMethodController } from '../controllers/PaymentMethodController';
import { 
  PaymentMethodSchema, 
  CreatePaymentMethodSchema, 
  UpdatePaymentMethodSchema, 
  PaymentMethodIdParamSchema, 
  UserIdParamSchema, 
  ErrorSchema,
  DeletePaymentMethodResponseSchema
} from '../schemas/PaymentMethodSchemas';
import { authMiddleware } from '../middleware/auth';

const paymentMethodRoutes = new OpenAPIHono();

// Get all payment methods for a specific user
const getUserPaymentMethodsRoute = createRoute({
  method: 'get',
  path: '/user/{userId}',
  tags: ['Payment Methods'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    params: UserIdParamSchema,
  },
  responses: {
    200: {
      description: 'Returns all payment methods for the specified user',
      content: {
        'application/json': {
          schema: PaymentMethodSchema.array(),
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
      description: 'Forbidden: You are not authorized to access these payment methods',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'User not found or has no payment methods',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

paymentMethodRoutes.openapi(getUserPaymentMethodsRoute, PaymentMethodController.getUserPaymentMethods);

// Add a new payment method for a user
const createPaymentMethodRoute = createRoute({
  method: 'post',
  path: '/user/{userId}',
  tags: ['Payment Methods'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    params: UserIdParamSchema,
    body: {
      content: {
        'application/json': {
          schema: CreatePaymentMethodSchema,
        },
      },
    },
  },
  responses: {
    201: {
      description: 'Payment method created successfully',
      content: {
        'application/json': {
          schema: PaymentMethodSchema,
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
      description: 'Forbidden: You are not authorized to add a payment method for this user',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

paymentMethodRoutes.openapi(createPaymentMethodRoute, PaymentMethodController.createPaymentMethod);

// Update an existing payment method
const updatePaymentMethodRoute = createRoute({
  method: 'put',
  path: '/{id}',
  tags: ['Payment Methods'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    params: PaymentMethodIdParamSchema,
    body: {
      content: {
        'application/json': {
          schema: UpdatePaymentMethodSchema,
        },
      },
    },
  },
  responses: {
    200: {
      description: 'Payment method updated successfully',
      content: {
        'application/json': {
          schema: PaymentMethodSchema,
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
      description: 'Forbidden: You are not authorized to update this payment method',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'Payment method not found',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

paymentMethodRoutes.openapi(updatePaymentMethodRoute, PaymentMethodController.updatePaymentMethod);

// Delete a payment method
const deletePaymentMethodRoute = createRoute({
  method: 'delete',
  path: '/{id}',
  tags: ['Payment Methods'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    params: PaymentMethodIdParamSchema,
  },
  responses: {
    204: {
      description: 'Payment method deleted successfully',
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
      description: 'Forbidden: You are not authorized to delete this payment method',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'Payment method not found',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

paymentMethodRoutes.openapi(deletePaymentMethodRoute, PaymentMethodController.deletePaymentMethod);

export { paymentMethodRoutes };