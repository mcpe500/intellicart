import { Context } from 'hono';
import { db } from '../database/db_service';
import { Logger } from '../utils/logger';
import { User } from '../types/UserTypes';

export class AdminController {
  // Get all users - admin only
  static async getAllUsers(c: Context) {
    try {
      const users = await db().getAllUsers();
      
      // Remove password from all users before returning
      const usersWithoutPassword = users.map(user => {
        const { password, ...userWithoutPassword } = user as any;
        return userWithoutPassword;
      });
      
      Logger.info(`Admin retrieved ${usersWithoutPassword.length} users`);
      return c.json(usersWithoutPassword);
    } catch (error) {
      Logger.error('Admin get all users error:', { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Failed to retrieve users' }, 500);
    }
  }

  // Get user by ID - admin only
  static async getUserById(c: Context) {
    try {
      const { id } = c.req.param();
      
      const user = await db().getUserById(id);
      
      if (!user) {
        Logger.warn(`Admin get user failed: User not found: ${id}`);
        return c.json({ error: 'User not found' }, 404);
      }
      
      // Remove password from user before returning
      const { password, ...userWithoutPassword } = user as any;
      
      Logger.info(`Admin retrieved user: ${id}`);
      return c.json(userWithoutPassword);
    } catch (error) {
      Logger.error(`Admin get user by ID error for user ${c.req.param('id')}:`, { 
        error: (error as Error).message, 
        stack: (error as Error).stack 
      });
      return c.json({ error: 'Failed to retrieve user' }, 500);
    }
  }

  // Update user role - admin only
  static async updateUserRole(c: Context) {
    try {
      const { id } = c.req.param();
      const { role } = await c.req.json();
      
      // Validate role
      if (!role || !['admin', 'seller', 'buyer'].includes(role)) {
        return c.json({ error: 'Invalid role. Must be admin, seller, or buyer' }, 400);
      }
      
      const currentUser = await db().getUserById(id);
      if (!currentUser) {
        Logger.warn(`Admin update role failed: User not found: ${id}`);
        return c.json({ error: 'User not found' }, 404);
      }
      
      // Update the user's role
      const userData: Partial<User> = { role };
      const updatedUser = await db().updateUser(id, userData);
      
      if (!updatedUser) {
        Logger.warn(`Admin update role failed: Failed to update user: ${id}`);
        return c.json({ error: 'Failed to update user' }, 500);
      }
      
      const { password, ...userWithoutPassword } = updatedUser as any;
      
      Logger.info(`Admin updated user role: ${id} to ${role}`);
      return c.json(userWithoutPassword);
    } catch (error) {
      Logger.error(`Admin update user role error for user ${c.req.param('id')}:`, { 
        error: (error as Error).message, 
        stack: (error as Error).stack 
      });
      return c.json({ error: 'Failed to update user role' }, 500);
    }
  }

  // Delete user - admin only
  static async deleteUser(c: Context) {
    try {
      const { id } = c.req.param();
      
      const user = await db().getUserById(id);
      if (!user) {
        Logger.warn(`Admin delete user failed: User not found: ${id}`);
        return c.json({ error: 'User not found' }, 404);
      }
      
      // In a real admin panel, you might want to implement soft delete or more complex logic
      const success = await db().deleteUser(id);
      
      if (!success) {
        Logger.warn(`Admin delete user failed: Failed to delete user: ${id}`);
        return c.json({ error: 'Failed to delete user' }, 500);
      }
      
      const { password, ...userWithoutPassword } = user as any;
      
      Logger.info(`Admin deleted user: ${id}`);
      // Combine the user data with the message
      const response = {
        ...userWithoutPassword,
        message: 'User deleted successfully'
      };
      
      return c.json(response);
    } catch (error) {
      Logger.error(`Admin delete user error for user ${c.req.param('id')}:`, { 
        error: (error as Error).message, 
        stack: (error as Error).stack 
      });
      return c.json({ error: 'Failed to delete user' }, 500);
    }
  }

  // Get system stats - admin only
  static async getSystemStats(c: Context) {
    try {
      const users = await db().getAllUsers();
      const products = await db().getAllProducts();
      
      const stats = {
        totalUsers: users.length,
        totalProducts: products.length,
        userRoles: {
          admin: users.filter(u => u.role === 'admin').length,
          seller: users.filter(u => u.role === 'seller').length,
          buyer: users.filter(u => u.role === 'buyer').length,
        },
        timestamp: new Date().toISOString()
      };
      
      Logger.info('Admin retrieved system stats');
      return c.json(stats);
    } catch (error) {
      Logger.error('Admin get system stats error:', { 
        error: (error as Error).message, 
        stack: (error as Error).stack 
      });
      return c.json({ error: 'Failed to retrieve system stats' }, 500);
    }
  }
}