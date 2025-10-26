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

import { serve } from "@hono/node-server";
import app, { init } from "./index";

const port = Number(process.env.PORT) || 3000;

init()
  .then(() => {
    console.log("Database initialized successfully");
    console.log(`Intellicart API Server is running on port ${port}`);
    serve({
      fetch: app.fetch,
      port,
    });
  })
  .catch((error) => {
    console.error("Failed to initialize database:", error);
    process.exit(1);
  });
