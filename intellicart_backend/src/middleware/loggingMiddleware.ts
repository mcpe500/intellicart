/**
 * Logging Middleware Module
 *
 * This module provides a comprehensive logging middleware for the Intellicart API.
 * It logs all incoming requests with details including method, URL, IP, user agent,
 * request body (for certain endpoints), and response status.
 *
 * @module loggingMiddleware
 * @description Middleware for request/response logging
 * @author Intellicart Team
 * @version 1.0.0
 */

import { Context, Next } from "hono";
import { logger } from "../utils/logger";

/**
 * Logging middleware function that logs all incoming requests
 *
 * @param c - Hono context object
 * @param next - Next middleware function
 */
export async function loggingMiddleware(c: Context, next: Next) {
  const startTime = Date.now();
  const method = c.req.method;
  const url = c.req.url;
  const userAgent = c.req.header("user-agent");

  // Extract IP address from request headers
  const ip =
    c.req.header("x-forwarded-for")?.split(",")[0]?.trim() ||
    c.req.header("x-real-ip") ||
    c.req.header("x-forwarded-host") ||
    c.req.header("x-forwarded-server") ||
    c.req.header("x-forwarded-proto") ||
    c.req.header("x-forwarded-port") ||
    c.req.header("x-forwarded-by") ||
    c.req.raw.headers.get("cf-connecting-ip") || // Cloudflare
    c.req.raw.headers.get("x-cluster-client-ip") || // Load balancer
    c.req.header("x-client-ip") || // Nginx
    c.req.header("x-real-ip") ||
    c.req.header("x-forwarded-for")?.split(",")[0] ||
    "unknown";

  // Log the incoming request
  logger.info("API Request Started", {
    method,
    url,
    ip,
    userAgent: userAgent || "unknown",
    timestamp: new Date().toISOString(),
  });

  // Capture request body for certain endpoints (avoid logging sensitive data like passwords)
  const shouldLogBody =
    method === "POST" &&
    !url.includes("/auth/login") &&
    !url.includes("/auth/register");
  let requestBody = null;

  if (shouldLogBody) {
    try {
      requestBody = await c.req.json();
    } catch (e) {
      // If parsing fails, don't log the body
      requestBody = null;
    }
  }

  if (requestBody) {
    logger.info("Request Body", {
      url,
      body: requestBody,
      timestamp: new Date().toISOString(),
    });
  }

  // Store the request start time on the context for later use
  c.set("requestStartTime", startTime);

  try {
    // Continue with the next middleware/handler
    await next();

    // Calculate response time
    const responseTime = Date.now() - startTime;

    // Log successful response
    logger.info("API Request Completed", {
      method,
      url,
      statusCode: c.res.status,
      responseTime: `${responseTime}ms`,
      ip,
      userAgent: userAgent || "unknown",
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    // Calculate response time even for errors
    const responseTime = Date.now() - startTime;

    // Log error response
    logger.error("API Request Failed", {
      method,
      url,
      statusCode: c.res.status,
      responseTime: `${responseTime}ms`,
      error: error instanceof Error ? error.message : String(error),
      ip,
      userAgent: userAgent || "unknown",
      timestamp: new Date().toISOString(),
    });

    // Re-throw the error to maintain original behavior
    throw error;
  }
}

declare module "hono" {
  interface ContextVariableMap {
    requestStartTime: number;
  }
}
