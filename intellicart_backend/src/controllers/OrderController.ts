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
      // Get query parameters for filtering and pagination
      const { status, page = 1, limit = 10 } = c.req.query();
      const pageNum = parseInt(page as string) || 1;
      const limitNum = Math.min(parseInt(limit as string) || 10, 100); // Cap at 100 per page
      
      // Get all orders for the seller
      const allOrders = await db().getOrdersBySellerId(sellerId);
      
      // Apply status filter if provided
      let filteredOrders = allOrders;
      if (status) {
        filteredOrders = filteredOrders.filter(order => 
          order.status.toLowerCase() === (status as string).toLowerCase()
        );
      }
      
      // Apply pagination
      const total = filteredOrders.length;
      const startIndex = (pageNum - 1) * limitNum;
      const endIndex = startIndex + limitNum;
      const orders = filteredOrders.slice(startIndex, endIndex);
      
      const result = {
        orders,
        pagination: {
          page: pageNum,
          limit: limitNum,
          total,
          totalPages: Math.ceil(total / limitNum)
        }
      };
      
      return c.json(result);
    } catch (error) {
      console.error('Error retrieving orders:', error);
      return c.json({ error: 'Failed to retrieve orders' }, 500);
    }
  }

  static async getOrdersByUser(c: Context) {
    const jwtPayload = c.get('jwtPayload');
    if (!jwtPayload) {
      return c.json({ error: 'Authentication required' }, 401);
    }

    const customerId = jwtPayload.id;

    try {
      // Get query parameters for filtering and pagination
      const { status, page = 1, limit = 10 } = c.req.query();
      const pageNum = parseInt(page as string) || 1;
      const limitNum = Math.min(parseInt(limit as string) || 10, 100); // Cap at 100 per page
      
      // Get all orders for the user
      const allOrders = await db().getOrdersByCustomerId(customerId);
      
      // Apply status filter if provided
      let filteredOrders = allOrders;
      if (status) {
        filteredOrders = filteredOrders.filter(order => 
          order.status.toLowerCase() === (status as string).toLowerCase()
        );
      }
      
      // Apply pagination
      const total = filteredOrders.length;
      const startIndex = (pageNum - 1) * limitNum;
      const endIndex = startIndex + limitNum;
      const orders = filteredOrders.slice(startIndex, endIndex);
      
      const result = {
        orders,
        pagination: {
          page: pageNum,
          limit: limitNum,
          total,
          totalPages: Math.ceil(total / limitNum)
        }
      };
      
      return c.json(result);
    } catch (error) {
      console.error('Error retrieving user orders:', error);
      return c.json({ error: 'Failed to retrieve user orders' }, 500);
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