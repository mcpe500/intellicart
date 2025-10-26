/**
 * Intellicart API Main Application File
 * 
 * This file initializes the Hono application with OpenAPI integration,
 * registers all routes, and configures Swagger UI documentation.
 * 
 * The application follows a modular architecture with:
 * - Controllers handling business logic
 * - Routes defining API endpoints with validation
 * - Documentation automatically generated from Zod schemas
 * 
 * @file Main application entry point
 * @author Intellicart Team
 * @version 1.0.0
 */

import { OpenAPIHono } from '@hono/zod-openapi';
import { swaggerUI } from '@hono/swagger-ui';
import { userRoutes } from './routes/userRoutes';
import { authRoutes } from './routes/authRoutes';
import { productRoutes } from './routes/productRoutes';
import { orderRoutes } from './routes/orderRoutes';
import { loggingMiddleware } from './middleware/loggingMiddleware';

/**
 * Create the main application instance using OpenAPIHono
 * This allows automatic OpenAPI documentation generation from Zod schemas
 */
const app = new OpenAPIHono();

// Add logging middleware to log all requests
app.use('*', loggingMiddleware);

/**
 * Register all authentication-related routes under the '/api/auth' prefix
 * This creates endpoints such as:
 * - POST /api/auth/register
 * - POST /api/auth/login
 * - GET /api/auth/me
 * - POST /api/auth/logout
 * - POST /api/auth/verify
 */
app.route('/api/auth', authRoutes);

/**
 * Register all product-related routes under the '/api/products' prefix
 * This creates endpoints such as:
 * - GET /api/products
 * - POST /api/products
 * - GET /api/products/:id
 * - PUT /api/products/:id
 * - DELETE /api/products/:id
 * - GET /api/products/seller/:sellerId
 */
app.route('/api/products', productRoutes);

/**
 * Register all order-related routes under the '/api/orders' prefix
 * This creates endpoints such as:
 * - GET /api/orders
 * - PUT /api/orders/:id/status
 */
app.route('/api/orders', orderRoutes);

/**
 * Register all user-related routes under the '/api/users' prefix
 * This creates endpoints such as:
 * - GET /api/users
 * - POST /api/users
 * - GET /api/users/:id
 * - PUT /api/users/:id
 * - DELETE /api/users/:id
 */
app.route('/api/users', userRoutes);

/**
 * Root endpoint for API health check and information
 * Returns a welcome message with instructions for accessing documentation
 */
app.get('/', (c) => {
  return c.json({ 
    message: 'Welcome to Intellicart API! Visit /ui for Swagger documentation.' 
  });
});

/**
 * Health check endpoint for monitoring service availability
 * Returns the current status and timestamp
 * 
 * @route GET /health
 * @returns {Object} Health status object with timestamp
 */
app.get('/health', (c) => {
  return c.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString() 
  });
});

/**
 * Generate OpenAPI documentation specification
 * This endpoint serves the OpenAPI JSON document that Swagger UI consumes
 * The specification is automatically generated from Zod schemas in route definitions
 */
app.doc('/doc', {
  openapi: '3.1.0',
  info: {
    title: 'Intellicart API',
    version: '1.0.0',
    description: 'Auto-generated API documentation with Zod + Hono',
  },
});

/**
 * Serve Swagger UI for interactive API documentation
 * This endpoint provides a web interface to explore and test API endpoints
 * The UI is populated with automatically generated documentation from Zod schemas
 */
app.get('/ui', swaggerUI({ url: '/doc' }));

export default app;
