/**
 * Authentication Middleware
 *
 * This middleware provides token verification for protected routes.
 * It checks for a valid JWT token in the Authorization header.
 *
 * @module authMiddleware
 * @description Middleware for authentication
 * @author Intellicart Team
 * @version 1.0.0
 */

import { MiddlewareHandler } from "hono";
import jwt from "jsonwebtoken";
import { dbManager } from "../database/Config";
import { logger } from '../utils/logger';

// Helper function to ensure the tokens table exists
async function ensureTokensTable() {
  const db = dbManager.getDatabase<any>();
  // The database will automatically create the table when we first insert data
  // but we can check if there's any data for validation
}

/**
 * Middleware to verify authentication token
 *
 * @function verifyToken
 * @returns {MiddlewareHandler} Hono middleware function
 *
 * This middleware:
 * 1. Extracts the token from the Authorization header
 * 2. Verifies the token is valid and not expired
 * 3. Sets the user data in the context for use by subsequent handlers
 * 4. Returns 401 if the token is invalid or missing
 */
export const verifyToken: MiddlewareHandler = async (c, next) => {
  // Get authorization header
  const authHeader = c.req.header("Authorization");

  // Check if authorization header exists and starts with 'Bearer '
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    logger.info("[AUTH] No authorization header provided or format incorrect", { ip: c.req.header('x-forwarded-for') || 'unknown', userAgent: c.req.header('user-agent') });
    return c.json({ error: "Access token required" }, 401);
  }

  // Extract the token from the header
  const token = authHeader.substring(7); // Remove 'Bearer ' prefix
  logger.info(`[AUTH] Token verification attempt for token: ${token.substring(0, 10)}...`, { ip: c.req.header('x-forwarded-for') || 'unknown', userAgent: c.req.header('user-agent') });

  try {
    // Check if token exists in our active tokens in the database
    const db = dbManager.getDatabase<any>();
    let activeTokens;
    try {
      activeTokens = await db.findAll("tokens");
    } catch (error) {
      // If the tokens table doesn't exist, create an empty array
      activeTokens = [];
    }

    // Find the token in the stored tokens
    const tokenRecord = activeTokens.find((t) => t.token === token);

    if (!tokenRecord) {
      logger.warn("[AUTH] Token not found in active tokens database", { token: token.substring(0, 10) + '...', ip: c.req.header('x-forwarded-for') || 'unknown', userAgent: c.req.header('user-agent') });
      return c.json({ error: "Invalid token" }, 401);
    }
    
    logger.info(`[AUTH] Token found for user ID: ${tokenRecord.userId}, email: ${tokenRecord.email}`, { userId: tokenRecord.userId, email: tokenRecord.email, ip: c.req.header('x-forwarded-for') || 'unknown' });

    // Verify token hasn't expired
    const currentTime = Math.floor(Date.now() / 1000); // Current time in seconds
    logger.info(`[AUTH] Token expiration check`, { expiration: tokenRecord.exp, currentTime, ip: c.req.header('x-forwarded-for') || 'unknown' });

    if (currentTime > tokenRecord.exp) {
      logger.warn("[AUTH] Token has expired, removing from database", { userId: tokenRecord.userId, email: tokenRecord.email, ip: c.req.header('x-forwarded-for') || 'unknown' });
      // Remove expired token from database
      await db.delete("tokens", tokenRecord.id);
      return c.json({ error: "Token expired" }, 401);
    }

    // Verify the JWT signature
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || "default_secret",
    ) as { userId: number; email: string };

    // Check if the decoded token matches our stored data
    if (
      decoded.userId !== tokenRecord.userId ||
      decoded.email !== tokenRecord.email
    ) {
      logger.warn(`[AUTH] Token payload mismatch`, { 
        expectedUserId: tokenRecord.userId, 
        expectedEmail: tokenRecord.email, 
        actualUserId: decoded.userId, 
        actualEmail: decoded.email,
        ip: c.req.header('x-forwarded-for') || 'unknown',
        userAgent: c.req.header('user-agent')
      });
      return c.json({ error: "Invalid token" }, 401);
    }

    // Verify that the user actually exists in the users table
    const userInDb = await db.findById("users", decoded.userId);
    if (!userInDb) {
      logger.warn(`[AUTH] Token valid but user does not exist in users table`, { userId: decoded.userId, email: decoded.email, ip: c.req.header('x-forwarded-for') || 'unknown' });
      // Remove the token from the tokens table since the user is gone
      await db.delete("tokens", tokenRecord.id);
      return c.json({ error: "Invalid token" }, 401);
    }

    // Add user data to context for use by subsequent handlers
    c.set("user", {
      userId: decoded.userId,
      email: decoded.email,
    });

    // Continue to the next handler
    logger.info(`[AUTH] Token validation successful`, { userId: decoded.userId, email: decoded.email, ip: c.req.header('x-forwarded-for') || 'unknown' });
    await next();
  } catch (error) {
    // JWT verification failed
    logger.error(`[AUTH] JWT verification failed: ${error instanceof Error ? error.message : 'Unknown error'}`, { 
      token: token.substring(0, 10) + '...', 
      error: error instanceof Error ? error.message : 'Unknown error',
      ip: c.req.header('x-forwarded-for') || 'unknown',
      userAgent: c.req.header('user-agent')
    });
    return c.json({ error: "Invalid token" }, 401);
  }
};
