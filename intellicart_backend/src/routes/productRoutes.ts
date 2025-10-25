/**
 * Product Routes Module
 * 
 * This module defines all product-related API endpoints with proper validation
 * using Zod schemas. Each route is documented with OpenAPI specifications
 * that are automatically generated and displayed in Swagger UI.
 * 
 * The routes follow RESTful conventions and include proper HTTP status codes,
 * request validation, and response schemas.
 * 
 * @module productRoutes
 * @description API routes for product management
 * @author Intellicart Team
 * @version 1.0.0
 */

import { OpenAPIHono, createRoute, z } from '@hono/zod-openapi';
import { verifyToken } from '../middleware/authMiddleware';
import { ProductController } from '../controllers/ProductController';

/**
 * Create a new OpenAPIHono instance for product routes
 * This allows automatic OpenAPI documentation generation from Zod schemas
 */
const productRoutes = new OpenAPIHono();

/**
 * Zod schema defining the structure of a Product object
 * This schema is used for both request and response validation
 */
const ProductSchema = z.object({
  // Unique identifier for the product (auto-generated)
  id: z.number().openapi({ 
    example: 1,
    description: 'Unique identifier for the product (auto-generated)'
  }),
  
  // Product's name (required)
  name: z.string().openapi({ 
    example: 'Wireless Headphones',
    description: 'Product\'s name'
  }),
  
  // Product's description (required) 
  description: z.string().openapi({ 
    example: 'High-quality wireless headphones with noise cancellation',
    description: 'Product\'s description'
  }),
  
  // Product's price (required)
  price: z.string().openapi({ 
    example: '$99.99',
    description: 'Product\'s price'
  }),
  
  // Product's original price (optional, for discount display)
  originalPrice: z.string().optional().openapi({ 
    example: '$129.99',
    description: 'Product\'s original price (optional, for discount display)'
  }),
  
  // Product's image URL (required)
  imageUrl: z.string().url().openapi({ 
    example: 'https://example.com/product-image.jpg',
    description: 'Product\'s image URL'
  }),
  
  // Product's reviews (optional)
  reviews: z.array(z.object({
    id: z.number().openapi({ example: 1 }),
    title: z.string().openapi({ example: 'Great product!' }),
    reviewText: z.string().openapi({ example: 'This product is amazing!' }),
    rating: z.number().min(1).max(5).openapi({ example: 5 }),
    timeAgo: z.string().openapi({ example: '2 days ago' })
  })).optional().openapi({ 
    description: 'Product\'s reviews'
  }),
  
  // Seller ID (required, identifies who added this product)
  sellerId: z.number().openapi({
    example: 1,
    description: 'ID of the seller who added this product'
  }),
  
  // Creation timestamp (auto-generated)
  createdAt: z.string().datetime().optional().openapi({
    example: new Date().toISOString(),
    description: 'Timestamp when the product was created'
  }),
});

/**
 * Zod schema defining the structure for creating a new product
 * Used for validation of POST /api/products request body
 */
const CreateProductSchema = z.object({
  // Product's name (required, minimum length: 1 character)
  name: z.string().min(1, { message: 'Name is required' }).openapi({ 
    example: 'Wireless Headphones',
    description: 'Product\'s name (required, minimum 1 character)'
  }),
  
  // Product's description (required)
  description: z.string().min(1, { message: 'Description is required' }).openapi({ 
    example: 'High-quality wireless headphones with noise cancellation',
    description: 'Product\'s description (required)'
  }),
  
  // Product's price (required)
  price: z.string().min(1, { message: 'Price is required' }).openapi({ 
    example: '$99.99',
    description: 'Product\'s price (required)'
  }),
  
  // Product's original price (optional)
  originalPrice: z.string().optional().openapi({ 
    example: '$129.99',
    description: 'Product\'s original price (optional, for discount display)'
  }),
  
  // Product's image URL (required)
  imageUrl: z.string().url({ message: 'Must be a valid URL' }).openapi({ 
    example: 'https://example.com/product-image.jpg',
    description: 'Product\'s image URL (required, must be valid URL)'
  }),
});

/**
 * Zod schema defining the structure for updating an existing product
 * Used for validation of PUT /api/products/:id request body
 * All fields are optional to allow partial updates
 */
