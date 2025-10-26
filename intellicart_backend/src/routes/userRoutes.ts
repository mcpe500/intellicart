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
 * @version 1.0.0
 */

import { OpenAPIHono, createRoute, z } from '@hono/zod-openapi';
import { UserController } from '../controllers/UserController';

/**
 * Create a new OpenAPIHono instance for user routes
 * This allows automatic OpenAPI documentation generation from Zod schemas
 */
const userRoutes = new OpenAPIHono();

/**
 * Zod schema defining the structure of a User object
 * This schema is used for both request and response validation
 */
const UserSchema = z.object({
  // Unique identifier for the user (auto-generated)
  id: z.number().openapi({ 
    example: 1,
    description: 'Unique identifier for the user (auto-generated)'
  }),
  
  // User's full name (required)
  name: z.string().openapi({ 
    example: 'John Doe',
    description: 'User\'s full name'
  }),
  
  // User's email address (required, validated as email format)
  email: z.string().email().openapi({ 
    example: 'john@example.com',
    description: 'User\'s email address (must be valid email format)'
  }),
  
  // User's age (optional)
  age: z.number().min(0).optional().openapi({ 
    example: 30,
    description: 'User\'s age (optional, minimum value: 0)'
  }),
  
  // Creation timestamp (auto-generated)
  createdAt: z.string().datetime().openapi({ 
    example: new Date().toISOString(),
    description: 'Timestamp when the user was created'
  }),
});

/**
 * Zod schema defining the structure for creating a new user
 * Used for validation of POST /api/users request body
 */
const CreateUserSchema = z.object({
  // User's full name (required, minimum length: 1 character)
  name: z.string().min(1, { message: 'Name is required' }).openapi({ 
    example: 'John Doe',
    description: 'User\'s full name (required, minimum 1 character)'
  }),
  
  // User's email address (required, validated as email format)
  email: z.string().email({ message: 'Must be a valid email address' }).openapi({ 
    example: 'john@example.com',
    description: 'User\'s email address (required, must be valid format)'
  }),
  
  // User's age (optional, minimum value: 0)
  age: z.number().min(0, { message: 'Age must be 0 or greater' }).optional().openapi({ 
    example: 30,
    description: 'User\'s age (optional, minimum value: 0)'
  }),
});

/**
 * Zod schema defining the structure for updating an existing user
 * Used for validation of PUT /api/users/:id request body
 * All fields are optional to allow partial updates
 */
const UpdateUserSchema = z.object({
  // User's full name (optional, minimum length: 1 character if provided)
  name: z.string().min(1, { message: 'Name must be at least 1 character' }).optional().openapi({ 
    example: 'John Doe',
    description: 'User\'s full name (optional, minimum 1 character if provided)'
  }),
  
  // User's email address (optional, validated as email format if provided)
  email: z.string().email({ message: 'Must be a valid email address' }).optional().openapi({ 
    example: 'john@example.com',
    description: 'User\'s email address (optional, must be valid format if provided)'
  }),
  
  // User's age (optional, minimum value: 0 if provided)
  age: z.number().min(0, { message: 'Age must be 0 or greater' }).optional().openapi({ 
    example: 30,
    description: 'User\'s age (optional, minimum value: 0 if provided)'
  }),
});

/**
 * Route: GET /api/users
 * Description: Retrieve all users from the database
 * 
 * Request:
 * - Method: GET
 * - Path: / (relative to /api/users)
 * - Parameters: None
 * - Query: None
 * - Body: None
 * 
 * Response:
 * - Status: 200 OK
 * - Content-Type: application/json
 * - Body: Array of User objects
 */
