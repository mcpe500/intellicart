import { BaseService } from "./BaseService";
import { logger } from "../utils/logger";
import { Product, AddReviewRequest } from "../models/ProductDTO";
import { Review } from "../models/ProductDTO";
import { NotFoundError, ValidationError } from "../types/errors";

export class ProductService extends BaseService<Product> {
  constructor() {
    super("products");
  }

  async getSellerProducts(sellerId: number): Promise<Product[]> {
    return await this.db.findBy("products", { sellerId });
  }

  async addReviewToProduct(
    productId: number,
    reviewData: AddReviewRequest,
    userId: number,
  ): Promise<Product> {
    const product = await this.getById(productId);
    if (!product) {
      logger.error("Product not found when adding review", { productId });
      throw new NotFoundError("Product not found", { productId });
    }

    // Validate review data
    if (
      !reviewData.title ||
      !reviewData.reviewText ||
      reviewData.rating < 1 ||
      reviewData.rating > 5
    ) {
      throw new ValidationError(
        "Title, reviewText, and rating (1-5) are required",
      );
    }

    const newReview: Review = {
      id: Date.now(), // Use timestamp as ID for uniqueness
      ...reviewData,
      userId,
      timeAgo: "Just now",
      images: reviewData.images || [], // Add images if provided
    };

    const updatedReviews = [...(product.reviews || []), newReview];

    logger.info("Review added successfully", {
      productId,
      reviewId: newReview.id,
      totalReviews: updatedReviews.length,
    });

    const updatedProduct = await this.update(productId, {
      ...product,
      reviews: updatedReviews,
    });

    if (!updatedProduct) {
      throw new NotFoundError("Product not found after update", { productId });
    }

    return updatedProduct;
  }

  async getReviewsByProductId(productId: number): Promise<Review[]> {
    const product = await this.getById(productId);
    if (!product) {
      logger.error("Product not found when retrieving reviews", { productId });
      throw new NotFoundError("Product not found", { productId });
    }

    logger.info("Reviews retrieved successfully", {
      productId,
      reviewCount: product.reviews?.length || 0,
    });

    return product.reviews || [];
  }
}
