import { Context } from 'hono';
import { ProductController } from '../controllers/ProductController';

export class ProductHandler {
  static async getAllProducts(c: Context) {
    try {
      return await ProductController.getAllProducts(c);
    } catch (error: any) {
      console.error('Error in getAllProducts handler:', error);
      const statusCode = error.status || 500;
      const errorMessage = error.message || 'Internal server error';
      return c.json({ error: errorMessage }, statusCode);
    }
  }

  static async getProductById(c: Context) {
    try {
      // Pass context directly to controller which handles parameter extraction
      return await ProductController.getProductById(c);
    } catch (error: any) {
      console.error('Error in getProductById handler:', error);

      // Handler formats the error JSON response
      // Use status from error if available (like the 404 we added), else default to 500
      const statusCode = error.status || 500;
      const errorMessage = error.message || 'Internal server error';
      return c.json({ error: errorMessage }, statusCode);
    }
  }

  static async createProduct(c: Context) {
    try {
      // Pass context directly to controller which handles extraction internally
      return await ProductController.createProduct(c);
    } catch (error: any) {
      console.error('Error in createProduct handler:', error);

      // Handler formats the error JSON response
      const statusCode = error.status || 500;
      const errorMessage = error.message || 'Internal server error';
      return c.json({ error: errorMessage }, statusCode);
    }
  }

  static async updateProduct(c: Context) {
    try {
      // Pass context directly to controller which handles extraction internally
      return await ProductController.updateProduct(c);
    } catch (error: any) {
      console.error('Error in updateProduct handler:', error);

      // Handler formats the error JSON response
      const statusCode = error.status || 500;
      const errorMessage = error.message || 'Internal server error';
      return c.json({ error: errorMessage }, statusCode);
    }
  }

  static async deleteProduct(c: Context) {
    try {
      // Pass context directly to controller which handles extraction internally
      return await ProductController.deleteProduct(c);
    } catch (error: any) {
      console.error('Error in deleteProduct handler:', error);

      // Handler formats the error JSON response
      const statusCode = error.status || 500;
      const errorMessage = error.message || 'Internal server error';
      return c.json({ error: errorMessage }, statusCode);
    }
  }

  static async getSellerProducts(c: Context) {
    try {
      // Pass context directly to controller which handles extraction internally
      return await ProductController.getSellerProducts(c);
    } catch (error: any) {
      console.error('Error in getSellerProducts handler:', error);

      // Handler formats the error JSON response
      const statusCode = error.status || 500;
      const errorMessage = error.message || 'Internal server error';
      return c.json({ error: errorMessage }, statusCode);
    }
  }

  /**
   * Handler for POST /api/products/:id/reviews
   * Extracts data, calls controller, and handles HTTP response/errors.
   */
  static async addReview(c: Context) {
    try {
      // Pass context directly to controller which handles extraction internally
      return await ProductController.addReviewToProduct(c);

    } catch (error: any) {
      console.error('Error in addReview handler:', error);
      // Handler formats the error JSON response
      const statusCode = error.status || 500;
      const errorMessage = error.message || 'Internal server error';
      return c.json({ error: errorMessage }, statusCode);
    }
  }
}