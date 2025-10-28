/**
 * Product Data Transfer Object (DTO) Module
 *
 * This module defines the data transfer objects for product-related operations.
 * These interfaces provide type safety and clear structure for product data
 * across the application.
 *
 * @module ProductDTO
 * @description DTOs for product data structures
 * @author Intellicart Team
 * @version 1.0.0
 */

// Interface for a Review entity
export interface Review {
  id: number;
  title: string;
  reviewText: string;
  rating: number;
  timeAgo: string; // e.g., "2 days ago", "Just now"
  images?: string[]; // Optional list of image URLs for the review
  userId?: number; // Optional user ID who submitted the review
}

// Interface for a Product entity
export interface Product {
  id: number;
  name: string;
  description: string;
  price: string;
  originalPrice?: string;
  imageUrl: string;
  reviews?: Review[];
  sellerId: number;
  createdAt?: string;
}

// Interface for creating a new product (request)
export interface CreateProductRequest {
  name: string;
  description: string;
  price: string;
  originalPrice?: string;
  imageUrl: string;
  sellerId: number;
}

// Interface for updating a product (request)
export interface UpdateProductRequest {
  name?: string;
  description?: string;
  price?: string;
  originalPrice?: string;
  imageUrl?: string;
}

// Interface for adding a review to a product (request)
export interface AddReviewRequest {
  title: string;
  reviewText: string;
  rating: number;
  images?: string[]; // Optional list of image URLs for the review
}
