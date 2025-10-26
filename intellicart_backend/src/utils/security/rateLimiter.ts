/**
 * Rate Limiting Middleware Module
 * 
 * This middleware provides rate limiting functionality to prevent abuse
 * of API endpoints by limiting the number of requests from a single IP
 * within a specified time window.
 * 
 * @module rateLimiter
 * @description Rate limiting middleware for API protection
 * @author Intellicart Team
 * @version 1.0.0
 */

import { Context, Next } from 'hono';

// Interface for rate limit data
interface RateLimitData {
  count: number;
  resetTime: number;
}

// In-memory store for rate limit data (in production, use Redis or similar)
const rateLimitStore = new Map<string, RateLimitData>();

/**
 * Rate limiting configuration
 */
interface RateLimitOptions {
  windowMs: number;  // Time window in milliseconds
  max: number;       // Maximum number of requests allowed
  message?: string;  // Custom message to send when rate limit exceeded
  keyGenerator?: (c: Context) => string; // Function to generate rate limit key
}

/**
 * Default rate limit options
 */
const defaultOptions: RateLimitOptions = {
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests, please try again later.',
  keyGenerator: (c: Context) => {
    // Use IP address as the key by default
    return c.req.header('x-forwarded-for')?.split(',')[0] || 
           c.req.header('x-real-ip') || 
           c.req.header('x-client-ip') || 
           c.req.raw.headers.get('cf-connecting-ip') || // Cloudflare
           c.req.raw.headers.get('x-cluster-client-ip') || // Load balancer
           'unknown';
  }
};

/**
 * Rate limiting middleware function
 * 
 * @param options - Rate limiting configuration options
 * @returns Hono middleware function
 */
export const rateLimiter = (options: Partial<RateLimitOptions> = {}) => {
  const config = { ...defaultOptions, ...options };
  
  return async (c: Context, next: Next) => {
    const key = config.keyGenerator!(c);
    
    // Get current time
    const now = Date.now();
    
    // Get or create rate limit data for this key
    let limitData = rateLimitStore.get(key);
    
    // Check if window has expired
    if (!limitData || now >= limitData.resetTime) {
      // Reset
      limitData = {
        count: 1,
        resetTime: now + config.windowMs
      };
      rateLimitStore.set(key, limitData);
    } else {
      // Increment count
      limitData.count++;
    }
    
    // Calculate remaining requests and reset time
    const remaining = Math.max(config.max - limitData.count, 0);
    const resetTime = new Date(limitData.resetTime).getTime();
    
    // Set rate limit headers
    c.header('X-RateLimit-Limit', config.max.toString());
    c.header('X-RateLimit-Remaining', remaining.toString());
    c.header('X-RateLimit-Reset', resetTime.toString());
    
    if (limitData.count > config.max) {
      // Too many requests
      c.status(429);
      return c.json({ 
        error: config.message || 'Too many requests, please try again later.' 
      });
    }
    
    // Continue to next middleware
    await next();
  };
};

/**
 * Convenience function for API rate limiting
 * 
 * @param maxRequests - Maximum requests allowed (default: 100 per 15 minutes)
 */
export const apiRateLimiter = (maxRequests: number = 100) => {
  return rateLimiter({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: maxRequests
  });
};

/**
 * Convenience function for authentication rate limiting
 * 
 * @param maxRequests - Maximum requests allowed (default: 5 per 15 minutes)
 */
export const authRateLimiter = (maxRequests: number = 5) => {
  return rateLimiter({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: maxRequests,
    message: 'Too many login attempts, please try again later.'
  });
};