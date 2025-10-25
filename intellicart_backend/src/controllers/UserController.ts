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
 * The controller uses the DatabaseManager for data persistence.
 * 
 * @class UserController
 * @description Business logic layer for user operations
 * @author Intellicart Team
 * @version 1.0.0
 */

import { Context } from 'hono';
import { z } from 'zod';
import { dbManager } from '../database/Config';

export class UserController {
  /**
   * Retrieve all users from the database
   * 
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing array of all users
   * @route GET /api/users
   * 
   * Example response:
   * [
   *   {
   *     "id": 1,
   *     "name": "John Doe",
   *     "email": "john@example.com",
   *     "age": 30,
   *     "createdAt": "2023-01-01T00:00:00.000Z"
   *   }
   * ]
   */
  static async getAllUsers(c: Context) {
    try {
      const db = dbManager.getDatabase<any>();
      const users = await db.findAll('users');
      return c.json(users);
    } catch (error) {
      console.error('Error retrieving all users:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  /**
   * Retrieve a specific user by ID
   * 
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing the user object or error if not found
   * @route GET /api/users/:id
   * 
   * Example response (success):
   * {
   *   "id": 1,
   *   "name": "John Doe",
   *   "email": "john@example.com",
   *   "age": 30,
   *   "createdAt": "2023-01-01T00:00:00.000Z"
   * }
   * 
   * Example response (error):
   * {
   *   "error": "User not found"
   * }
   */
  static async getUserById(c: Context) {
    try {
      const id = Number(c.req.param('id'));
      
      const db = dbManager.getDatabase<any>();
      const user = await db.findById('users', id);
      
      if (!user) {
        return c.json({ error: 'User not found' }, 404);
      }
      
      return c.json(user);
    } catch (error) {
      console.error('Error retrieving user by ID:', error);
      return c.json({ error: 'Internal server error' }, 500);
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
   *   "age": 25
   * }
   * 
   * Example response:
   * {
   *   "id": 2,
   *   "name": "Jane Smith",
   *   "email": "jane@example.com",
   *   "age": 25,
   *   "createdAt": "2023-01-01T00:00:00.000Z"
   * }
   */
  static async createUser(c: Context) {
    try {
      const body = c.req.valid('json') as {
        name: string;
        email: string;
        age?: number;
      };
      
      const db = dbManager.getDatabase<any>();
      
      // Check if user already exists
      const existingUser = await db.findOne('users', { email: body.email });
      if (existingUser) {
        return c.json({ error: 'User with this email already exists' }, 409);
      }
      
      const newUser = {
        ...body,
        createdAt: new Date().toISOString(),
      };
      
      const createdUser = await db.create('users', newUser);
      
      return c.json(createdUser, 201);
    } catch (error) {
      console.error('Error creating user:', error);
      return c.json({ error: 'Internal server error' }, 500);
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
   *   "age": 26
   * }
   * 
   * Example response (success):
   * {
   *   "id": 2,
   *   "name": "Jane Smith Updated",
   *   "email": "jane@example.com",
   *   "age": 26,
   *   "createdAt": "2023-01-01T00:00:00.000Z"
   * }
   * 
   * Example response (error):
   * {
   *   "error": "User not found"
   * }
   */
  static async updateUser(c: Context) {
    try {
      const id = Number(c.req.param('id'));
      
      const body = c.req.valid('json') as {
        name?: string;
        email?: string;
        age?: number;
      };
      
      const db = dbManager.getDatabase<any>();
      
      // Check if user exists
      const existingUser = await db.findById('users', id);
      if (!existingUser) {
        return c.json({ error: 'User not found' }, 404);
      }
      
      // Check if email is being updated and already exists for another user
      if (body.email && body.email !== existingUser.email) {
        const duplicateUser = await db.findOne('users', { email: body.email });
        if (duplicateUser) {
          return c.json({ error: 'User with this email already exists' }, 409);
        }
      }
      
      const updatedUser = await db.update('users', id, body);
      
      if (!updatedUser) {
        return c.json({ error: 'User not found' }, 404);
      }
      
      return c.json(updatedUser);
    } catch (error) {
      console.error('Error updating user:', error);
      return c.json({ error: 'Internal server error' }, 500);
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
   *     "id": 2,
   *     "name": "Jane Smith",
   *     "email": "jane@example.com",
   *     "age": 25,
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
    try {
      const id = Number(c.req.param('id'));
      
      const db = dbManager.getDatabase<any>();
      
      const deletedUser = await db.findById('users', id);
      
      if (!deletedUser) {
        return c.json({ error: 'User not found' }, 404);
      }
      
      const deleted = await db.delete('users', id);
      
      if (deleted) {
        return c.json({ 
          message: 'User deleted successfully', 
          user: deletedUser 
        });
      } else {
        return c.json({ error: 'Failed to delete user' }, 500);
      }
    } catch (error) {
      console.error('Error deleting user:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
}