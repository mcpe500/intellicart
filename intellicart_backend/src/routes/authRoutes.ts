import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import { AuthController } from '../controllers/AuthController';
import { LoginSchema, RegisterSchema, AuthResponseSchema, ErrorSchema, RefreshTokenSchema, RefreshResponseSchema } from '../schemas/AuthSchemas';
import { authMiddleware } from '../middleware/auth';
import { Logger } from '../utils/logger';
import { z } from 'zod';

const authRoutes = new OpenAPIHono();

authRoutes.onError((err, c) => {
  Logger.error('Auth route error:', { error: err.message, stack: err.stack });
  return c.json({ error: 'Validation failed', details: err.message }, 400);
});

// Login Route
const loginRoute = createRoute({
  method: 'post',
  path: '/login',
  tags: ['Authentication'],
  request: {
    body: {
      content: {
        'application/json': {
          schema: LoginSchema,
        },
      },
    },
  },
  responses: {
    200: {
      description: 'User logged in successfully',
      content: {
        'application/json': {
          schema: AuthResponseSchema,
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
      description: 'Invalid email or password',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

authRoutes.openapi(loginRoute, AuthController.login);

// Register Route
const registerRoute = createRoute({
  method: 'post',
  path: '/register',
  tags: ['Authentication'],
  request: {
    body: {
      content: {
        'application/json': {
          schema: RegisterSchema,
        },
      },
    },
  },
  responses: {
    201: {
      description: 'User registered successfully',
      content: {
        'application/json': {
          schema: AuthResponseSchema,
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
    409: {
      description: 'User already exists',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

authRoutes.openapi(registerRoute, AuthController.register);


// Get Current User Route (auth/me equivalent)
const getCurrentUserRoute = createRoute({
  method: 'get',
  path: '/me',
  tags: ['Authentication'],
  middleware: [authMiddleware],
  responses: {
    200: {
      description: 'Returns the authenticated user\'s profile',
      content: {
        'application/json': {
          schema: z.object({
            id: z.string(),
            name: z.string(),
            email: z.string(),
            role: z.string(),
            createdAt: z.string().optional()
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

authRoutes.openapi(getCurrentUserRoute, AuthController.getProfile);

// Profile Route - kept for backward compatibility
const profileRoute = createRoute({
  method: 'get',
  path: '/profile',
  tags: ['Authentication'],
  middleware: [authMiddleware],
  responses: {
    200: {
      description: 'Returns the authenticated user\'s profile',
      content: {
        'application/json': {
          schema: z.object({
            id: z.string(),
            name: z.string(),
            email: z.string(),
            role: z.string(),
            createdAt: z.string().optional()
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

authRoutes.openapi(profileRoute, AuthController.getProfile);

// Refresh Token Route
const refreshTokenRoute = createRoute({
  method: 'post',
  path: '/refresh',
  tags: ['Authentication'],
  request: {
    body: {
      content: {
        'application/json': {
          schema: RefreshTokenSchema,
        },
      },
    },
  },
  responses: {
    200: {
      description: 'Token refreshed successfully',
      content: {
        'application/json': {
          schema: RefreshResponseSchema,
        },
      },
    },
    400: {
      description: 'Invalid refresh token',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    501: {
      description: 'Refresh tokens not yet implemented',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

authRoutes.openapi(refreshTokenRoute, AuthController.refreshToken);

export { authRoutes };