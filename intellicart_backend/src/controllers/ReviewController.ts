/**
 * Review Controller
 * 
 * This controller handles all review-related business logic including:
 * - Adding reviews to products
 * - Retrieving reviews for products
 * 
 * All methods are static for easy access from route handlers.
 * The controller uses the DatabaseManager for data persistence.
 * 
 * @class ReviewController
 * @description Business logic layer for review operations
 * @author Intellicart Team
 * @version 1.0.0
 */

import { Context } from 'hono';
import { dbManager } from '../database/Config';
import { logger } from '../utils/logger';

export class ReviewController {
  /**
   * Add a review to an existing product
   *
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing the updated product with the new review
   * @route POST /api/products/:id/reviews
   */
  static async addReviewToProduct(c: Context) {
    try {
      const productId = Number(c.req.param('id'));
      const reviewData = await c.req.json() as {
        title: string;
        reviewText: string;
        rating: number;
      };
      const user = c.get('user');

      const db = dbManager.getDatabase<any>();

      // 1. Find the product
      const product: any = await db.findById('products', productId);
      if (!product) {
        logger.error('Product not found when adding review', { productId });
        return c.json({ error: 'Product not found' }, 404);
      }

      // 2. Validate the review data
      if (!reviewData.title || !reviewData.reviewText || reviewData.rating < 1 || reviewData.rating > 5) {
        return c.json({ 
          error: 'Title, reviewText, and rating (1-5) are required' 
        }, 400);
      }

      // 3. Prepare the new review object
      const newReview = {
        id: Date.now(), // Simple ID generation for the review
        title: reviewData.title,
        reviewText: reviewData.reviewText,
        rating: reviewData.rating,
        timeAgo: 'Just now', // Set default timeAgo
        userId: user.userId // Track who submitted the review
      };

      // 4. Add the new review to the product's reviews array
      const updatedReviews = [...(product.reviews || []), newReview];
      const updatedProduct = await db.update('products', productId, { reviews: updatedReviews });

      if (!updatedProduct) {
        return c.json({ error: 'Failed to update product with review' }, 500);
      }

      logger.info('Review added successfully', { 
        productId, 
        reviewId: newReview.id, 
        userId: user.userId,
        totalReviews: updatedReviews.length 
      });

      c.status(201);
      return c.json({
        message: 'Review added successfully',
        review: newReview
      });
    } catch (error) {
      console.error('Error adding review to product:', error);
      logger.error('Error adding review to product', { error: (error as Error).message });
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  /**
   * Get all reviews for a specific product
   *
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing an array of reviews for the product
   * @route GET /api/products/:id/reviews
   */
  static async getReviewsByProductId(c: Context) {
    try {
      const productId = Number(c.req.param('id'));

      const db = dbManager.getDatabase<any>();
      const product: any = await db.findById('products', productId);

      if (!product) {
        logger.error('Product not found when retrieving reviews', { productId });
        return c.json({ error: 'Product not found' }, 404);
      }

      logger.info('Reviews retrieved successfully', { 
        productId, 
        reviewCount: product.reviews?.length || 0 
      });

      return c.json({ reviews: product.reviews || [] });
    } catch (error) {
      console.error('Error retrieving reviews for product:', error);
      logger.error('Error retrieving reviews for product', { error: (error as Error).message });
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
}