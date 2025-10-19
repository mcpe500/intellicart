import { Context } from 'hono';
import { db } from '../database/db_service';
import { Order } from '../types/OrderTypes';

export class OrderController {
  static async getOrdersBySeller(c: Context) {
    const jwtPayload = c.get('jwtPayload');
    if (!jwtPayload) {
      return c.json({ error: 'Authentication required' }, 401);
    }

    const sellerId = jwtPayload.id;

    try {
      const orders = await db().getOrdersBySellerId(sellerId);
      return c.json(orders);
    } catch (error) {
      console.error('Error retrieving orders:', error);
      return c.json({ error: 'Failed to retrieve orders' }, 500);
    }
  }

  static async updateOrderStatus(c: Context) {
    const jwtPayload = c.get('jwtPayload');
    if (!jwtPayload) {
      return c.json({ error: 'Authentication required' }, 401);
    }

    const orderId = c.req.param('id');
    const { status } = await c.req.json();

    try {
      // Verify that the authenticated user is the seller for this order
      const orders = await db().getOrdersBySellerId(jwtPayload.id);
      const order = orders.find(o => o.id === orderId);

      if (!order) {
        return c.json({ error: 'Order not found or you are not authorized to update this order' }, 403);
      }

      const updatedOrder = await db().updateOrderStatus(orderId, status);

      if (!updatedOrder) {
        return c.json({ error: 'Order not found' }, 404);
      }

      return c.json(updatedOrder);
    } catch (error) {
      console.error(`Error updating order status for order ${orderId}:`, error);
      return c.json({ error: 'Failed to update order status' }, 500);
    }
  }
}