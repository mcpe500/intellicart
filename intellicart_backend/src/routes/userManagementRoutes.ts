import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import { z } from 'zod';
import { UserController } from '../controllers/UserController';
import { 
  UpdateUserRequestSchema, 
  UpdateUserResponseSchema, 
  RequestEmailChangeRequestSchema, 
  VerifyPhoneRequestSchema, 
  RequestPhoneChangeRequestSchema, 
  UpdatePhoneRequestSchema, 
  ErrorSchema 
} from '../schemas/UserSchemas';
import { authMiddleware } from '../middleware/auth';
import { Logger } from '../utils/logger';

const userManagementRoutes = new OpenAPIHono();

userManagementRoutes.onError((err, c) => {
  Logger.error('User management route error:', { error: err.message, stack: err.stack });
  return c.json({ error: 'Validation failed', details: err.message }, 400);
});

// Define the path parameters schema
const UpdateUserParamsSchema = z.object({
  userId: z.string().describe('The unique identifier of the user to update')
});

// Update User Information Route
const updateUserRoute = createRoute({
  method: 'put',
  path: '/{userId}',
  tags: ['User Management'],
  request: {
    params: UpdateUserParamsSchema,
    body: {
      content: {
        'application/json': {
          schema: UpdateUserRequestSchema,
        },
      },
    },
  },
  responses: {
    200: {
      description: 'User updated successfully',
      content: {
        'application/json': {
          schema: UpdateUserResponseSchema,
        },
      },
    },
    400: {
      description: 'Invalid user data provided',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    401: {
      description: 'User not authorized to update this account',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    403: {
      description: 'User not authorized to update this account',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'User not found',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    422: {
      description: 'User validation failed',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

// Apply auth middleware to routes that require authentication
userManagementRoutes.use('/{userId}/*', authMiddleware);
userManagementRoutes.openapi(updateUserRoute, UserController.updateUserInfo);

export { userManagementRoutes };