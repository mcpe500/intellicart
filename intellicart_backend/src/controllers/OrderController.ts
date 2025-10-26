/**
 * Order Controller
 * 
 * This controller handles all order-related business logic including:
 * - Retrieving orders for a seller
 * - Updating order status
 * 
 * All methods are static for easy access from route handlers.
 * The controller uses the DatabaseManager for data persistence.
 * 
 * @class OrderController
 * @description Business logic layer for order operations
 * @author Intellicart Team
 * @version 1.0.0
 */

import { Context } from 'hono';
import { dbManager } from '../database/Config';

export class OrderController {
  /**
   * Retrieve orders for the authenticated seller
   * 
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing array of orders for the seller
   * @route GET /api/orders
   */
  static async getSellerOrders(c: Context) {
    try {
      const user = c.get('user');
      
      const db = dbManager.getDatabase<any>();
      const orders = await db.findBy('orders', { sellerId: user.userId });
      
      return c.json(orders);
    } catch (error) {
      console.error('Error retrieving seller orders:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  /**
   * Update the status of an order
   * 
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing the updated order object or error
   * @route PUT /api/orders/:id/status
   */
  static async updateOrderStatus(c: Context) {
    try {
      const rawId = c.req.param('id');
      const id = Number(rawId);
      
      // Validate that the ID is a number
      if (isNaN(id) || id <= 0) {
        return c.json({ error: 'Invalid order ID' }, 400);
      }
      
      const body = await c.req.json() as { status: string };
      const { status } = body;
      const user = c.get('user');
      
      const db = dbManager.getDatabase<any>();
      
      // Check if order exists
      const existingOrder = await db.findById('orders', id);
      if (!existingOrder) {
        return c.json({ error: 'Order not found' }, 404);
      }
      
      // Check if the user is the seller of this order
      if (existingOrder.sellerId !== user.userId) {
        return c.json({ error: 'You can only update orders associated with your products' }, 403);
      }
      
      const updatedOrder = await db.update('orders', id, { status });
      
      if (!updatedOrder) {
        return c.json({ error: 'Order not found' }, 404);
      }
      
      return c.json(updatedOrder);
    } catch (error) {
      console.error('Error updating order status:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
}