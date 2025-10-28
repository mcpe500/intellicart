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
 * The controller delegates business logic to the ProductService.
 *
 * @class ProductController
 * @description Business logic layer for product operations
 * @author Intellicart Team
 * @version 1.0.0
 */

import { Context } from "hono";
import { BaseController } from "./BaseController";
import { ProductService } from "../services/ProductService";
import { ReviewService } from "../services/ReviewService";
import { AddReviewRequest } from "../models/ProductDTO";

export class ProductController extends BaseController<any> {
  private productService: ProductService;
  private reviewService: ReviewService;

  constructor() {
    super("products");
    this.productService = new ProductService();
    this.reviewService = new ReviewService();
  }

  /**
   * Add a review to an existing product
   *
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing the updated product with the new review
   * @route POST /api/products/:id/reviews
   */
  static async addReviewToProduct(
    c: Context,
    productId: number,
    reviewData: AddReviewRequest,
  ): Promise<any> {
    try {
      const user = c.get("user");

      const productService = new ProductService();
      const updatedProduct = await productService.addReviewToProduct(
        productId,
        reviewData,
        user.userId,
      );

      return c.json(updatedProduct, 201);
    } catch (error: any) {
      console.error("Error adding review to product:", error);
      if (error.message === "Product not found") {
        return c.json({ error: error.message }, 404);
      }
      return c.json({ error: "Internal server error" }, 500);
    }
  }

  async getSellerProducts(c: Context) {
    try {
      const user = c.get("user");
      const sellerId = user.userId;
      const products = await this.productService.getSellerProducts(sellerId);
      return c.json(products);
    } catch (error: any) {
      console.error("Error retrieving seller products:", error);
      return c.json({ error: "Internal server error" }, 500);
    }
  }
}
