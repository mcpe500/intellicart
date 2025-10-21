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
 * @version 3.0.0
 */

import { OpenAPIHono } from '@hono/zod-openapi';
import { swaggerUI } from '@hono/swagger-ui';
import { readFile } from 'fs/promises';
import { join } from 'path';
import { stringify } from 'yaml';
import { userRoutes } from './routes/userRoutes';
import { authRoutes } from './routes/authRoutes';
import { productRoutes } from './routes/productRoutes';
import { orderRoutes } from './routes/orderRoutes';
import { reviewRoutes } from './routes/reviewRoutes';
import { addressRoutes } from './routes/addressRoutes';
import { paymentMethodRoutes } from './routes/paymentMethodRoutes';
import { deliveryRoutes } from './routes/deliveryRoutes';
import { initializeDb } from './database/db_service';
import { requestLogger } from './utils/logger';
import { cors } from './middleware/cors';

// Import type extensions
import './types/HonoContextTypes';

// Initialize the database service based on environment configuration
initializeDb();

/**
 * Create the main application instance using OpenAPIHono
 * This allows automatic OpenAPI documentation generation from Zod schemas
 */
const app = new OpenAPIHono();

// Add CORS and request logging middleware
app.use('*', cors);
app.use('*', requestLogger);

/**
 * Register all API routes under specific prefixes for proper grouping
 * This creates grouped endpoints for better organization:
 * - Authentication: /api/auth/*
 * - Users: /api/users/*
 * - Products: /api/products/*
 * - Orders: /api/orders/*
 */
app.route('/api/auth', authRoutes);
app.route('/api/users', userRoutes);
app.route('/api/products', productRoutes);
app.route('/api/orders', orderRoutes);
app.route('/api/reviews', reviewRoutes);
app.route('/api/addresses', addressRoutes);
app.route('/api/payment-methods', paymentMethodRoutes);
app.route('/api/deliveries', deliveryRoutes);

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
 * Generate OpenAPI documentation specification with tags for grouping
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
  tags: [
    {
      name: 'Authentication',
      description: 'Authentication related endpoints for user login and registration'
    },
    {
      name: 'Users',
      description: 'Operations related to user management'
    },
    {
      name: 'Products',
      description: 'Operations related to product management'
    },
    {
      name: 'Orders',
      description: 'Operations related to order management'
    },
    {
      name: 'Reviews',
      description: 'Operations related to product reviews'
    },
    {
      name: 'Addresses',
      description: 'Operations related to user addresses'
    },
    {
      name: 'Payment Methods',
      description: 'Operations related to user payment methods'
    },
    {
      name: 'Deliveries',
      description: 'Operations related to order deliveries and tracking'
    }
  ]
});

/**
 * Serve Swagger UI for interactive API documentation
 * This endpoint provides a web interface to explore and test API endpoints
 * The UI is populated with automatically generated documentation from Zod schemas
 */
app.get('/ui', swaggerUI({ url: '/doc' }));

/**
 * Serve the OpenAPI specification as YAML
 * This endpoint provides the API specification in YAML format
 */
app.get('/swagger.yaml', async (c) => {
  try {
    // Try to read the static swagger.yaml file if it exists
    const yamlPath = join(process.cwd(), 'swagger.yaml');
    const yamlContent = await readFile(yamlPath, 'utf-8');
    
    c.header('Content-Type', 'application/yaml');
    return c.body(yamlContent);
  } catch (error) {
    // If static file doesn't exist, generate spec dynamically and return as YAML
    const openApiDoc = app.getOpenAPIDocument();
    
    // Create a clean copy without functions for YAML serialization
    const cleanOpenApiDoc = JSON.parse(JSON.stringify(openApiDoc, (key, value) => {
      // Skip functions and undefined values
      if (typeof value === 'function' || value === undefined) {
        return undefined;
      }
      return value;
    }));
    
    // Create the complete OpenAPI specification with metadata
    const completeOpenApiSpec = {
      openapi: '3.1.0',
      info: {
        title: 'Intellicart API',
        version: '1.0.0',
        description: 'Auto-generated API documentation with Zod + Hono',
      },
      tags: [
        {
          name: 'Authentication',
          description: 'Authentication related endpoints for user login and registration'
        },
        {
          name: 'Users',
          description: 'Operations related to user management'
        },
        {
          name: 'Products',
          description: 'Operations related to product management'
        },
        {
          name: 'Orders',
          description: 'Operations related to order management'
        },
        {
          name: 'Reviews',
          description: 'Operations related to product reviews'
        },
        {
          name: 'Addresses',
          description: 'Operations related to user addresses'
        },
        {
          name: 'Payment Methods',
          description: 'Operations related to user payment methods'
        },
        {
          name: 'Deliveries',
          description: 'Operations related to order deliveries and tracking'
        }
      ],
      ...cleanOpenApiDoc, // This adds paths, components, etc.
    };
    
    // Convert to proper YAML format
    const yamlString = stringify(completeOpenApiSpec, { indent: 2 });

    c.header('Content-Type', 'application/yaml');
    return c.body(yamlString);
  }
});

export default app;