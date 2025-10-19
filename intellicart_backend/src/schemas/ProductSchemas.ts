import { z } from 'zod';

export const ProductSchema = z.object({
  id: z.string().openapi({ 
    example: 'prod-1234567890',
    description: 'Unique identifier for the product'
  }),
  
  name: z.string().min(1, { message: 'Name is required' }).openapi({ 
    example: 'Wireless Headphones',
    description: 'Product name'
  }),
  
  description: z.string().openapi({ 
    example: 'High-quality wireless headphones with noise cancellation',
    description: 'Product description'
  }),
  
  price: z.number().min(0, { message: 'Price must be a positive number' }).openapi({ 
    example: 99.99,
    description: 'Product price'
  }),
  
  imageUrl: z.string().url({ message: 'Must be a valid URL' }).openapi({ 
    example: 'https://example.com/product-image.jpg',
    description: 'URL to product image'
  }),
  
  sellerId: z.string().openapi({ 
    example: 'user-1234567890',
    description: 'ID of the seller'
  }),
  
  reviews: z.array(z.object({
    id: z.string().openapi({ 
      example: 'rev-1234567890',
      description: 'Unique identifier for the review'
    }),
    userId: z.string().openapi({ 
      example: 'user-1234567890',
      description: 'ID of the user who wrote the review'
    }),
    rating: z.number().min(1).max(5).openapi({ 
      example: 5,
      description: 'Rating from 1 to 5'
    }),
    comment: z.string().optional().openapi({ 
      example: 'Great product!',
      description: 'Review comment (optional)'
    }),
    createdAt: z.string().datetime().openapi({ 
      example: new Date().toISOString(),
      description: 'Timestamp when the review was created'
    })
  })).openapi({
    description: 'Array of product reviews'
  })
});

export const CreateProductSchema = z.object({
  name: z.string().min(1, { message: 'Name is required' }).openapi({ 
    example: 'Wireless Headphones',
    description: 'Product name (required, minimum 1 character)'
  }),
  
  description: z.string().openapi({ 
    example: 'High-quality wireless headphones with noise cancellation',
    description: 'Product description (optional)'
  }),
  
  price: z.number().min(0, { message: 'Price must be a positive number' }).openapi({ 
    example: 99.99,
    description: 'Product price (required, minimum 0)'
  }),
  
  imageUrl: z.string().url({ message: 'Must be a valid URL' }).openapi({ 
    example: 'https://example.com/product-image.jpg',
    description: 'URL to product image (required, must be valid URL)'
  })
});

export const UpdateProductSchema = z.object({
  name: z.string().min(1, { message: 'Name must be at least 1 character' }).optional().openapi({ 
    example: 'Wireless Headphones',
    description: 'Product name (optional, minimum 1 character if provided)'
  }),
  
  description: z.string().optional().openapi({ 
    example: 'High-quality wireless headphones with noise cancellation',
    description: 'Product description (optional)'
  }),
  
  price: z.number().min(0, { message: 'Price must be 0 or greater' }).optional().openapi({ 
    example: 99.99,
    description: 'Product price (optional, minimum 0 if provided)'
  }),
  
  imageUrl: z.string().url({ message: 'Must be a valid URL' }).optional().openapi({ 
    example: 'https://example.com/product-image.jpg',
    description: 'URL to product image (optional, must be valid URL if provided)'
  })
});

export const CreateReviewSchema = z.object({
  rating: z.number().min(1, { message: 'Rating must be at least 1' }).max(5, { message: 'Rating must be at most 5' }).openapi({
    example: 5,
    description: 'Rating from 1 to 5 (required)'
  }),
  
  comment: z.string().max(500, { message: 'Comment must be 500 characters or less' }).optional().openapi({
    example: 'Great product!',
    description: 'Review comment (optional, max 500 characters)'
  })
});

export const ProductIdParamSchema = z.object({
  id: z.string().openapi({ 
    example: 'prod-1234567890',
    description: 'Unique identifier of the product'
  })
});

export const ErrorSchema = z.object({
  error: z.string().openapi({
    example: 'Product not found',
    description: 'Error message explaining why the request failed'
  })
});