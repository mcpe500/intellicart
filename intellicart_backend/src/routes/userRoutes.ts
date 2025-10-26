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
import { zValidator } from '@hono/zod-validator';
import { verifyToken } from '../middleware/authMiddleware';
import { UserHandler } from '../handlers/UserHandler';

export const userRoutes = () => {
  const userRoutes = new OpenAPIHono();

  const UserSchema = z.object({
    id: z.number().openapi({ 
      example: 1,
      description: 'Unique identifier for the user (auto-generated)'
    }),
    name: z.string().openapi({ 
      example: 'John Doe',
      description: 'User\'s full name'
    }),
    email: z.string().email().openapi({ 
      example: 'john@example.com',
      description: 'User\'s email address (must be valid email format)'
    }),
    age: z.number().min(0).optional().openapi({ 
      example: 30,
      description: 'User\'s age (optional, minimum value: 0)'
    }),
    createdAt: z.string().datetime().openapi({ 
      example: new Date().toISOString(),
      description: 'Timestamp when the user was created'
    }),
  });

  const CreateUserSchema = z.object({
    name: z.string().min(1, { message: 'Name is required' }).openapi({ 
      example: 'John Doe',
      description: 'User\'s full name (required, minimum 1 character)'
    }),
    email: z.string().email({ message: 'Must be a valid email address' }).openapi({ 
      example: 'john@example.com',
      description: 'User\'s email address (required, must be valid format)'
    }),
    age: z.number().min(0, { message: 'Age must be 0 or greater' }).optional().openapi({ 
      example: 30,
      description: 'User\'s age (optional, minimum value: 0)'
    }),
  });

  const UpdateUserSchema = z.object({
    name: z.string().min(1, { message: 'Name must be at least 1 character' }).optional().openapi({ 
      example: 'John Doe',
      description: 'User\'s full name (optional, minimum 1 character if provided)'
    }),
    email: z.string().email({ message: 'Must be a valid email address' }).optional().openapi({ 
      example: 'john@example.com',
      description: 'User\'s email address (optional, must be valid format if provided)'
    }),
    age: z.number().min(0, { message: 'Age must be 0 or greater' }).optional().openapi({ 
      example: 30,
      description: 'User\'s age (optional, minimum value: 0 if provided)'
    }),
  });

  const getAllUsersRoute = createRoute({
    method: 'get',
    path: '/',
    tags: ['Users'],
    security: [{ BearerAuth: [] }], // Require authentication for user listing
    responses: {
      200: {
        description: 'Returns all users in the system',
        content: {
          'application/json': {
            schema: z.array(UserSchema),
          },
        },
      },
    },
  });

  userRoutes.openapi(getAllUsersRoute, async (c) => {
    await verifyToken(c, async () => {});
    return UserHandler.getAllUsers(c);
  });

  const getUserByIdRoute = createRoute({
    method: 'get',
    path: '/{id}',
    tags: ['Users'],
    security: [{ BearerAuth: [] }], // Require authentication
    request: {
      params: z.object({
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
    responses: {
      200: {
        description: 'Returns the requested user by ID',
        content: {
          'application/json': {
            schema: UserSchema,
          },
        },
      },
      404: {
        description: 'User with the specified ID was not found',
        content: {
          'application/json': {
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

  userRoutes.openapi(getUserByIdRoute, async (c) => {
    await verifyToken(c, async () => {});
    return UserHandler.getUserById(c);
  });

  const createUserRoute = createRoute({
    method: 'post',
    path: '/',
    tags: ['Users'],
    request: {
      body: {
        content: {
          'application/json': {
            schema: CreateUserSchema,
          },
        },
      },
    },
    responses: {
      201: {
        description: 'User created successfully',
        content: {
          'application/json': {
            schema: UserSchema,
          },
        },
      },
    },
  });

  userRoutes.openapi(createUserRoute, UserHandler.createUser);

  const updateUserRoute = createRoute({
    method: 'put',
    path: '/{id}',
    tags: ['Users'],
    security: [{ BearerAuth: [] }],
    request: {
      params: z.object({
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
            schema: UpdateUserSchema,
          },
        },
      },
    },
    responses: {
      200: {
        description: 'User updated successfully',
        content: {
          'application/json': {
            schema: UserSchema,
          },
        },
      },
      404: {
        description: 'User with the specified ID was not found',
        content: {
          'application/json': {
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

  userRoutes.openapi(updateUserRoute, async (c) => {
    await verifyToken(c, async () => {});
    return UserHandler.updateUser(c);
  });

  const deleteUserRoute = createRoute({
    method: 'delete',
    path: '/{id}',
    tags: ['Users'],
    security: [{ BearerAuth: [] }],
    request: {
      params: z.object({
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
    responses: {
      200: {
        description: 'User deleted successfully',
        content: {
          'application/json': {
            schema: z.object({
              message: z.string().openapi({ 
                example: 'User deleted successfully',
                description: 'Confirmation message'
              }),
              user: UserSchema,
            }),
          },
        },
      },
      404: {
        description: 'User with the specified ID was not found',
        content: {
          'application/json': {
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

  userRoutes.openapi(deleteUserRoute, async (c) => {
    await verifyToken(c, async () => {});
    return UserHandler.deleteUser(c);
  });

  return userRoutes;
};