import { Context } from 'hono';
import { BaseHandler } from './BaseHandler';
import { OrderController } from '../controllers/OrderController';

export class OrderHandler {
  static async getSellerOrders(c: Context) {
    return BaseHandler.handle(async (ctx) => {
      return await OrderController.getSellerOrders(ctx);
    }, c);
  }

  static async updateOrderStatus(c: Context) {
    return BaseHandler.handle(async (ctx) => {
      return await OrderController.updateOrderStatus(ctx);
    }, c);
  }
}