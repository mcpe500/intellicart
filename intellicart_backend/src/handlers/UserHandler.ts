import { Context } from 'hono';
import { BaseHandler } from './BaseHandler';
import { UserController } from '../controllers/UserController';

export class UserHandler {
  static async getAllUsers(c: Context) {
    return BaseHandler.handle(async (ctx) => {
      const userController = new UserController();
      return await userController.getAll(ctx);
    }, c);
  }

  static async getUserById(c: Context) {
    return BaseHandler.handle(async (ctx) => {
      const userController = new UserController();
      return await userController.getById(ctx);
    }, c);
  }

  static async createUser(c: Context) {
    return BaseHandler.handle(async (ctx) => {
      const userController = new UserController();
      return await userController.createUser(ctx);
    }, c);
  }

  static async updateUser(c: Context) {
    return BaseHandler.handle(async (ctx) => {
      const userController = new UserController();
      return await userController.updateUser(ctx);
    }, c);
  }

  static async deleteUser(c: Context) {
    return BaseHandler.handle(async (ctx) => {
      const userController = new UserController();
      return await userController.delete(ctx);
    }, c);
  }
}