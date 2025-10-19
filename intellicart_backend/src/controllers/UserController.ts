/**
 * User Controller
 * 
 * This controller handles all user-related business logic including:
 * - Retrieving all users
 * - Retrieving a specific user by ID
 * - Creating new users
 * - Updating existing users
 * - Deleting users
 * 
 * All methods are static for easy access from route handlers.
 * The controller now uses the dual-mode database service (JSON or Firestore).
 * 
 * @class UserController
 * @description Business logic layer for user operations
 * @author Intellicart Team
 * @version 4.0.0
 */

import { Context } from 'hono';
import { db } from '../database/db_service';
import { User, CreateUserInput, UpdateUserInput } from '../types/UserTypes';
import { Logger } from '../utils/logger';

export class UserController {
  /**
   * Retrieve all users from the database (not implemented for security reasons)
   * 
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing array of all users
   * @route GET /api/users
   * 
   * This endpoint is not implemented for security/privacy reasons.
   */
  static async getAllUsers(c: Context) {
    return c.json({ error: 'Endpoint not available for privacy reasons' }, 404);
  }

  /**
   * Retrieve a specific user by ID from the database
   * 
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing the user object or error if not found
   * @route GET /api/users/:id
   * 
   * Example response (success):
   * {
   *   "id": "1",
   *   "name": "John Doe",
   *   "email": "john@example.com",
   *   "role": "buyer",
   *   "createdAt": "2023-01-01T00:00:00.000Z"
   * }
   * 
   * Example response (error):
   * {
   *   "error": "User not found"
   * }
   */
  static async getUserById(c: Context) {
    const id = c.req.param('id');
    
    try {
      const user: User | null = await db().getUserById(id);
      
      if (!user) {
        Logger.warn(`Get user failed: User not found: ${id}`);
        return c.json({ error: 'User not found' }, 404);
      }
      
      return c.json(user);
    } catch (error) {
      Logger.error(`Error retrieving user with ID ${id}:`, { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Failed to retrieve user' }, 500);
    }
  }

  /**
   * Create a new user in the database
   * 
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing the created user object
   * @route POST /api/users
   * 
   * Example request body:
   * {
   *   "name": "Jane Smith",
   *   "email": "jane@example.com",
   *   "password": "securepassword",
   *   "role": "buyer"
   * }
   * 
   * Example response:
   * {
   *   "id": "user-1234567890",
   *   "name": "Jane Smith",
   *   "email": "jane@example.com",
   *   "role": "buyer",
   *   "createdAt": "2023-01-01T00:00:00.000Z"
   * }
   */
  static async createUser(c: Context) {
    try {
      const body = await c.req.json() as CreateUserInput;
      Logger.debug('Create user request:', { email: body.email, role: body.role });
      
      const newUser: User = await db().createUser(body);
      Logger.info(`User created: ${newUser.id}`);
      
      return c.json(newUser, 201);
    } catch (error) {
      Logger.error('Error creating user:', { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Failed to create user' }, 500);
    }
  }

  /**
   * Update an existing user in the database
   * 
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing the updated user object or error if not found
   * @route PUT /api/users/:id
   * 
   * Example request body:
   * {
   *   "name": "Jane Smith Updated",
   *   "email": "jane.updated@example.com"
   * }
   * 
   * Example response (success):
   * {
   *   "id": "user-1234567890",
   *   "name": "Jane Smith Updated",
   *   "email": "jane.updated@example.com",
   *   "role": "buyer",
   *   "createdAt": "2023-01-01T00:00:00.000Z"
   * }
   * 
   * Example response (error):
   * {
   *   "error": "User not found"
   * }
   */
  static async updateUser(c: Context) {
    const id = c.req.param('id');
    
    try {
      Logger.warn(`Update user attempt for ID ${id}: Not supported`);
      return c.json({ error: 'User updates not supported through this endpoint' }, 400);
    } catch (error) {
      Logger.error(`Error updating user with ID ${id}:`, { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Failed to update user' }, 500);
    }
  }

  /**
   * Delete a user from the database
   * 
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response indicating success or error
   * @route DELETE /api/users/:id
   * 
   * Example response (success):
   * {
   *   "message": "User deleted successfully",
   *   "user": {
   *     "id": "user-1234567890",
   *     "name": "Jane Smith",
   *     "email": "jane@example.com",
   *     "role": "buyer",
   *     "createdAt": "2023-01-01T00:00:00.000Z"
   *   }
   * }
   * 
   * Example response (error):
   * {
   *   "error": "User not found"
   * }
   */
  static async deleteUser(c: Context) {
    const id = c.req.param('id');
    
    try {
      Logger.warn(`Delete user attempt for ID ${id}: Not supported`);
      return c.json({ error: 'User deletion not supported for security reasons' }, 400);
    } catch (error) {
      Logger.error(`Error deleting user with ID ${id}:`, { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Failed to delete user' }, 500);
    }
  }
}