import { Context } from 'hono';
import { db } from '../database/db_service';
import { Order } from '../types/OrderTypes';
import { Logger } from '../utils/logger';

export class OrderController {
  static async getOrdersBySeller(c: Context) {
    const jwtPayload = c.get('jwtPayload');
    if (!jwtPayload) {
      Logger.warn('Get orders by seller failed: No authentication');
      return c.json({ error: 'Authentication required' }, 401);
    }

    const sellerId = jwtPayload.id;

    try {
      const { status, page = 1, limit = 10 } = c.req.query();
      const pageNum = parseInt(page as string) || 1;
      const limitNum = Math.min(parseInt(limit as string) || 10, 100);
      
      Logger.debug('Fetching orders by seller:', { sellerId, status, page: pageNum, limit: limitNum });
      const allOrders = await db().getOrdersBySellerId(sellerId);
      
      let filteredOrders = allOrders;
      if (status) {
        filteredOrders = filteredOrders.filter(order => 
          order.status.toLowerCase() === (status as string).toLowerCase()
        );
      }
      
      const total = filteredOrders.length;
      const startIndex = (pageNum - 1) * limitNum;
      const endIndex = startIndex + limitNum;
      const orders = filteredOrders.slice(startIndex, endIndex);
      
      Logger.info(`Fetched ${orders.length} orders for seller: ${sellerId}`);
      return c.json({
        orders,
        pagination: {
          page: pageNum,
          limit: limitNum,
          total,
          totalPages: Math.ceil(total / limitNum)
        }
      });
    } catch (error) {
      Logger.error('Error retrieving orders:', { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Failed to retrieve orders' }, 500);
    }
  }

  static async getOrdersByUser(c: Context) {
    const jwtPayload = c.get('jwtPayload');
    if (!jwtPayload) {
      Logger.warn('Get orders by user failed: No authentication');
      return c.json({ error: 'Authentication required' }, 401);
    }

    const customerId = jwtPayload.id;

    try {
      const { status, page = 1, limit = 10 } = c.req.query();
      const pageNum = parseInt(page as string) || 1;
      const limitNum = Math.min(parseInt(limit as string) || 10, 100);
      
      Logger.debug('Fetching orders by user:', { customerId, status, page: pageNum, limit: limitNum });
      const allOrders = await db().getOrdersByCustomerId(customerId);
      
      let filteredOrders = allOrders;
      if (status) {
        filteredOrders = filteredOrders.filter(order => 
          order.status.toLowerCase() === (status as string).toLowerCase()
        );
      }
      
      const total = filteredOrders.length;
      const startIndex = (pageNum - 1) * limitNum;
      const endIndex = startIndex + limitNum;
      const orders = filteredOrders.slice(startIndex, endIndex);
      
      Logger.info(`Fetched ${orders.length} orders for user: ${customerId}`);
      return c.json({
        orders,
        pagination: {
          page: pageNum,
          limit: limitNum,
          total,
          totalPages: Math.ceil(total / limitNum)
        }
      });
    } catch (error) {
      Logger.error('Error retrieving user orders:', { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Failed to retrieve user orders' }, 500);
    }
  }

  static async updateOrderStatus(c: Context) {
    const jwtPayload = c.get('jwtPayload');
    if (!jwtPayload) {
      Logger.warn('Update order status failed: No authentication');
      return c.json({ error: 'Authentication required' }, 401);
    }

    const orderId = c.req.param('id');
    const { status } = await c.req.json();

    try {
      Logger.debug('Update order status request:', { orderId, status, sellerId: jwtPayload.id });
      
      const orders = await db().getOrdersBySellerId(jwtPayload.id);
      const order = orders.find(o => o.id === orderId);

      if (!order) {
        Logger.warn(`Update order status failed: Order not found or unauthorized: ${orderId}`);
        return c.json({ error: 'Order not found or you are not authorized to update this order' }, 403);
      }

      const updatedOrder = await db().updateOrderStatus(orderId, status);

      if (!updatedOrder) {
        Logger.warn(`Update order status failed: Order not found: ${orderId}`);
        return c.json({ error: 'Order not found' }, 404);
      }

      Logger.info(`Order status updated: ${orderId} to ${status}`);
      return c.json(updatedOrder);
    } catch (error) {
      Logger.error(`Error updating order status for order ${orderId}:`, { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Failed to update order status' }, 500);
    }
  }
}