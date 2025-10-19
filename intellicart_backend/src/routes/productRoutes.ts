import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import { ProductController } from '../controllers/ProductController';
import { 
  ProductSchema, 
  CreateProductSchema, 
  UpdateProductSchema, 
  CreateReviewSchema, 
  ProductIdParamSchema, 
  ErrorSchema 
} from '../schemas/ProductSchemas';
import { authMiddleware } from '../middleware/auth';
import { z } from 'zod';

const productRoutes = new OpenAPIHono();

// Get all products with pagination
const getAllProductsRoute = createRoute({
  method: 'get',
  path: '/',
  tags: ['Products'],
  request: {
    query: z.object({
      page: z.string().regex(/^\d+$/).transform(Number).optional().default('1'),
      limit: z.string().regex(/^\d+$/).transform(Number).optional().default('10'),
      search: z.string().optional(),
      category: z.string().optional(),
    })
  },
  responses: {
    200: {
      description: 'Returns all products in the system with pagination',
      content: {
        'application/json': {
          schema: z.object({
            products: ProductSchema.array(),
            pagination: z.object({
              page: z.number(),
              limit: z.number(),
              total: z.number(),
              totalPages: z.number()
            })
          }),
        },
      },
    },
    500: {
      description: 'Internal server error',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

productRoutes.openapi(getAllProductsRoute, ProductController.getAllProducts);

// Get seller products with pagination
const getSellerProductsRoute = createRoute({
  method: 'get',
  path: '/seller/{sellerId}',
  tags: ['Products'],
  request: {
    params: z.object({
      sellerId: z.string().openapi({
        example: 'user-1234567890',
        description: 'Unique identifier of the seller'
      })
    }),
    query: z.object({
      page: z.string().regex(/^\d+$/).transform(Number).optional().default('1'),
      limit: z.string().regex(/^\d+$/).transform(Number).optional().default('10'),
    })
  },
  responses: {
    200: {
      description: 'Returns products for a specific seller with pagination',
      content: {
        'application/json': {
          schema: z.object({
            products: ProductSchema.array(),
            pagination: z.object({
              page: z.number(),
              limit: z.number(),
              total: z.number(),
              totalPages: z.number()
            })
          }),
        },
      },
    },
    404: {
      description: 'Seller not found or has no products',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

productRoutes.openapi(getSellerProductsRoute, ProductController.getSellerProducts);

// Get product by ID
const getProductByIdRoute = createRoute({
  method: 'get',
  path: '/{id}',
  tags: ['Products'],
  request: {
    params: ProductIdParamSchema,
  },
  responses: {
    200: {
      description: 'Returns the requested product by ID',
      content: {
        'application/json': {
          schema: ProductSchema,
        },
      },
    },
    404: {
      description: 'Product with the specified ID was not found',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

productRoutes.openapi(getProductByIdRoute, ProductController.getProductById);

// Create product (requires authentication)
const createProductRoute = createRoute({
  method: 'post',
  path: '/',
  tags: ['Products'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    body: {
      content: {
        'application/json': {
          schema: CreateProductSchema,
        },
      },
    },
  },
  responses: {
    201: {
      description: 'Product created successfully',
      content: {
        'application/json': {
          schema: ProductSchema,
        },
      },
    },
    400: {
      description: 'Invalid input',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    401: {
      description: 'Unauthorized: Invalid or missing token',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

productRoutes.openapi(createProductRoute, ProductController.createProduct);

// Update product
const updateProductRoute = createRoute({
  method: 'put',
  path: '/{id}',
  tags: ['Products'],
  request: {
    params: ProductIdParamSchema,
    body: {
      content: {
        'application/json': {
          schema: UpdateProductSchema,
        },
      },
    },
  },
  responses: {
    200: {
      description: 'Product updated successfully',
      content: {
        'application/json': {
          schema: ProductSchema,
        },
      },
    },
    404: {
      description: 'Product with the specified ID was not found',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

productRoutes.openapi(updateProductRoute, ProductController.updateProduct);

// Delete product
const deleteProductRoute = createRoute({
  method: 'delete',
  path: '/{id}',
  tags: ['Products'],
  request: {
    params: ProductIdParamSchema,
  },
  responses: {
    200: {
      description: 'Product deleted successfully',
      content: {
        'application/json': {
          schema: z.object({
            message: z.string(),
          }),
        },
      },
    },
    404: {
      description: 'Product with the specified ID was not found',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

productRoutes.openapi(deleteProductRoute, ProductController.deleteProduct);

// Add review to product
const addReviewRoute = createRoute({
  method: 'post',
  path: '/{id}/reviews',
  tags: ['Products'],
  middleware: [authMiddleware],
  security: [{ BearerAuth: [] }],
  request: {
    params: ProductIdParamSchema,
    body: {
      content: {
        'application/json': {
          schema: CreateReviewSchema,
        },
      },
    },
  },
  responses: {
    201: {
      description: 'Review added successfully',
      content: {
        'application/json': {
          schema: z.object({
            id: z.string(),
            userId: z.string(),
            title: z.string().optional(),
            reviewText: z.string().optional(),
            rating: z.number(),
            userName: z.string().optional(),
            createdAt: z.string(),
          }),
        },
      },
    },
    400: {
      description: 'Invalid input',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    401: {
      description: 'Unauthorized: Invalid or missing token',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
    404: {
      description: 'Product with the specified ID was not found',
      content: {
        'application/json': {
          schema: ErrorSchema,
        },
      },
    },
  },
});

productRoutes.openapi(addReviewRoute, ProductController.addReview);

export { productRoutes };