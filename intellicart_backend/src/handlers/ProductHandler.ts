import { Context } from 'hono';
import { ProductController } from '../controllers/ProductController';
import { AddReviewRequest } from '../models/ProductDTO';

export class ProductHandler {
  static async getAllProducts(c: Context) {
    try {
      const productController = new ProductController();
      return await productController.getAll(c);
    } catch (error: any) {
      console.error('Error in getAllProducts:', error);
      return c.json({ error: 'Internal Server Error' }, 500);
    }
  }

  static async getProductById(c: Context) {
    try {
      const productController = new ProductController();
      return await productController.getById(c);
    } catch (error: any) {
      console.error('Error in getProductById:', error);
      return c.json({ error: 'Internal Server Error' }, 500);
    }
  }

  static async createProduct(c: Context) {
    try {
      const productController = new ProductController();
      const json = await c.req.json();
      return await productController.create(c, json);
    } catch (error: any) {
      console.error('Error in createProduct:', error);
      return c.json({ error: 'Internal Server Error' }, 500);
    }
  }

  static async updateProduct(c: Context) {
    try {
      const productController = new ProductController();
      const json = await c.req.json();
      return await productController.update(c, json);
    } catch (error: any) {
      console.error('Error in updateProduct:', error);
      return c.json({ error: 'Internal Server Error' }, 500);
    }
  }

  static async deleteProduct(c: Context) {
    try {
      const productController = new ProductController();
      return await productController.delete(c);
    } catch (error: any) {
      console.error('Error in deleteProduct:', error);
      return c.json({ error: 'Internal Server Error' }, 500);
    }
  }

  static async getSellerProducts(c: Context) {
    try {
      const user = c.get('user');
      const productController = new ProductController();
      const items = await productController['db'].findBy('products', { sellerId: user.userId });
      return c.json(items);
    } catch (error: any) {
      console.error('Error in getSellerProducts:', error);
      return c.json({ error: 'Internal Server Error' }, 500);
    }
  }

  static async addReview(c: Context) {
    try {
      const id = c.req.param('id');
      const json = await c.req.json() as AddReviewRequest;
      return await ProductController.addReviewToProduct(c, Number(id), json);
    } catch (error: any) {
      console.error('Error in addReview:', error);
      return c.json({ error: 'Internal Server Error' }, 500);
    }
  }
}