const UpdateProductSchema = z.object({
  // Product's name (optional, minimum length: 1 character if provided)
  name: z.string().min(1, { message: 'Name must be at least 1 character' }).optional().openapi({ 
    example: 'Wireless Headphones',
    description: 'Product\'s name (optional, minimum 1 character if provided)'
  }),
  
  // Product's description (optional)
  description: z.string().optional().openapi({ 
    example: 'High-quality wireless headphones with noise cancellation',
    description: 'Product\'s description (optional)'
  }),
  
  // Product's price (optional)
  price: z.string().optional().openapi({ 
    example: '$99.99',
    description: 'Product\'s price (optional)'
  }),
  
  // Product's original price (optional)
  originalPrice: z.string().optional().openapi({ 
    example: '$129.99',
    description: 'Product\'s original price (optional, for discount display)'
  }),
  
  // Product's image URL (optional, must be valid URL if provided)
  imageUrl: z.string().url({ message: 'Must be a valid URL' }).optional().openapi({ 
    example: 'https://example.com/product-image.jpg',
    description: 'Product\'s image URL (optional, must be valid URL if provided)'
  }),
});

/**
 * Route: GET /api/products
 * Description: Retrieve all products from the database
 * 
 * Request:
 * - Method: GET
 * - Path: / (relative to /api/products)
 * - Parameters: None
 * - Query: None
 * - Body: None
 * 
 * Response:
 * - Status: 200 OK
 * - Content-Type: application/json
 * - Body: Array of Product objects
 */
const getAllProductsRoute = createRoute({
  method: 'get',
  path: '/',  // Changed from '/products' to '/'
  // Documentation for the successful response
  responses: {
    200: {
      description: 'Returns all products in the system',
      content: {
        'application/json': {
          // Response body schema
          schema: z.array(ProductSchema),
        },
      },
    },
  },
});

// Register the route
productRoutes.openapi(getAllProductsRoute, ProductController.getAllProducts);

/**
 * Route: GET /api/products/:id
 * Description: Retrieve a specific product by ID
 * 
 * Request:
 * - Method: GET
 * - Path: /{id}
 * - Parameters: id (number, required)
 * - Query: None
 * - Body: None
 * 
 * Response:
 * - Status: 200 OK (product found)
 * - Content-Type: application/json
 * - Body: Product object
 * 
 * - Status: 404 Not Found (product not found)
 * - Content-Type: application/json
 * - Body: Error object
 */
const getProductByIdRoute = createRoute({
  method: 'get',
  path: '/{id}',
  // Validate request parameters
  request: {
    params: z.object({
      // ID parameter: string that matches numeric pattern, transformed to number
      id: z
        .string()
        .regex(/^\d+$/, { message: 'ID must be a positive number' })
        .transform(Number)
        .openapi({ 
          example: 1,
          description: 'Unique identifier of the product to retrieve'
        }),
    }),
  },
  // Documentation for possible responses
  responses: {
    200: {
      description: 'Returns the requested product by ID',
      content: {
        'application/json': {
          // Response body schema
          schema: ProductSchema,
        },
      },
    },
    404: {
      description: 'Product with the specified ID was not found',
      content: {
        'application/json': {
          // Error response schema
          schema: z.object({
            error: z.string().openapi({ 
              example: 'Product not found',
              description: 'Error message explaining why the request failed'
            }),
          }),
        },
      },
    },
  },
});

// Register the route with authentication middleware
productRoutes.openapi(getProductByIdRoute, verifyToken, ProductController.getProductById);

/**
 * Route: POST /api/products
 * Description: Create a new product
 * 
 * Request:
 * - Method: POST
 * - Path: / (relative to /api/products)
 * - Parameters: None
 * - Query: None
 * - Body: Product creation object (validated against CreateProductSchema)
 * 
 * Response:
 * - Status: 201 Created
 * - Content-Type: application/json
 * - Body: Created Product object with assigned ID
 */
const createProductRoute = createRoute({
  method: 'post',
  path: '/',  // Changed from '/products' to '/'
  // Validate request body
  request: {
    body: {
      content: {
        'application/json': {
          // Request body schema
          schema: CreateProductSchema,
        },
      },
    },
  },
  // Documentation for the successful response
  responses: {
    201: {
      description: 'Product created successfully',
      content: {
        'application/json': {
          // Response body schema
          schema: ProductSchema,
        },
      },
    },
  },
});

// Register the route with authentication middleware
productRoutes.openapi(createProductRoute, verifyToken, ProductController.createProduct);

/**
 * Route: PUT /api/products/:id
 * Description: Update an existing product by ID
 * 
 * Request:
 * - Method: PUT
 * - Path: /{id}
 * - Parameters: id (number, required)
 * - Query: None
 * - Body: Product update object (validated against UpdateProductSchema)
 * 
 * Response:
 * - Status: 200 OK (product updated successfully)
 * - Content-Type: application/json
 * - Body: Updated Product object
 * 
 * - Status: 404 Not Found (product not found)
 * - Content-Type: application/json
 * - Body: Error object
 */
