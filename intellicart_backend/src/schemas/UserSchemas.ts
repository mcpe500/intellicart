/**
 * User Schemas Definition
 * 
 * This file contains all Zod schemas related to User entities.
 * These schemas are used for request validation, response formatting,
 * and OpenAPI documentation generation.
 * 
 * @file User Zod schemas
 * @author Intellicart Team
 * @version 2.0.0
 */

import { z } from 'zod';

/**
 * Zod schema defining the structure of a User object
 * This schema is used for both request and response validation
 */
export const UserSchema = z.object({
  // Unique identifier for the user (auto-generated)
  id: z.string().openapi({ 
    example: 'user-1234567890',
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
  
  // User's role (required)
  role: z.string().openapi({
    example: 'buyer',
    description: 'User\'s role (buyer or seller)'
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
export const CreateUserSchema = z.object({
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
  
  // User's password (required, minimum length: 6 characters)
  password: z.string().min(6, { message: 'Password must be at least 6 characters' }).openapi({
    example: 'password123',
    description: 'User\'s password (required, minimum 6 characters)'
  }),
  
  // User's role (optional, defaults to 'buyer')
  role: z.string().optional().default('buyer').openapi({
    example: 'buyer',
    description: 'User\'s role (optional, defaults to buyer)'
  }),
});

/**
 * Zod schema defining the structure for updating an existing user
 * Used for validation of PUT /api/users/:id request body
 * All fields are optional to allow partial updates
 */
export const UpdateUserSchema = z.object({
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
  
  // User's role (optional)
  role: z.string().optional().openapi({
    example: 'seller',
    description: 'User\'s role (optional)'
  }),
});

/**
 * Zod schema for delete user response
 */
export const DeleteUserResponseSchema = z.object({
  message: z.string().openapi({
    example: 'User deleted successfully',
    description: 'Confirmation message'
  }),
  user: UserSchema, // Include the UserSchema in the response
});

/**
 * Zod schema for error responses
 */
export const ErrorSchema = z.object({
  error: z.string().openapi({
    example: 'User not found',
    description: 'Error message explaining why the request failed'
  }),
});

/**
 * Zod schema for user ID parameter validation
 */
export const UserIdParamSchema = z.object({
  id: z.string().openapi({ 
    example: 'user-1234567890',
    description: 'Unique identifier of the user to retrieve/update/delete'
  }),
});