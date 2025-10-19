import { Context } from 'hono';
import { db } from '../database/db_service';
import { Product, CreateProductInput, UpdateProductInput, CreateReviewInput } from '../types/ProductTypes';

export class ProductController {
  static async getAllProducts(c: Context) {
    try {
      // Get query parameters for pagination and filtering
      const { page = 1, limit = 10, search, category } = c.req.query();
      const pageNum = parseInt(page as string) || 1;
      const limitNum = Math.min(parseInt(limit as string) || 10, 100); // Cap at 100 per page
      
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
      
      return c.json(result);
    } catch (error) {
      console.error('Error retrieving all products:', error);
      return c.json({ error: 'Failed to retrieve products' }, 500);
    }
  }

  static async getSellerProducts(c: Context) {
    try {
      const sellerId = c.req.param('sellerId');
      
      // Get query parameters for pagination
      const { page = 1, limit = 10 } = c.req.query();
      const pageNum = parseInt(page as string) || 1;
      const limitNum = Math.min(parseInt(limit as string) || 10, 100); // Cap at 100 per page
      
      // Get products for the specific seller from database using pagination method
      const result = await db().getProductsBySellerIdWithPagination(sellerId, pageNum, limitNum);
      
      return c.json(result);
    } catch (error) {
      console.error('Error retrieving seller products:', error);
      return c.json({ error: 'Failed to retrieve seller products' }, 500);
    }
  }

  static async getProductById(c: Context) {
    const id = c.req.param('id');
    
    try {
      const product = await db().getProductById(id);
      
      if (!product) {
        return c.json({ error: 'Product not found' }, 404);
      }
      
      return c.json(product);
    } catch (error) {
      console.error(`Error retrieving product with ID ${id}:`, error);
      return c.json({ error: 'Failed to retrieve product' }, 500);
    }
  }

  static async createProduct(c: Context) {
    const jwtPayload = c.get('jwtPayload');
    if (!jwtPayload) {
      return c.json({ error: 'Authentication required' }, 401);
    }

    const sellerId = jwtPayload.id;

    try {
      const body = await c.req.json() as CreateProductInput;
      
      const newProduct = await db().createProduct(body, sellerId);
      
      return c.json(newProduct, 201);
    } catch (error) {
      console.error('Error creating product:', error);
      return c.json({ error: 'Failed to create product' }, 500);
    }
  }

  static async updateProduct(c: Context) {
    const id = c.req.param('id');
    
    try {
      const body = await c.req.json() as UpdateProductInput;
      const updatedProduct = await db().updateProduct(id, body);
      
      if (!updatedProduct) {
        return c.json({ error: 'Product not found' }, 404);
      }
      
      return c.json(updatedProduct);
    } catch (error) {
      console.error(`Error updating product with ID ${id}:`, error);
      return c.json({ error: 'Failed to update product' }, 500);
    }
  }

  static async deleteProduct(c: Context) {
    const id = c.req.param('id');
    
    try {
      const success = await db().deleteProduct(id);
      
      if (!success) {
        return c.json({ error: 'Product not found' }, 404);
      }
      
      return c.json({ message: 'Product deleted successfully' });
    } catch (error) {
      console.error(`Error deleting product with ID ${id}:`, error);
      return c.json({ error: 'Failed to delete product' }, 500);
    }
  }

  static async addReview(c: Context) {
    const productId = c.req.param('id');
    const jwtPayload = c.get('jwtPayload');
    
    if (!jwtPayload) {
      return c.json({ error: 'Authentication required' }, 401);
    }

    const userId = jwtPayload.id;

    try {
      const body = await c.req.json() as CreateReviewInput;
      
      // Validate rating is between 1 and 5
      if (body.rating < 1 || body.rating > 5) {
        return c.json({ error: 'Rating must be between 1 and 5' }, 400);
      }
      
      const review = await db().addProductReview(productId, body, userId);
      
      if (!review) {
        return c.json({ error: 'Product not found' }, 404);
      }
      
      return c.json(review, 201);
    } catch (error) {
      console.error(`Error adding review to product with ID ${productId}:`, error);
      return c.json({ error: 'Failed to add review' }, 500);
    }
  }
}