const updateProductRoute = createRoute({
  method: 'put',
  path: '/{id}',  // Changed from '/products/{id}' to '/{id}'
  // Validate request parameters and body
  request: {
    params: z.object({
      // ID parameter: string that matches numeric pattern, transformed to number
      id: z
        .string()
        .regex(/^\d+$/, { message: 'ID must be a positive number' })
        .transform(Number)
        .openapi({ 
          example: 1,
          description: 'Unique identifier of the product to update'
        }),
    }),
    body: {
      content: {
        'application/json': {
          // Request body schema
          schema: UpdateProductSchema,
        },
      },
    },
  },
  // Documentation for possible responses
  responses: {
    200: {
      description: 'Product updated successfully',
      content: {
        'application/json': {
          // Response body schema
          schema: ProductSchema,
        },
      },
    },
    404: {
      description: 'Product with the specified ID was not found',
      content: {
        'application/json': {
          // Error response schema
          schema: z.object({
            error: z.string().openapi({ 
              example: 'Product not found',
              description: 'Error message explaining why the request failed'
            }),
          }),
        },
      },
    },
  },
});

// Register the route with authentication middleware
productRoutes.openapi(updateProductRoute, verifyToken, ProductController.updateProduct);

/**
 * Route: DELETE /api/products/:id
 * Description: Delete an existing product by ID
 * 
 * Request:
 * - Method: DELETE
 * - Path: /{id}
 * - Parameters: id (number, required)
 * - Query: None
 * - Body: None
 * 
 * Response:
 * - Status: 200 OK (product deleted successfully)
 * - Content-Type: application/json
 * - Body: Success message and deleted product object
 * 
 * - Status: 404 Not Found (product not found)
 * - Content-Type: application/json
 * - Body: Error object
 */
const deleteProductRoute = createRoute({
  method: 'delete',
  path: '/{id}',  // Changed from '/products/{id}' to '/{id}'
  // Validate request parameters
  request: {
    params: z.object({
      // ID parameter: string that matches numeric pattern, transformed to number
      id: z
        .string()
        .regex(/^\d+$/, { message: 'ID must be a positive number' })
        .transform(Number)
        .openapi({ 
          example: 1,
          description: 'Unique identifier of the product to delete'
        }),
    }),
  },
  // Documentation for possible responses
  responses: {
    200: {
      description: 'Product deleted successfully',
      content: {
        'application/json': {
          // Response body schema
          schema: z.object({
            message: z.string().openapi({ 
              example: 'Product deleted successfully',
              description: 'Confirmation message'
            }),
            product: ProductSchema, // Return the deleted product object
          }),
        },
      },
    },
    404: {
      description: 'Product with the specified ID was not found',
      content: {
        'application/json': {
          // Error response schema
          schema: z.object({
            error: z.string().openapi({ 
              example: 'Product not found',
              description: 'Error message explaining why the request failed'
            }),
          }),
        },
      },
    },
  },
});

// Register the route with authentication middleware
productRoutes.openapi(deleteProductRoute, verifyToken, ProductController.deleteProduct);

/**
 * Route: GET /api/products/seller/:sellerId
 * Description: Retrieve all products by a specific seller
 * 
 * Request:
 * - Method: GET
 * - Path: /seller/{sellerId}
 * - Parameters: sellerId (number, required)
 * - Query: None
 * - Body: None
 * 
 * Response:
 * - Status: 200 OK
 * - Content-Type: application/json
 * - Body: Array of Product objects
 */
const getSellerProductsRoute = createRoute({
  method: 'get',
  path: '/seller/{sellerId}',  // Changed from '/products/seller/{sellerId}' to '/seller/{sellerId}'
  // Validate request parameters
  request: {
    params: z.object({
      // Seller ID parameter: string that matches numeric pattern, transformed to number
      sellerId: z
        .string()
        .regex(/^\d+$/, { message: 'Seller ID must be a positive number' })
        .transform(Number)
        .openapi({ 
          example: 1,
          description: 'Unique identifier of the seller'
        }),
    }),
  },
  // Documentation for the successful response
  responses: {
    200: {
      description: 'Returns all products created by the specified seller',
      content: {
        'application/json': {
          // Response body schema
          schema: z.array(ProductSchema),
        },
      },
    },
  },
});

// Register the route with authentication middleware
productRoutes.openapi(getSellerProductsRoute, verifyToken, ProductController.getSellerProducts);

// Export the configured routes for use in the main application
export { productRoutes };