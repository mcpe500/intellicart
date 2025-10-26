import { Context } from 'hono';
import { ProductController } from '../controllers/ProductController';

export class ProductHandler {
  static async getAllProducts(c: Context) {
    try {
      const products = await ProductController.getAllProducts();
      return c.json(products);
    } catch (error: any) {
      console.error('Error in getAllProducts handler:', error);
      const statusCode = error.status || 500;
      const errorMessage = error.message || 'Internal server error';
      return c.json({ error: errorMessage }, statusCode);
    }
  }

  static async getProductById(c: Context) {
    try {
      // Extract validated parameters HERE in the handler
      const { id } = c.req.valid('param') as { id: number };

      // Call controller with only the necessary data (the ID)
      const product = await ProductController.getProductById(id);

      // Handler formats the successful JSON response
      return c.json(product);
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
      const body = c.req.valid('json') as {
        name: string;
        description: string;
        price: string;
        originalPrice?: string;
        imageUrl: string;
      };
      
      // Get the user from context to get userId
      const user = c.get('user');
      
      // Call controller with the product body and userId
      const createdProduct = await ProductController.createProduct(body, user.userId);

      // Handler formats the successful JSON response
      return c.json(createdProduct, 201);
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
      const { id } = c.req.valid('param') as { id: number };
      
      const body = c.req.valid('json') as {
        name?: string;
        description?: string;
        price?: string;
        originalPrice?: string;
        imageUrl?: string;
        reviews?: any[]; // Allow reviews to be updated
      };
      
      // Get the user from context to get userId
      const user = c.get('user');
      
      // Call controller with the id, body and userId
      const updatedProduct = await ProductController.updateProduct(id, body, user.userId);

      // Handler formats the successful JSON response
      return c.json(updatedProduct);
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
      const { id } = c.req.valid('param') as { id: number };
      
      // Get the user from context to get userId
      const user = c.get('user');
      
      // Call controller with the id and userId
      const result = await ProductController.deleteProduct(id, user.userId);

      // Handler formats the successful JSON response
      return c.json(result);
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
      const { sellerId } = c.req.valid('param') as { sellerId: number };
      
      // Get the user from context to get userId
      const user = c.get('user');
      
      // Call controller with the sellerId and userId
      const products = await ProductController.getSellerProducts(sellerId, user.userId);

      // Handler formats the successful JSON response
      return c.json(products);
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
      // 1. Extract validated product ID and review data
      const { id: productId } = c.req.valid('param') as { id: number };
      const reviewData = c.req.valid('json') as { title: string; reviewText: string; rating: number };
      const user = c.get('user'); // Get authenticated user (optional for review)

      // 2. Call controller with the necessary data
      const updatedProduct = await ProductController.addReviewToProduct(
        productId,
        reviewData,
        user?.userId // Pass userId if available and needed
      );

      // 3. Handler formats the successful JSON response (return the updated product)
      return c.json(updatedProduct);

    } catch (error: any) {
      console.error('Error in addReview handler:', error);
      // 4. Handler formats the error JSON response
      const statusCode = error.status || 500;
      const errorMessage = error.message || 'Internal server error';
      return c.json({ error: errorMessage }, statusCode);
    }
  }
}