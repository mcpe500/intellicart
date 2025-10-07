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
 * The controller uses a mock in-memory database for demonstration purposes.
 * 
 * @class UserController
 * @description Business logic layer for user operations
 * @author Intellicart Team
 * @version 1.0.0
 */

import { Context } from 'hono';
import { z } from 'zod';

/**
 * Mock in-memory database for users
 * In a real application, this would be replaced with a persistent database
 */
let users: Array<{
  id: number;
  name: string;
  email: string;
  age?: number;
  createdAt: string;
}> = [
  {
    id: 1,
    name: 'John Doe',
    email: 'john@example.com',
    age: 30,
    createdAt: new Date().toISOString(),
  },
];

export class UserController {
  /**
   * Retrieve all users from the mock database
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
    // Return all users in the mock database
    return c.json(users);
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
    // Extract user ID from request parameters and convert to number
    const id = Number(c.req.param('id'));
    
    // Find user in mock database by ID
    const user = users.find(u => u.id === id);
    
    // Return 404 if user not found
    if (!user) {
      return c.json({ error: 'User not found' }, 404);
    }
    
    // Return found user
    return c.json(user);
  }

  /**
   * Create a new user in the mock database
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
    // Extract validated request body from context
    // The body has already been validated against Zod schema in route definition
    const body = c.req.valid('json') as {
      name: string;
      email: string;
      age?: number;
    };
    
    // Generate new user object with auto-incremented ID and creation timestamp
    const newUser = {
      // Calculate new ID based on current highest ID in database
      id: users.length > 0 ? Math.max(...users.map(u => u.id)) + 1 : 1,
      ...body, // Spread validated request body into new user object
      createdAt: new Date().toISOString(), // Add creation timestamp
    };
    
    // Add new user to mock database
    users.push(newUser);
    
    // Return created user with 201 status (Created)
    return c.json(newUser, 201);
  }

  /**
   * Update an existing user in the mock database
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
    // Extract user ID from request parameters and convert to number
    const id = Number(c.req.param('id'));
    
    // Extract validated request body from context
    const body = c.req.valid('json') as {
      name?: string;
      email?: string;
      age?: number;
    };
    
    // Find index of user in mock database by ID
    const index = users.findIndex(u => u.id === id);
    
    // Return 404 if user not found
    if (index === -1) {
      return c.json({ error: 'User not found' }, 404);
    }
    
    // Update user object by merging existing data with validated request body
    users[index] = { ...users[index], ...body };
    
    // Return updated user
    return c.json(users[index]);
  }

  /**
   * Delete a user from the mock database
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
    // Extract user ID from request parameters and convert to number
    const id = Number(c.req.param('id'));
    
    // Find index of user in mock database by ID
    const index = users.findIndex(u => u.id === id);
    
    // Return 404 if user not found
    if (index === -1) {
      return c.json({ error: 'User not found' }, 404);
    }
    
    // Remove user from mock database and store the deleted user
    const deletedUser = users.splice(index, 1)[0];
    
    // Return success message and deleted user object
    return c.json({ 
      message: 'User deleted successfully', 
      user: deletedUser 
    });
  }
}