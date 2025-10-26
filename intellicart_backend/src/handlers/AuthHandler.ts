import { Context } from 'hono';
import { BaseHandler } from './BaseHandler';
import { AuthController } from '../controllers/authController';

export class AuthHandler {
  static async register(c: Context) {
    return BaseHandler.handle(async (ctx) => {
      return await AuthController.register(ctx);
    }, c);
  }

  static async login(c: Context) {
    return BaseHandler.handle(async (ctx) => {
      return await AuthController.login(ctx);
    }, c);
  }

  static async logout(c: Context) {
    return BaseHandler.handle(async (ctx) => {
      return await AuthController.logout(ctx);
    }, c);
  }

  static async getMe(c: Context) {
    return BaseHandler.handle(async (ctx) => {
      return await AuthController.getCurrentUser(ctx);
    }, c);
  }

  static async verifyToken(c: Context) {
    return BaseHandler.handle(async (ctx) => {
      return await AuthController.verifyToken(ctx);
    }, c);
  }
}