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
  static async getAllProducts() {
    const db = dbManager.getDatabase<any>();
    const products = await db.findAll('products');
    
    // Log the product fetch with count
    console.log(`[INFO] Fetching products: ${products.length} products retrieved`);
    
    return products;
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
  static async getProductById(id: number) {
    const db = dbManager.getDatabase<any>();
    const product = await db.findById('products', id);
    
    if (!product) {
      const error = new Error('Product not found');
      (error as any).status = 404;
      throw error;
    }
    
    return product;
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
  static async createProduct(body: {
    name: string;
    description: string;
    price: string;
    originalPrice?: string;
    imageUrl: string;
  }, userId: number) {
    const db = dbManager.getDatabase<any>();
    
    const newProduct = {
      ...body,
      reviews: [],
      sellerId: userId,
      createdAt: new Date().toISOString(),
    };
    
    const createdProduct = await db.create('products', newProduct);
    
    return createdProduct;
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
  static async updateProduct(id: number, body: {
    name?: string;
    description?: string;
    price?: string;
    originalPrice?: string;
    imageUrl?: string;
    reviews?: any[]; // Allow reviews to be updated
  }, userId: number) {
    const db = dbManager.getDatabase<any>();
    
    // Check if product exists
    const existingProduct = await db.findById('products', id);
    if (!existingProduct) {
      const error = new Error('Product not found');
      (error as any).status = 404;
      throw error;
    }
    
    // Check if the user is the seller of this product
    if (existingProduct.sellerId !== userId) {
      const error = new Error('You can only update products you created');
      (error as any).status = 403;
      throw error;
    }
    
    const updatedProduct = await db.update('products', id, body);
    
    if (!updatedProduct) {
      const error = new Error('Product not found');
      (error as any).status = 404;
      throw error;
    }
    
    return updatedProduct;
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
  static async deleteProduct(id: number, userId: number) {
    const db = dbManager.getDatabase<any>();
    
    const product = await db.findById('products', id);
    
    if (!product) {
      const error = new Error('Product not found');
      (error as any).status = 404;
      throw error;
    }
    
    // Check if the user is the seller of this product
    if (product.sellerId !== userId) {
      const error = new Error('You can only delete products you created');
      (error as any).status = 403;
      throw error;
    }
    
    const deleted = await db.delete('products', id);
    
    if (deleted) {
      return {
        message: 'Product deleted successfully', 
        product 
      };
    } else {
      const error = new Error('Failed to delete product');
      (error as any).status = 500;
      throw error;
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
  static async getSellerProducts(sellerId: number, userId: number) {
    // Check if the requesting user is the seller
    if (userId !== sellerId) {
      const error = new Error('Access denied');
      (error as any).status = 403;
      throw error;
    }
    
    const db = dbManager.getDatabase<any>();
    const products = await db.findBy('products', { sellerId: sellerId });
    
    return products;
  }

  /**
   * Add a review to an existing product
   *
   * @static
   * @async
   * @param {number} productId - The ID of the product to add the review to.
   * @param {any} reviewData - The review data (title, text, rating).
   * @param {number} userId - The ID of the user submitting the review (optional, for tracking).
   * @returns {Promise<any>} The updated product object with the new review.
   * @throws {Error} Throws an error if the product is not found or on database error.
   */
  static async addReviewToProduct(productId: number, reviewData: any, userId?: number): Promise<any> {
    console.log(`[INFO] Attempting to add review to product ID: ${productId}`); // <-- ADD THIS LOG
    const db = dbManager.getDatabase<any>();

    // 1. Find the product
    const product = await db.findById('products', productId);
    if (!product) {
      console.error(`[ERROR] Product not found for ID: ${productId} during addReview`); // <-- ADD THIS LOG
      const error = new Error('Product not found');
      (error as any).status = 404;
      throw error;
    }

    // 2. Prepare the new review object
    const newReview = {
      id: (product.reviews?.length || 0) + 1, // Simple ID generation for the review within the product
      ...reviewData,
      timeAgo: 'Just now', // Or generate a timestamp server-side
      // userId: userId // Optionally add userId if you track who submitted
    };

    // 3. Add the new review to the product's reviews array
    const updatedReviews = [...(product.reviews || []), newReview];

    // 4. Update the product in the database with the new reviews array
    const updatedProduct = await db.update('products', productId, { reviews: updatedReviews });

    if (!updatedProduct) {
      // This case should ideally not happen if findById succeeded, but handle defensively
      const error = new Error('Failed to update product with review');
      (error as any).status = 500;
      throw error;
    }

    console.log(`[INFO] Added review to product ${productId}. New review count: ${updatedReviews.length}`); // Add log
    return updatedProduct; // Return the full updated product
  }
}