const getAllUsersRoute = createRoute({
  method: 'get',
  path: '/',
  tags: ['Users'], // Add tags for grouping in Swagger UI
  // Documentation for the successful response
  responses: {
    200: {
      description: 'Returns all users in the system',
      content: {
        'application/json': {
          // Response body schema
          schema: z.array(UserSchema),
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
 * - Path: /{id}
 * - Parameters: id (number, required)
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
  path: '/{id}',
  tags: ['Users'], // Add tags for grouping in Swagger UI
  // Validate request parameters
  request: {
    params: z.object({
      // ID parameter: string that matches numeric pattern, transformed to number
      id: z
        .string()
        .regex(/^\d+$/, { message: 'ID must be a positive number' })
        .transform(Number)
        .openapi({ 
          example: 1,
          description: 'Unique identifier of the user to retrieve'
        }),
    }),
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
          schema: z.object({
            error: z.string().openapi({ 
              example: 'User not found',
              description: 'Error message explaining why the request failed'
            }),
          }),
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
 * - Path: / (relative to /api/users)
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
  path: '/',
  tags: ['Users'], // Add tags for grouping in Swagger UI
  // Note: This endpoint does not require authentication as it's for creating new users
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
  },
});

// Register the route with its corresponding controller method
userRoutes.openapi(createUserRoute, UserController.createUser);

/**
 * Route: PUT /api/users/:id
 * Description: Update an existing user by ID (full update)
 * 
 * Request:
 * - Method: PUT
 * - Path: /{id}
 * - Parameters: id (number, required)
 * - Query: None
 * - Body: User update object (validated against UpdateUserSchema)
 * 
 * Response:
 * - Status: 200 OK (user updated successfully)
 * - Content-Type: application/json
 * - Body: Updated User object
 * 
 * - Status: 404 Not Found (user not found)
 * - Content-Type: application/json
 * - Body: Error object
 */
const updateUserRoute = createRoute({
  method: 'put',
  path: '/{id}',
  tags: ['Users'], // Add tags for grouping in Swagger UI
  security: [{ BearerAuth: [] }], // Require authentication
  // Validate request parameters and body
  request: {
    params: z.object({
      // ID parameter: string that matches numeric pattern, transformed to number
      id: z
        .string()
        .regex(/^\d+$/, { message: 'ID must be a positive number' })
        .transform(Number)
        .openapi({ 
          example: 1,
          description: 'Unique identifier of the user to update'
        }),
    }),
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
    404: {
      description: 'User with the specified ID was not found',
      content: {
        'application/json': {
          // Error response schema
          schema: z.object({
            error: z.string().openapi({ 
              example: 'User not found',
              description: 'Error message explaining why the request failed'
            }),
          }),
        },
      },
    },
  },
});

// Register the route with its corresponding controller method
userRoutes.openapi(updateUserRoute, UserController.updateUser);

/**
 * Route: DELETE /api/users/:id
 * Description: Delete an existing user by ID
 * 
 * Request:
 * - Method: DELETE
 * - Path: /{id}
 * - Parameters: id (number, required)
 * - Query: None
 * - Body: None
 * 
 * Response:
 * - Status: 200 OK (user deleted successfully)
 * - Content-Type: application/json
 * - Body: Success message and deleted user object
 * 
 * - Status: 404 Not Found (user not found)
 * - Content-Type: application/json
 * - Body: Error object
 */
const deleteUserRoute = createRoute({
  method: 'delete',
  path: '/{id}',
  tags: ['Users'], // Add tags for grouping in Swagger UI
  security: [{ BearerAuth: [] }], // Require authentication
  // Validate request parameters
  request: {
    params: z.object({
      // ID parameter: string that matches numeric pattern, transformed to number
      id: z
        .string()
        .regex(/^\d+$/, { message: 'ID must be a positive number' })
        .transform(Number)
        .openapi({ 
          example: 1,
          description: 'Unique identifier of the user to delete'
        }),
    }),
  },
  // Documentation for possible responses
  responses: {
    200: {
      description: 'User deleted successfully',
      content: {
        'application/json': {
          // Response body schema
          schema: z.object({
            message: z.string().openapi({ 
              example: 'User deleted successfully',
              description: 'Confirmation message'
            }),
            user: UserSchema, // Return the deleted user object
          }),
        },
      },
    },
    404: {
      description: 'User with the specified ID was not found',
      content: {
        'application/json': {
          // Error response schema
          schema: z.object({
            error: z.string().openapi({ 
              example: 'User not found',
              description: 'Error message explaining why the request failed'
            }),
          }),
        },
      },
    },
  },
});

// Register the route with its corresponding controller method
userRoutes.openapi(deleteUserRoute, UserController.deleteUser);

// Export the configured routes for use in the main application
export { userRoutes };