import { Context } from "hono";
import { BaseHandler } from "./BaseHandler";
import { ReviewController } from "../controllers/ReviewController";

export class ReviewHandler {
  static async addReviewToProduct(c: Context) {
    return BaseHandler.handle(async (ctx) => {
      return await ReviewController.addReviewToProduct(ctx);
    }, c);
  }

  static async getReviewsByProductId(c: Context) {
    return BaseHandler.handle(async (ctx) => {
      const productId = Number(ctx.req.param("id"));
      try {
        // For now, we'll use the database directly since we don't have a method in ReviewController
        // In a full implementation, we would have a method in ReviewController
        const { dbManager } = await import("../database/Config");
        const db = dbManager.getDatabase();
        const product = await db.findById("products", productId);

        if (!product) {
          return ctx.json({ error: "Product not found" }, 404);
        }

        return ctx.json({ reviews: (product as any).reviews || [] });
      } catch (error: any) {
        console.error("Error getting reviews:", error);
        return ctx.json({ error: "Internal server error" }, 500);
      }
    }, c);
  }
}
