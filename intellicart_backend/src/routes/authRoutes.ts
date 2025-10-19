import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import { AuthController } from '../controllers/AuthController';
import { LoginSchema, RegisterSchema, AuthResponseSchema, ErrorSchema } from '../schemas/AuthSchemas';
import { authMiddleware } from '../middleware/auth';
import { z } from 'zod';

const authRoutes = new OpenAPIHono();

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

// Profile Route
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
            createdAt: z.string()
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

export { authRoutes };