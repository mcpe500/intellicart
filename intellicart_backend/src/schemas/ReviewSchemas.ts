import { z } from 'zod';

export const ReviewSchema = z.object({
  id: z.string().optional(),
  productId: z.string().min(1, 'Product ID is required'),
  userId: z.string().min(1, 'User ID is required'),
  rating: z.number().min(1).max(5, 'Rating must be between 1 and 5'),
  comment: z.string().optional(),
  createdAt: z.string().optional(),
  updatedAt: z.string().optional(),
});

export const CreateReviewSchema = ReviewSchema.omit({ id: true, createdAt: true, updatedAt: true }).extend({
  rating: z.number().int().min(1).max(5, 'Rating must be an integer between 1 and 5'),
});

export const UpdateReviewSchema = ReviewSchema.partial().omit({ id: true, productId: true, userId: true });

export type Review = z.infer<typeof ReviewSchema>;
export type CreateReview = z.infer<typeof CreateReviewSchema>;
export type UpdateReview = z.infer<typeof UpdateReviewSchema>;