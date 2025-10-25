/**
 * Product Controller
 * 
 * This controller handles all product-related business logic including:
 * - Retrieving all products
 * - Retrieving a specific product by ID
 * - Creating new products
 * - Updating existing products
 * - Deleting products
 * - Retrieving products by seller
 * 
 * All methods are static for easy access from route handlers.
 * The controller uses the DatabaseManager for data persistence.
 * 
 * @class ProductController
 * @description Business logic layer for product operations
 * @author Intellicart Team
 * @version 1.0.0
 */

import { Context } from 'hono';
import { dbManager } from '../database/Config';

export class ProductController {
  /**
   * Retrieve all products from the database
   * 
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing array of all products
   * @route GET /api/products
   */
  static async getAllProducts(c: Context) {
    try {
      const db = dbManager.getDatabase<any>();
      const products = await db.findAll('products');
      return c.json(products);
    } catch (error) {
      console.error('Error retrieving all products:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  /**
   * Retrieve a specific product by ID
   * 
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing the product object or error if not found
   * @route GET /api/products/:id
   */
  static async getProductById(c: Context) {
    try {
      const id = Number(c.req.param('id'));
      
      const db = dbManager.getDatabase<any>();
      const product = await db.findById('products', id);
      
      if (!product) {
        return c.json({ error: 'Product not found' }, 404);
      }
      
      return c.json(product);
    } catch (error) {
      console.error('Error retrieving product by ID:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  /**
   * Create a new product in the database
   * 
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing the created product object
   * @route POST /api/products
   */
  static async createProduct(c: Context) {
    try {
      const body = c.req.valid('json') as {
        name: string;
        description: string;
        price: string;
        originalPrice?: string;
        imageUrl: string;
      };
      
      const db = dbManager.getDatabase<any>();
      
      // Get the user from context to set sellerId
      const user = c.get('user');
      
      const newProduct = {
        ...body,
        reviews: [],
        sellerId: user.userId,
        createdAt: new Date().toISOString(),
      };
      
      const createdProduct = await db.create('products', newProduct);
      
      return c.json(createdProduct, 201);
    } catch (error) {
      console.error('Error creating product:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  /**
   * Update an existing product by ID
   * 
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing the updated product object or error if not found
   * @route PUT /api/products/:id
   */
  static async updateProduct(c: Context) {
    try {
      const id = Number(c.req.param('id'));
      
      const body = c.req.valid('json') as {
        name?: string;
        description?: string;
        price?: string;
        originalPrice?: string;
        imageUrl?: string;
      };
      
      const db = dbManager.getDatabase<any>();
      
      // Check if product exists
      const existingProduct = await db.findById('products', id);
      if (!existingProduct) {
        return c.json({ error: 'Product not found' }, 404);
      }
      
      // Check if the user is the seller of this product
      const user = c.get('user');
      if (existingProduct.sellerId !== user.userId) {
        return c.json({ error: 'You can only update products you created' }, 403);
      }
      
      const updatedProduct = await db.update('products', id, body);
      
      if (!updatedProduct) {
        return c.json({ error: 'Product not found' }, 404);
      }
      
      return c.json(updatedProduct);
    } catch (error) {
      console.error('Error updating product:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  /**
   * Delete a product by ID
   * 
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response indicating success or error
   * @route DELETE /api/products/:id
   */
  static async deleteProduct(c: Context) {
    try {
      const id = Number(c.req.param('id'));
      
      const db = dbManager.getDatabase<any>();
      
      const product = await db.findById('products', id);
      
      if (!product) {
        return c.json({ error: 'Product not found' }, 404);
      }
      
      // Check if the user is the seller of this product
      const user = c.get('user');
      if (product.sellerId !== user.userId) {
        return c.json({ error: 'You can only delete products you created' }, 403);
      }
      
      const deleted = await db.delete('products', id);
      
      if (deleted) {
        return c.json({ 
          message: 'Product deleted successfully', 
          product 
        });
      } else {
        return c.json({ error: 'Failed to delete product' }, 500);
      }
    } catch (error) {
      console.error('Error deleting product:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  /**
   * Retrieve all products by a specific seller
   * 
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing array of products by seller
   * @route GET /api/products/seller/:sellerId
   */
  static async getSellerProducts(c: Context) {
    try {
      const sellerId = Number(c.req.param('sellerId'));
      const user = c.get('user');
      
      // Check if the requesting user is the seller
      if (user.userId !== sellerId) {
        return c.json({ error: 'Access denied' }, 403);
      }
      
      const db = dbManager.getDatabase<any>();
      const products = await db.findBy('products', { sellerId: sellerId });
      
      return c.json(products);
    } catch (error) {
      console.error('Error retrieving seller products:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
}