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

import { MiddlewareHandler } from 'hono';
import jwt from 'jsonwebtoken';

// In-memory "database" for storing tokens (in production, use Redis or database)
// This should match the one in AuthController
const activeTokens: Map<string, { userId: number, email: string, exp: number }> = new Map();

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
  const authHeader = c.req.header('Authorization');
  
  // Check if authorization header exists and starts with 'Bearer '
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Access token required' }, 401);
  }
  
  // Extract the token from the header
  const token = authHeader.substring(7); // Remove 'Bearer ' prefix
  
  try {
    // Check if token exists in our active tokens map
    if (!activeTokens.has(token)) {
      return c.json({ error: 'Invalid token' }, 401);
    }
    
    // Verify token hasn't expired
    const tokenData = activeTokens.get(token)!;
    const currentTime = Math.floor(Date.now() / 1000); // Current time in seconds
    
    if (currentTime > tokenData.exp) {
      activeTokens.delete(token); // Remove expired token
      return c.json({ error: 'Token expired' }, 401);
    }
    
    // Verify the JWT signature
    const decoded = jwt.verify(
      token, 
      process.env.JWT_SECRET || 'default_secret'
    ) as { userId: number; email: string };
    
    // Check if the decoded token matches our stored data
    if (decoded.userId !== tokenData.userId || decoded.email !== tokenData.email) {
      return c.json({ error: 'Invalid token' }, 401);
    }
    
    // Add user data to context for use by subsequent handlers
    c.set('user', {
      userId: decoded.userId,
      email: decoded.email
    });
    
    // Continue to the next handler
    await next();
  } catch (error) {
    // JWT verification failed
    return c.json({ error: 'Invalid token' }, 401);
  }
};