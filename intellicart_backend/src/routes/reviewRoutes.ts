import { OpenAPIHono } from '@hono/zod-openapi';
import { z } from 'zod';
import { ReviewSchema, CreateReviewSchema } from '../schemas/ReviewSchemas';
import * as ReviewController from '../controllers/ReviewController';

// Create Hono app with OpenAPI integration for review routes
const reviewRoutes = new OpenAPIHono();

// Define the input and output schemas for OpenAPI documentation
const ReviewResponseSchema = z.object({
  success: z.boolean(),
  message: z.string().optional(),
  data: z.union([ReviewSchema, z.array(ReviewSchema)]).optional(),
  count: z.number().optional(),
  errors: z.array(z.any()).optional(),
});

// POST /api/reviews - Create a new review
reviewRoutes.openapi(
  {
    method: 'post',
    path: '/',
    description: 'Create a new review for a product',
    request: {
      body: {
        content: {
          'application/json': {
            schema: z.object({
              productId: z.string().min(1, 'Product ID is required'),
              rating: z.number().int().min(1).max(5, 'Rating must be an integer between 1 and 5'),
              comment: z.string().optional(),
              userId: z.string().optional(), // Optional, could be extracted from auth
            }),
          },
        },
      },
    },
    responses: {
      201: {
        description: 'Review created successfully',
        content: {
          'application/json': {
            schema: ReviewResponseSchema,
          },
        },
      },
      400: {
        description: 'Validation error',
        content: {
          'application/json': {
            schema: ReviewResponseSchema,
          },
        },
      },
    },
  },
  ReviewController.createReview
);

// GET /api/reviews/product/:productId - Get all reviews for a specific product
reviewRoutes.openapi(
  {
    method: 'get',
    path: '/product/{productId}',
    description: 'Get all reviews for a specific product',
    request: {
      params: z.object({
        productId: z.string().min(1, 'Product ID is required'),
      }),
    },
    responses: {
      200: {
        description: 'Reviews retrieved successfully',
        content: {
          'application/json': {
            schema: ReviewResponseSchema,
          },
        },
      },
      404: {
        description: 'Product not found or no reviews found',
        content: {
          'application/json': {
            schema: ReviewResponseSchema,
          },
        },
      },
    },
  },
  ReviewController.getReviewsByProduct
);

// GET /api/reviews/:id - Get a specific review by ID (requires productId as well)
reviewRoutes.openapi(
  {
    method: 'get',
    path: '/{id}',
    description: 'Get a specific review by ID (note: productId is needed as path param in actual implementation)',
    request: {
      params: z.object({
        id: z.string().min(1, 'Review ID is required'),
        productId: z.string().min(1, 'Product ID is required'),
      }),
    },
    responses: {
      200: {
        description: 'Review retrieved successfully',
        content: {
          'application/json': {
            schema: ReviewResponseSchema,
          },
        },
      },
      404: {
        description: 'Review not found',
        content: {
          'application/json': {
            schema: ReviewResponseSchema,
          },
        },
      },
    },
  },
  ReviewController.getReviewById
);

// GET /api/reviews/user/:userId - Get all reviews by a specific user
reviewRoutes.openapi(
  {
    method: 'get',
    path: '/user/{userId}',
    description: 'Get all reviews by a specific user',
    request: {
      params: z.object({
        userId: z.string().min(1, 'User ID is required'),
      }),
    },
    responses: {
      200: {
        description: 'User reviews retrieved successfully',
        content: {
          'application/json': {
            schema: ReviewResponseSchema,
          },
        },
      },
      404: {
        description: 'User not found or no reviews found',
        content: {
          'application/json': {
            schema: ReviewResponseSchema,
          },
        },
      },
    },
  },
  ReviewController.getReviewsByUser
);

export { reviewRoutes };