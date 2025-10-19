import { Context } from 'hono';
import { db } from '../database/db_service';
import { Product, CreateProductInput, UpdateProductInput, CreateReviewInput } from '../types/ProductTypes';
import { Logger } from '../utils/logger';

export class ProductController {
  static async getAllProducts(c: Context) {
    try {
      // Get query parameters for pagination and filtering
      const { page = 1, limit = 10, search, category } = c.req.query();
      const pageNum = parseInt(page as string) || 1;
      const limitNum = Math.min(parseInt(limit as string) || 10, 100); // Cap at 100 per page
      
      Logger.debug('Fetching products', { page: pageNum, limit: limitNum, search, category });
      
      // Get all products from database
      const allProducts = await db().getAllProducts();
      
      // Apply search and category filters if provided
      let filteredProducts = allProducts;
      
      if (search) {
        const searchTerm = (search as string).toLowerCase();
        filteredProducts = filteredProducts.filter(product => 
          product.name.toLowerCase().includes(searchTerm) || 
          product.description.toLowerCase().includes(searchTerm)
        );
      }
      
      if (category) {
        filteredProducts = filteredProducts.filter(product => 
          product.categoryId === category
        );
      }
      
      // Pagination
      const total = filteredProducts.length;
      const startIndex = (pageNum - 1) * limitNum;
      const endIndex = startIndex + limitNum;
      const products = filteredProducts.slice(startIndex, endIndex);
      
      const result = {
        products,
        pagination: {
          page: pageNum,
          limit: limitNum,
          total,
          totalPages: Math.ceil(total / limitNum)
        }
      };
      
      Logger.info(`Successfully fetched ${products.length} products out of total ${total}`);
      return c.json(result);
    } catch (error) {
      Logger.error('Error retrieving all products:', { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Failed to retrieve products' }, 500);
    }
  }

  static async getSellerProducts(c: Context) {
    try {
      const sellerId = c.req.param('sellerId');
      
      const { page = 1, limit = 10 } = c.req.query();
      const pageNum = parseInt(page as string) || 1;
      const limitNum = Math.min(parseInt(limit as string) || 10, 100);
      
      Logger.debug('Fetching seller products:', { sellerId, page: pageNum, limit: limitNum });
      const result = await db().getProductsBySellerIdWithPagination(sellerId, pageNum, limitNum);
      
      Logger.info(`Fetched ${result.products.length} products for seller: ${sellerId}`);
      return c.json(result);
    } catch (error) {
      Logger.error('Error retrieving seller products:', { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Failed to retrieve seller products' }, 500);
    }
  }

  static async getProductById(c: Context) {
    const id = c.req.param('id');
    
    try {
      const product = await db().getProductById(id);
      
      if (!product) {
        Logger.warn(`Get product failed: Product not found: ${id}`);
        return c.json({ error: 'Product not found' }, 404);
      }
      
      return c.json(product);
    } catch (error) {
      Logger.error(`Error retrieving product with ID ${id}:`, { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Failed to retrieve product' }, 500);
    }
  }

  static async createProduct(c: Context) {
    const jwtPayload = c.get('jwtPayload');
    if (!jwtPayload) {
      Logger.warn('Create product failed: No authentication');
      return c.json({ error: 'Authentication required' }, 401);
    }

    const sellerId = jwtPayload.id;

    try {
      const body = await c.req.json() as CreateProductInput;
      Logger.debug('Create product request:', { sellerId, productName: body.name });
      
      const newProduct = await db().createProduct(body, sellerId);
      Logger.info(`Product created: ${newProduct.id} by seller: ${sellerId}`);
      
      return c.json(newProduct, 201);
    } catch (error) {
      Logger.error('Error creating product:', { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Failed to create product' }, 500);
    }
  }

  static async updateProduct(c: Context) {
    const id = c.req.param('id');
    
    try {
      const body = await c.req.json() as UpdateProductInput;
      Logger.debug('Update product request:', { productId: id });
      
      const updatedProduct = await db().updateProduct(id, body);
      
      if (!updatedProduct) {
        Logger.warn(`Update product failed: Product not found: ${id}`);
        return c.json({ error: 'Product not found' }, 404);
      }
      
      Logger.info(`Product updated: ${id}`);
      return c.json(updatedProduct);
    } catch (error) {
      Logger.error(`Error updating product with ID ${id}:`, { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Failed to update product' }, 500);
    }
  }

  static async deleteProduct(c: Context) {
    const id = c.req.param('id');
    
    try {
      const success = await db().deleteProduct(id);
      
      if (!success) {
        Logger.warn(`Delete product failed: Product not found: ${id}`);
        return c.json({ error: 'Product not found' }, 404);
      }
      
      Logger.info(`Product deleted: ${id}`);
      return c.json({ message: 'Product deleted successfully' });
    } catch (error) {
      Logger.error(`Error deleting product with ID ${id}:`, { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Failed to delete product' }, 500);
    }
  }

  static async addReview(c: Context) {
    const productId = c.req.param('id');
    const jwtPayload = c.get('jwtPayload');
    
    if (!jwtPayload) {
      Logger.warn('Add review failed: No authentication');
      return c.json({ error: 'Authentication required' }, 401);
    }

    const userId = jwtPayload.id;

    try {
      const body = await c.req.json() as CreateReviewInput;
      Logger.debug('Add review request:', { productId, userId, rating: body.rating });
      
      if (body.rating < 1 || body.rating > 5) {
        Logger.warn(`Add review failed: Invalid rating: ${body.rating}`);
        return c.json({ error: 'Rating must be between 1 and 5' }, 400);
      }
      
      const review = await db().addProductReview(productId, body, userId);
      
      if (!review) {
        Logger.warn(`Add review failed: Product not found: ${productId}`);
        return c.json({ error: 'Product not found' }, 404);
      }
      
      Logger.info(`Review added to product: ${productId} by user: ${userId}`);
      return c.json(review, 201);
    } catch (error) {
      Logger.error(`Error adding review to product with ID ${productId}:`, { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Failed to add review' }, 500);
    }
  }
}