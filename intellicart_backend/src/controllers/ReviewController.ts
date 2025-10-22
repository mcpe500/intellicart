import { Context } from 'hono';
import { z } from 'zod';
import { CreateReviewSchema } from '../schemas/ReviewSchemas';
import * as reviewService from '../database/review_service';

export const createReview = async (c: Context) => {
  try {
    // Extract the JSON body
    const body = await c.req.json();
    const validatedData = CreateReviewSchema.parse(body);
    
    // Extract productId from the URL path (for Hono)
    const productId = c.req.param('productId');
    const userId = c.get('userId') || body.userId; // Assuming userId might come from auth middleware or body
    
    if (!productId) {
      return c.json({
        success: false,
        message: 'Product ID is required',
      }, 400);
    }
    
    if (!userId) {
      return c.json({
        success: false,
        message: 'User ID is required',
      }, 400);
    }
    
    // Check if user already reviewed this product
    // This would require additional logic to check if a review from the same user for the same product already exists
    // For now, we'll proceed with creating the review
    
    const result = await reviewService.addReview(productId, validatedData, userId);
    
    if (!result) {
      return c.json({
        success: false,
        message: 'Failed to add review',
      }, 500);
    }
    
    return c.json({
      success: true,
      message: 'Review created successfully',
      data: result,
    }, 201);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return c.json({
        success: false,
        message: 'Validation error',
        errors: error.errors,
      }, 400);
    } else {
      console.error('Error creating review:', error);
      return c.json({
        success: false,
        message: 'Failed to create review',
      }, 500);
    }
  }
};

export const getReviewsByProduct = async (c: Context) => {
  try {
    const productId = c.req.param('productId');
    
    if (!productId) {
      return c.json({
        success: false,
        message: 'Product ID is required',
      }, 400);
    }
    
    const reviews = await reviewService.getReviewsByProduct(productId);
    
    return c.json({
      success: true,
      data: reviews,
      count: reviews.length,
    }, 200);
  } catch (error) {
    console.error('Error fetching reviews:', error);
    return c.json({
      success: false,
      message: 'Failed to fetch reviews',
    }, 500);
  }
};

export const getReviewById = async (c: Context) => {
  try {
    const productId = c.req.param('productId');
    const reviewId = c.req.param('id');
    
    if (!productId || !reviewId) {
      return c.json({
        success: false,
        message: 'Product ID and Review ID are required',
      }, 400);
    }
    
    const review = await reviewService.getReviewById(productId, reviewId);
    
    if (!review) {
      return c.json({
        success: false,
        message: 'Review not found',
      }, 404);
    }
    
    return c.json({
      success: true,
      data: review,
    }, 200);
  } catch (error) {
    console.error('Error fetching review:', error);
    return c.json({
      success: false,
      message: 'Failed to fetch review',
    }, 500);
  }
};

// Note: The existing database service doesn't have direct methods for updating or deleting individual reviews
// Reviews are managed as part of the product document

export const getReviewsByUser = async (c: Context) => {
  try {
    const userId = c.req.param('userId');
    
    if (!userId) {
      return c.json({
        success: false,
        message: 'User ID is required',
      }, 400);
    }
    
    const reviews = await reviewService.getReviewsByUser(userId);
    
    return c.json({
      success: true,
      data: reviews,
      count: reviews.length,
    }, 200);
  } catch (error) {
    console.error('Error fetching user reviews:', error);
    return c.json({
      success: false,
      message: 'Failed to fetch user reviews',
    }, 500);
  }
};