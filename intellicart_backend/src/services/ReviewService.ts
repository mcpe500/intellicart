/**
 * Review Service Module
 * 
 * This service handles all review-related business logic including:
 * - Adding reviews to products
 * - Retrieving reviews for products
 * - Managing review data structure
 * 
 * The service uses the DatabaseManager for data persistence.
 * 
 * @module ReviewService
 * @description Business logic layer for review operations
 * @author Intellicart Team
 * @version 1.0.0
 */

import { BaseService } from './BaseService';
import { dbManager } from '../database/Config';
import { logger } from '../utils/logger';
import { Product, AddReviewRequest } from '../models/ProductDTO';
import { Review } from '../models/ProductDTO';
import { NotFoundError, ValidationError } from '../types/errors';

export class ReviewService extends BaseService<any> {
  constructor() {
    super('reviews');
  }

  /**
   * Add a review to a product
   * 
   * @param {number} productId - The ID of the product to add the review to
   * @param {AddReviewRequest} reviewData - The review data (title, text, rating)
   * @param {number} userId - Optional user ID of the reviewer
   * @returns {Promise<Product>} The updated product with the new review
   * @throws {Error} If the product is not found or if validation fails
   */
  async addReviewToProduct(productId: number, reviewData: AddReviewRequest, userId?: number): Promise<Product> {
    try {
      const db = dbManager.getDatabase<any>();
      const product: Product = await db.findById('products', productId);

      if (!product) {
        logger.error('Product not found when adding review', { productId });
        throw new NotFoundError('Product not found', { productId });
      }

      // Validate inputs
      if (!reviewData.title || !reviewData.reviewText || reviewData.rating < 1 || reviewData.rating > 5) {
        throw new ValidationError('Title, reviewText, and rating (1-5) are required');
      }

      // Create the new review object
      const newReview: Review = {
        id: Date.now(), // Simple ID generation for reviews
        ...reviewData,
        userId,
        timeAgo: 'Just now'
      };

      // Add the new review to the product's reviews array
      const updatedReviews = [...(product.reviews || []), newReview];
      const updatedProduct = await db.update('products', productId, { reviews: updatedReviews });

      logger.info('Review added successfully', { 
        productId, 
        reviewId: newReview.id, 
        totalReviews: updatedReviews.length 
      });
      
      return updatedProduct;
    } catch (error) {
      logger.error('Error adding review to product', { 
        productId, 
        error: (error as Error).message 
      });
      throw error;
    }
  }

  /**
   * Get all reviews for a specific product
   * 
   * @param {number} productId - The ID of the product to retrieve reviews for
   * @returns {Promise<Review[]>} Array of reviews for the product
   * @throws {Error} If the product is not found
   */
  async getReviewsByProductId(productId: number): Promise<Review[]> {
    try {
      const db = dbManager.getDatabase<any>();
      const product: Product = await db.findById('products', productId);

      if (!product) {
        logger.error('Product not found when retrieving reviews', { productId });
        throw new NotFoundError('Product not found', { productId });
      }

      logger.info('Reviews retrieved successfully', { productId, reviewCount: product.reviews?.length || 0 });
      
      return product.reviews || [];
    } catch (error) {
      logger.error('Error retrieving reviews for product', { 
        productId, 
        error: (error as Error).message 
      });
      throw error;
    }
  }

  /**
   * Create a new review object (helper method)
   */
  createReviewObject(reviewData: AddReviewRequest, userId?: number): Review {
    // Validate inputs
    if (!reviewData.title || !reviewData.reviewText || reviewData.rating < 1 || reviewData.rating > 5) {
      throw new ValidationError('Title, reviewText, and rating (1-5) are required');
    }

    // Create the new review object
    const newReview: Review = {
      id: Date.now(), // Simple ID generation for reviews
      ...reviewData,
      userId,
      timeAgo: 'Just now'
    };

    return newReview;
  }
}