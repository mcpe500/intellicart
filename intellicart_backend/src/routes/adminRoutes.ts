/**
 * Admin Routes Module
 * 
 * This module defines all admin-only API endpoints with proper validation
 * using Zod schemas. Each route is documented with OpenAPI specifications
 * that are automatically generated and displayed in Swagger UI.
 * 
 * The routes follow RESTful conventions and include proper HTTP status codes,
 * request validation, and response schemas.
 * 
 * @module adminRoutes
 * @description API routes for admin panel functionality
 * @author IntelliCart Team
 * @version 1.0.0
 */

import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import { AdminController } from '../controllers/AdminController';
import { adminMiddleware } from '../middleware/admin';
import { 
  UserSchema, 
  UserIdParamSchema 
} from '../schemas/UserSchemas';
import { ErrorSchema } from '../schemas/AuthSchemas';

/**
 * Create a new OpenAPIHono instance for admin routes
 * This allows automatic OpenAPI documentation generation from Zod schemas
 */
const adminRoutes = new OpenAPIHono();

// Apply admin middleware to all admin routes
adminRoutes.use('/admin/*', adminMiddleware);

/**
 * Route: GET /api/admin/users
 * Description: Retrieve all users in the system (admin only)
 * 
 * Request:
 * - Method: GET
 * - Path: /admin/users
 * - Requires: Admin authentication
 * 
 * Response:
 * - Status: 200 OK
 * - Content-Type: application/json
 * - Body: Array of user objects
 */
const getAllUsersRoute = createRoute({
  method: 'get',
  path: '/admin/users',
  tags: ['Admin'],
  middleware: [adminMiddleware],
  responses: {
    200: {
      description: 'Returns all users in the system',
      content: {
        'application/json': {
          // Response body schema
          schema: UserSchema.array(),
        },
      },
    },
    401: {
      description: 'Authentication required',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    403: {
      description: 'Admin access required',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

// Register the route with its corresponding controller method
adminRoutes.openapi(getAllUsersRoute, AdminController.getAllUsers);

/**
 * Route: GET /api/admin/users/:id
 * Description: Retrieve a specific user by ID (admin only)
 * 
 * Request:
 * - Method: GET
 * - Path: /admin/users/{id}
 * - Parameters: id (string, required)
 * - Requires: Admin authentication
 * 
 * Response:
 * - Status: 200 OK
 * - Content-Type: application/json
 * - Body: User object
 * 
 * - Status: 404 Not Found
 * - Content-Type: application/json
 * - Body: Error object
 */
const getUserByIdRoute = createRoute({
  method: 'get',
  path: '/admin/users/{id}',
  tags: ['Admin'],
  middleware: [adminMiddleware],
  request: {
    params: UserIdParamSchema,
  },
  responses: {
    200: {
      description: 'Returns the requested user by ID',
      content: {
        'application/json': {
          schema: UserSchema,
        },
      },
    },
    401: {
      description: 'Authentication required',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    403: {
      description: 'Admin access required',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'User with the specified ID was not found',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

// Register the route with its corresponding controller method
adminRoutes.openapi(getUserByIdRoute, AdminController.getUserById);

/**
 * Route: PUT /api/admin/users/:id/role
 * Description: Update a user's role (admin only)
 * 
 * Request:
 * - Method: PUT
 * - Path: /admin/users/{id}/role
 * - Parameters: id (string, required)
 * - Body: Role update object
 * - Requires: Admin authentication
 * 
 * Response:
 * - Status: 200 OK
 * - Content-Type: application/json
 * - Body: Updated user object
 * 
 * - Status: 400 Bad Request (invalid role)
 * - Content-Type: application/json
 * - Body: Error object
 */
const updateUserRoleRoute = createRoute({
  method: 'put',
  path: '/admin/users/{id}/role',
  tags: ['Admin'],
  middleware: [adminMiddleware],
  request: {
    params: UserIdParamSchema,
    body: {
      content: {
        'application/json': {
          schema: UserSchema.pick({ role: true }),
        },
      },
    },
  },
  responses: {
    200: {
      description: 'User role updated successfully',
      content: {
        'application/json': {
          schema: UserSchema,
        },
      },
    },
    400: {
      description: 'Invalid role provided',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    401: {
      description: 'Authentication required',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    403: {
      description: 'Admin access required',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'User with the specified ID was not found',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

// Register the route with its corresponding controller method
adminRoutes.openapi(updateUserRoleRoute, AdminController.updateUserRole);

/**
 * Route: DELETE /api/admin/users/:id
 * Description: Delete a user (admin only)
 * 
 * Request:
 * - Method: DELETE
 * - Path: /admin/users/{id}
 * - Parameters: id (string, required)
 * - Requires: Admin authentication
 * 
 * Response:
 * - Status: 200 OK
 * - Content-Type: application/json
 * - Body: Success message and deleted user
 * 
 * - Status: 404 Not Found
 * - Content-Type: application/json
 * - Body: Error object
 */
const deleteUserRoute = createRoute({
  method: 'delete',
  path: '/admin/users/{id}',
  tags: ['Admin'],
  middleware: [adminMiddleware],
  request: {
    params: UserIdParamSchema,
  },
  responses: {
    200: {
      description: 'User deleted successfully',
      content: {
        'application/json': {
          schema: UserSchema.extend({ 
            message: UserSchema.shape.email.or(UserSchema.shape.name) // Define a proper message field
          }),
        },
      },
    },
    401: {
      description: 'Authentication required',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    403: {
      description: 'Admin access required',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'User with the specified ID was not found',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

// Register the route with its corresponding controller method
adminRoutes.openapi(deleteUserRoute, AdminController.deleteUser);

/**
 * Route: GET /api/admin/stats
 * Description: Get system statistics (admin only)
 * 
 * Request:
 * - Method: GET
 * - Path: /admin/stats
 * - Requires: Admin authentication
 * 
 * Response:
 * - Status: 200 OK
 * - Content-Type: application/json
 * - Body: System statistics
 */
const getSystemStatsRoute = createRoute({
  method: 'get',
  path: '/admin/stats',
  tags: ['Admin'],
  middleware: [adminMiddleware],
  responses: {
    200: {
      description: 'Returns system statistics',
      content: {
        'application/json': {
          schema: {
            type: 'object',
            properties: {
              totalUsers: { type: 'number' },
              totalProducts: { type: 'number' },
              userRoles: {
                type: 'object',
                properties: {
                  admin: { type: 'number' },
                  seller: { type: 'number' },
                  buyer: { type: 'number' },
                }
              },
              timestamp: { type: 'string' }
            }
          }
        },
      },
    },
    401: {
      description: 'Authentication required',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    403: {
      description: 'Admin access required',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

// Register the route with its corresponding controller method
adminRoutes.openapi(getSystemStatsRoute, AdminController.getSystemStats);

// Export the configured routes for use in the main application
export { adminRoutes };