/**
 * Intellicart API Server Entry Point
 * 
 * This file serves as the main entry point for running the Intellicart API server.
 * It uses the @hono/node-server package to create an HTTP server that serves
 * the Hono application defined in the main index.ts file.
 * 
 * The server configuration includes:
 * - Port configuration from environment variables or default (3000)
 * - Integration with the main Hono application
 * - Proper error handling and logging
 * 
 * @file Server entry point
 * @author Intellicart Team
 * @version 1.0.0
 */

// Import the serve function from @hono/node-server package
// This function creates an HTTP server that serves the Hono application
import { serve } from '@hono/node-server';

// Import the main Hono application instance from the index file
// This contains all routes, middleware, and configuration
import app from './index';

// Import the database manager
import { dbManager } from './database/Config';

/**
 * Determine the port number for the server
 * Uses the PORT environment variable if available, otherwise defaults to 3000
 * The port is converted to a number for the server configuration
 */
const port = Number(process.env.PORT) || 3000;

// Initialize the database when the server starts
dbManager.initialize()
  .then(() => {
    console.log('Database initialized successfully');
    
    // Log a startup message to indicate the server is running
    console.log(`Intellicart API Server is running on port ${port}`);
    
    // Start the HTTP server with the configured port and Hono application
    serve({
      // Use the Hono application's fetch handler
      fetch: app.fetch,
      
      // Use the configured port number
      port,
    });
  })
  .catch(error => {
    console.error('Failed to initialize database:', error);
    process.exit(1); // Exit the process if database initialization fails
  });