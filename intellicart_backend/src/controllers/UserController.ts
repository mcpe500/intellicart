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
 * The controller delegates business logic to the UserService.
 *
 * @class UserController
 * @description Business logic layer for user operations
 * @author Intellicart Team
 * @version 1.0.0
 */

import { Context } from 'hono';
import { BaseController } from './BaseController';
import { UserService } from '../services/UserService';
import { CreateUserRequest, UpdateUserRequest } from '../models/UserDTO';

export class UserController extends BaseController<any> {
  private userService: UserService;

  constructor() {
    super('users');
    this.userService = new UserService();
  }

  // Override the create method to add user-specific logic
  async createUser(c: Context) {
    try {
      const body = await c.req.json();

      const createdUser = await this.userService.createUser(body);
      return c.json(createdUser, 201);
    } catch (error: any) {
      if (error.message === 'User with this email already exists') {
        return c.json({ error: error.message }, 409);
      }
      console.error('Error creating user:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  // Override the update method to add user-specific logic
  async updateUser(c: Context) {
    try {
      const { id } = c.req.param('id');
      const body = await c.req.json();

      const updatedUser = await this.userService.updateUser(id, body);
      return c.json(updatedUser);
    } catch (error: any) {
      if (error.message === 'User not found') {
        return c.json({ error: error.message }, 404);
      }
      if (error.message === 'User with this email already exists') {
        return c.json({ error: error.message }, 409);
      }
      console.error('Error updating user:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
}
