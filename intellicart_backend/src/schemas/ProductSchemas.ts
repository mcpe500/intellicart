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
  
  originalPrice: z.number().min(0, { message: 'Original price must be a positive number' }).optional().openapi({ 
    example: 129.99,
    description: 'Original/MSRP price (optional)'
  }),
  
  imageUrl: z.string().url({ message: 'Must be a valid URL' }).openapi({ 
    example: 'https://example.com/product-image.jpg',
    description: 'URL to product image'
  }),
  
  sellerId: z.string().openapi({ 
    example: 'user-1234567890',
    description: 'ID of the seller'
  }),
  
  categoryId: z.string().optional().openapi({ 
    example: 'electronics',
    description: 'Category ID (optional)'
  }),
  
  createdAt: z.string().datetime().openapi({ 
    example: new Date().toISOString(),
    description: 'Timestamp when the product was created'
  }),
  
  updatedAt: z.string().datetime().openapi({ 
    example: new Date().toISOString(),
    description: 'Timestamp when the product was last updated'
  }),
  
  reviews: z.array(z.object({
    id: z.string().openapi({ 
      example: 'rev-1234567890',
      description: 'Unique identifier for the review'
    }),
    title: z.string().optional().openapi({ 
      example: 'Excellent Product!',
      description: 'Review title (optional)'
    }),
    reviewText: z.string().optional().openapi({ 
      example: 'Great quality and functionality.',
      description: 'Review text content (optional)'
    }),
    rating: z.number().min(1).max(5).openapi({ 
      example: 5,
      description: 'Rating from 1 to 5'
    }),
    userId: z.string().openapi({ 
      example: 'user-1234567890',
      description: 'ID of the user who wrote the review'
    }),
    userName: z.string().optional().openapi({ 
      example: 'John Doe',
      description: 'Name of the user who wrote the review (optional)'
    }),
    createdAt: z.string().datetime().openapi({ 
      example: new Date().toISOString(),
      description: 'Timestamp when the review was created'
    })
  })).openapi({
    description: 'Array of product reviews'
  }),
  
  averageRating: z.number().min(0).max(5).openapi({ 
    example: 4.5,
    description: 'Average rating based on all reviews'
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
  
  originalPrice: z.number().min(0, { message: 'Original price must be a positive number' }).optional().openapi({ 
    example: 129.99,
    description: 'Original/MSRP price (optional)'
  }),
  
  imageUrl: z.string().url({ message: 'Must be a valid URL' }).openapi({ 
    example: 'https://example.com/product-image.jpg',
    description: 'URL to product image (required, must be valid URL)'
  }),
  
  categoryId: z.string().optional().openapi({ 
    example: 'electronics',
    description: 'Category ID (optional)'
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
  
  originalPrice: z.number().min(0, { message: 'Original price must be a positive number' }).optional().openapi({ 
    example: 129.99,
    description: 'Original/MSRP price (optional)'
  }),
  
  imageUrl: z.string().url({ message: 'Must be a valid URL' }).optional().openapi({ 
    example: 'https://example.com/product-image.jpg',
    description: 'URL to product image (optional, must be valid URL if provided)'
  }),
  
  categoryId: z.string().optional().openapi({ 
    example: 'electronics',
    description: 'Category ID (optional)'
  })
});

export const CreateReviewSchema = z.object({
  rating: z.number().min(1, { message: 'Rating must be at least 1' }).max(5, { message: 'Rating must be at most 5' }).openapi({
    example: 5,
    description: 'Rating from 1 to 5 (required)'
  }),
  
  title: z.string().optional().openapi({
    example: 'Excellent Product!',
    description: 'Review title (optional)'
  }),
  
  reviewText: z.string().max(1000, { message: 'Review text must be 1000 characters or less' }).optional().openapi({
    example: 'Great quality and functionality.',
    description: 'Review text content (optional, max 1000 characters)'
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

export const QueryParamsSchema = z.object({
  page: z.string().regex(/^\d+$/).transform(Number).optional().default('1').openapi({
    example: 1,
    description: 'Page number for pagination (default: 1)'
  }),
  limit: z.string().regex(/^\d+$/).transform(Number).optional().default('10').openapi({
    example: 10,
    description: 'Number of items per page (default: 10, max: 100)'
  }),
  search: z.string().optional().openapi({
    example: 'wireless headphones',
    description: 'Search term to filter products'
  }),
  category: z.string().optional().openapi({
    example: 'electronics',
    description: 'Category to filter products'
  })
});

export const PaginationSchema = z.object({
  page: z.number().openapi({
    example: 1,
    description: 'Current page number'
  }),
  limit: z.number().openapi({
    example: 10,
    description: 'Number of items per page'
  }),
  total: z.number().openapi({
    example: 100,
    description: 'Total number of items'
  }),
  totalPages: z.number().openapi({
    example: 10,
    description: 'Total number of pages'
  })
});

export const ProductListResponseSchema = z.object({
  products: ProductSchema.array(),
  pagination: PaginationSchema
});