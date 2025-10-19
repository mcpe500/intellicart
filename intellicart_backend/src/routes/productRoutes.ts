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

// Get all products
const getAllProductsRoute = createRoute({
  method: 'get',
  path: '/products',
  tags: ['Products'],
  responses: {
    200: {
      description: 'Returns all products in the system',
      content: {
        'application/json': {
          schema: ProductSchema.array(),
        },
      },
    },
  },
});

productRoutes.openapi(getAllProductsRoute, ProductController.getAllProducts);

// Get product by ID
const getProductByIdRoute = createRoute({
  method: 'get',
  path: '/products/{id}',
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
  path: '/products',
  tags: ['Products'],
  middleware: [authMiddleware],
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
  path: '/products/{id}',
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
  path: '/products/{id}',
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
  path: '/products/{id}/reviews',
  tags: ['Products'],
  middleware: [authMiddleware],
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
            rating: z.number(),
            comment: z.string().optional(),
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