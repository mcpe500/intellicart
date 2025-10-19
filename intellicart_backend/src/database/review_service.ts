import { CreateReview } from '../schemas/ReviewSchemas';
import { db } from './db_service';
import { CreateReviewInput } from '../types/ProductTypes';

export const addReview = async (productId: string, reviewData: CreateReview, userId: string): Promise<any | null> => {
  try {
    // Transform the schema-based review data to the type expected by the database service
    const reviewInput: CreateReviewInput = {
      rating: reviewData.rating,
      title: reviewData.comment, // Using comment as title since the schema has comment but types have title
      reviewText: reviewData.comment,
    };

    const result = await db().addProductReview(productId, reviewInput, userId);
    return result;
  } catch (error) {
    console.error('Error adding review:', error);
    throw new Error('Failed to add review');
  }
};

export const getReviewsByProduct = async (productId: string): Promise<any[]> => {
  try {
    const product = await db().getProductById(productId);
    if (!product) {
      return [];
    }
    return product.reviews || [];
  } catch (error) {
    console.error('Error fetching reviews:', error);
    throw new Error('Failed to fetch reviews');
  }
};

export const getReviewById = async (productId: string, reviewId: string): Promise<any | null> => {
  try {
    const product = await db().getProductById(productId);
    if (!product || !product.reviews) {
      return null;
    }
    
    const review = product.reviews.find(r => r.id === reviewId);
    return review || null;
  } catch (error) {
    console.error('Error fetching review:', error);
    throw new Error('Failed to fetch review');
  }
};

// Note: The existing database service doesn't have direct methods for updating or deleting individual reviews
// Reviews are managed as part of the product document

export const getReviewsByUser = async (userId: string): Promise<any[]> => {
  try {
    // Get all products and filter reviews by user
    const products = await db().getAllProducts();
    const userReviews: any[] = [];
    
    for (const product of products) {
      if (product.reviews) {
        const userProductReviews = product.reviews.filter(review => review.userId === userId);
        // Add product info to each review
        userProductReviews.forEach(review => {
          userReviews.push({
            ...review,
            productId: product.id,
            productName: product.name,
          });
        });
      }
    }
    
    return userReviews;
  } catch (error) {
    console.error('Error fetching user reviews:', error);
    throw new Error('Failed to fetch user reviews');
  }
};