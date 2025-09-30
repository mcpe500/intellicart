/**
 * OpenAPI Documentation Module
 * 
 * This module handles the generation and serving of OpenAPI documentation
 * for the Intellicart API. It uses Hono's built-in OpenAPI integration
 * with Zod schemas to automatically generate documentation from route definitions.
 * 
 * The documentation is available in JSON format at the /doc endpoint,
 * which is consumed by Swagger UI for the interactive documentation interface.
 * 
 * @module openapi
 * @description OpenAPI documentation configuration and generation
 * @author Intellicart Team
 * @version 1.0.0
 */

import { OpenAPIHono } from '@hono/zod-openapi';

/**
 * Creates and configures an OpenAPI documentation instance
 * 
 * This function initializes a new OpenAPIHono application that handles:
 * - Generation of OpenAPI specification document
 * - Serving the specification at the /doc endpoint
 * 
 * The OpenAPI specification includes:
 * - API title and version information
 * - API description
 * - OpenAPI version (3.1.0)
 * - Automatically generated paths from Zod schema route definitions
 * 
 * @function createOpenAPIDoc
 * @returns {OpenAPIHono} Configured Hono application for OpenAPI documentation
 * 
 * @example
 * ```typescript
 * import { createOpenAPIDoc } from './documentation/openapi';
 * 
 * const docApp = createOpenAPIDoc();
 * app.get('/doc', docApp.doc);
 * ```
 */
export const createOpenAPIDoc = () => {
  // Create a new OpenAPIHono instance for documentation
  const app = new OpenAPIHono();

  /**
   * Configure the OpenAPI specification document
   * This endpoint serves the OpenAPI JSON document that Swagger UI consumes
   * The specification is automatically populated with paths defined in route handlers
   * 
   * Endpoint: GET /doc
   * Response: OpenAPI 3.1.0 specification in JSON format
   */
  app.doc('/doc', {
    // OpenAPI specification version
    openapi: '3.1.0',
    
    // API information including title, version, and description
    info: {
      // Title of the API displayed in documentation
      title: 'Intellicart API',
      
      // Version of the API
      version: '1.0.0',
      
      // Description of what the API does
      description: 'Auto-generated API documentation with Zod + Hono',
    },
  });

  // Return the configured application instance
  return app;
};