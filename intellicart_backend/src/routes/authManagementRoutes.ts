import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import { UserController } from '../controllers/UserController';
import { 
  RequestEmailChangeRequestSchema, 
  VerifyPhoneRequestSchema, 
  RequestPhoneChangeRequestSchema, 
  UpdatePhoneRequestSchema, 
  ErrorSchema 
} from '../schemas/UserSchemas';
import { authMiddleware } from '../middleware/auth';
import { Logger } from '../utils/logger';

const authManagementRoutes = new OpenAPIHono();

authManagementRoutes.onError((err, c) => {
  Logger.error('Auth management route error:', { error: err.message, stack: err.stack });
  return c.json({ error: 'Validation failed', details: err.message }, 400);
});

// Request Email Change Route
const requestEmailChangeRoute = createRoute({
  method: 'post',
  path: '/change-email-request',
  tags: ['Authentication Management'],
  request: {
    body: {
      content: {
        'application/json': {
          schema: RequestEmailChangeRequestSchema,
        },
      },
    },
  },
  responses: {
    200: {
      description: 'Email change request successful',
      content: {
        'application/json': {
          schema: { type: 'object', properties: { message: { type: 'string' } } },
        },
      },
    },
    400: {
      description: 'Invalid request data provided',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    401: {
      description: 'User not authorized to change email',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    429: {
      description: 'Rate limit exceeded',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

authManagementRoutes.use('/change-email-request', authMiddleware);
authManagementRoutes.openapi(requestEmailChangeRoute, UserController.requestEmailChange);

// Verify Phone Route
const verifyPhoneRoute = createRoute({
  method: 'post',
  path: '/verify-phone',
  tags: ['Authentication Management'],
  request: {
    body: {
      content: {
        'application/json': {
          schema: VerifyPhoneRequestSchema,
        },
      },
    },
  },
  responses: {
    200: {
      description: 'Phone number verified successfully',
      content: {
        'application/json': {
          schema: { type: 'object', properties: { message: { type: 'string' } } },
        },
      },
    },
    400: {
      description: 'Invalid verification data',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    401: {
      description: 'Invalid OTP code',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    429: {
      description: 'Too many attempts, try again later',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

authManagementRoutes.use('/verify-phone', authMiddleware);
authManagementRoutes.openapi(verifyPhoneRoute, UserController.verifyPhone);

// Request Phone Number Change Route
const requestPhoneChangeRoute = createRoute({
  method: 'post',
  path: '/change-phone-request',
  tags: ['Authentication Management'],
  request: {
    body: {
      content: {
        'application/json': {
          schema: RequestPhoneChangeRequestSchema,
        },
      },
    },
  },
  responses: {
    200: {
      description: 'Phone change request successful',
      content: {
        'application/json': {
          schema: { type: 'object', properties: { message: { type: 'string' } } },
        },
      },
    },
    400: {
      description: 'Invalid request data provided',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    401: {
      description: 'User not authorized to change phone',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    429: {
      description: 'Rate limit exceeded',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

authManagementRoutes.use('/change-phone-request', authMiddleware);
authManagementRoutes.openapi(requestPhoneChangeRoute, UserController.requestPhoneChange);

// Update Phone After Verification Route
const updatePhoneRoute = createRoute({
  method: 'post',
  path: '/update-phone',
  tags: ['Authentication Management'],
  request: {
    body: {
      content: {
        'application/json': {
          schema: UpdatePhoneRequestSchema,
        },
      },
    },
  },
  responses: {
    200: {
      description: 'Phone number updated successfully',
      content: {
        'application/json': {
          schema: { type: 'object', properties: { message: { type: 'string' } } },
        },
      },
    },
    400: {
      description: 'Invalid verification data',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    401: {
      description: 'Invalid OTP code or unauthorized',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    429: {
      description: 'Too many attempts, try again later',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

authManagementRoutes.use('/update-phone', authMiddleware);
authManagementRoutes.openapi(updatePhoneRoute, UserController.updatePhoneAfterVerification);

export { authManagementRoutes };