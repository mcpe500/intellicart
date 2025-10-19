/**
 * User Routes Module
 * 
 * This module defines all user-related API endpoints with proper validation
 * using Zod schemas. Each route is documented with OpenAPI specifications
 * that are automatically generated and displayed in Swagger UI.
 * 
 * The routes follow RESTful conventions and include proper HTTP status codes,
 * request validation, and response schemas.
 * 
 * @module userRoutes
 * @description API routes for user management
 * @author Intellicart Team
 * @version 4.0.0
 */

import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import { UserController } from '../controllers/UserController';
import { 
  UserSchema, 
  CreateUserSchema, 
  UpdateUserSchema, 
  ErrorSchema, 
  DeleteUserResponseSchema, 
  UserIdParamSchema 
} from '../schemas/UserSchemas';

/**
 * Create a new OpenAPIHono instance for user routes
 * This allows automatic OpenAPI documentation generation from Zod schemas
 */
const userRoutes = new OpenAPIHono();

/**
 * Route: GET /api/users
 * Description: Retrieve all users from the database (not implemented for security reasons)
 * 
 * Request:
 * - Method: GET
 * - Path: /users
 * - Parameters: None
 * - Query: None
 * - Body: None
 * 
 * Response:
 * - Status: 404 Not Found (endpoint not available for privacy reasons)
 * - Content-Type: application/json
 * - Body: Error object
 */
const getAllUsersRoute = createRoute({
  method: 'get',
  path: '/users',
  tags: ['Users'],
  // Documentation for the successful response
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
    404: {
      description: 'Endpoint not available for privacy reasons',
      content: {
        'application/json': {
          // Error response schema
          schema: ErrorSchema,
        },
      },
    },
  },
});

// Register the route with its corresponding controller method
userRoutes.openapi(getAllUsersRoute, UserController.getAllUsers);

/**
 * Route: GET /api/users/:id
 * Description: Retrieve a specific user by ID
 * 
 * Request:
 * - Method: GET
 * - Path: /users/{id}
 * - Parameters: id (string, required)
 * - Query: None
 * - Body: None
 * 
 * Response:
 * - Status: 200 OK (user found)
 * - Content-Type: application/json
 * - Body: User object
 * 
 * - Status: 404 Not Found (user not found)
 * - Content-Type: application/json
 * - Body: Error object
 */
const getUserByIdRoute = createRoute({
  method: 'get',
  path: '/users/{id}',
  tags: ['Users'],
  // Validate request parameters
  request: {
    params: UserIdParamSchema,
  },
  // Documentation for possible responses
  responses: {
    200: {
      description: 'Returns the requested user by ID',
      content: {
        'application/json': {
          // Response body schema
          schema: UserSchema,
        },
      },
    },
    404: {
      description: 'User with the specified ID was not found',
      content: {
        'application/json': {
          // Error response schema
          schema: ErrorSchema,
        },
      },
    },
  },
});

// Register the route with its corresponding controller method
userRoutes.openapi(getUserByIdRoute, UserController.getUserById);

/**
 * Route: POST /api/users
 * Description: Create a new user
 * 
 * Request:
 * - Method: POST
 * - Path: /users
 * - Parameters: None
 * - Query: None
 * - Body: User creation object (validated against CreateUserSchema)
 * 
 * Response:
 * - Status: 201 Created
 * - Content-Type: application/json
 * - Body: Created User object with assigned ID and timestamp
 */
const createUserRoute = createRoute({
  method: 'post',
  path: '/users',
  tags: ['Users'],
  // Validate request body
  request: {
    body: {
      content: {
        'application/json': {
          // Request body schema
          schema: CreateUserSchema,
        },
      },
    },
  },
  // Documentation for the successful response
  responses: {
    201: {
      description: 'User created successfully',
      content: {
        'application/json': {
          // Response body schema
          schema: UserSchema,
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

// Register the route with its corresponding controller method
userRoutes.openapi(createUserRoute, UserController.createUser);

/**
 * Route: PUT /api/users/:id
 * Description: Update an existing user by ID (full update) - Not supported for security reasons
 * 
 * Request:
 * - Method: PUT
 * - Path: /users/{id}
 * - Parameters: id (string, required)
 * - Query: None
 * - Body: User update object (validated against UpdateUserSchema)
 * 
 * Response:
 * - Status: 400 Bad Request (not supported through this endpoint)
 * - Content-Type: application/json
 * - Body: Error object
 */
const updateUserRoute = createRoute({
  method: 'put',
  path: '/users/{id}',
  tags: ['Users'],
  // Validate request parameters and body
  request: {
    params: UserIdParamSchema,
    body: {
      content: {
        'application/json': {
          // Request body schema
          schema: UpdateUserSchema,
        },
      },
    },
  },
  // Documentation for possible responses
  responses: {
    200: {
      description: 'User updated successfully',
      content: {
        'application/json': {
          // Response body schema
          schema: UserSchema,
        },
      },
    },
    400: {
      description: 'User updates not supported through this endpoint',
      content: {
        'application/json': {
          // Error response schema
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'User with the specified ID was not found',
      content: {
        'application/json': {
          // Error response schema
          schema: ErrorSchema,
        },
      },
    },
  },
});

// Register the route with its corresponding controller method
userRoutes.openapi(updateUserRoute, UserController.updateUser);

/**
 * Route: DELETE /api/users/:id
 * Description: Delete an existing user by ID - Not supported for security reasons
 * 
 * Request:
 * - Method: DELETE
 * - Path: /users/{id}
 * - Parameters: id (string, required)
 * - Query: None
 * - Body: None
 * 
 * Response:
 * - Status: 400 Bad Request (not supported for security reasons)
 * - Content-Type: application/json
 * - Body: Error object
 * 
 * - Status: 404 Not Found (user not found)
 * - Content-Type: application/json
 * - Body: Error object
 */
const deleteUserRoute = createRoute({
  method: 'delete',
  path: '/users/{id}',
  tags: ['Users'],
  // Validate request parameters
  request: {
    params: UserIdParamSchema,
  },
  // Documentation for possible responses
  responses: {
    200: {
      description: 'User deleted successfully',
      content: {
        'application/json': {
          // Response body schema
          schema: DeleteUserResponseSchema,
        },
      },
    },
    400: {
      description: 'User deletion not supported for security reasons',
      content: {
        'application/json': {
          // Error response schema
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'User with the specified ID was not found',
      content: {
        'application/json': {
          // Error response schema
          schema: ErrorSchema,
        },
      },
    },
  },
});

// Register the route with its corresponding controller method
userRoutes.openapi(deleteUserRoute, UserController.deleteUser);

// Export the configured routes for use in the main application
export { userRoutes };