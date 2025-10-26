/**
 * Authorization Middleware Module
 *
 * This module provides role-based access control for protected routes.
 * It checks user roles to ensure they have permission for specific operations.
 *
 * @module authzMiddleware
 * @description Middleware for authorization and role-based access control
 * @author Intellicart Team
 * @version 1.0.0
 */

import { MiddlewareHandler } from "hono";
import { dbManager } from "../database/Config";
import { logger } from '../utils/logger';

/**
 * Middleware to check if the user has a specific role
 *
 * @param roles - Array of roles that are allowed to access the route
 * @returns {MiddlewareHandler} Hono middleware function
 *
 * This middleware:
 * 1. Gets the user from the context (set by authentication middleware)
 * 2. Checks if the user's role is in the allowed roles list
 * 3. Continues to the next handler if authorized
 * 4. Returns 403 if the user doesn't have the required role(s)
 */
export const requireRole = (roles: string[]): MiddlewareHandler => {
  return async (c, next) => {
    const user = c.get("user");
    
    if (!user) {
      logger.warn("[AUTHZ] Authorization failed - no user in context", { 
        ip: c.req.header('x-forwarded-for') || 'unknown',
        userAgent: c.req.header('user-agent'),
        requiredRoles: roles
      });
      return c.json({ error: "Authentication required" }, 401);
    }

    try {
      const db = dbManager.getDatabase<any>();
      const fullUser = await db.findById("users", user.userId);
      
      if (!fullUser) {
        logger.warn("[AUTHZ] Authorization failed - user not found in database", { 
          userId: user.userId,
          ip: c.req.header('x-forwarded-for') || 'unknown',
          userAgent: c.req.header('user-agent'),
          requiredRoles: roles
        });
        return c.json({ error: "User not found" }, 401);
      }

      // Check if user's role is in the allowed roles
      if (!roles.includes(fullUser.role)) {
        logger.warn("[AUTHZ] Authorization failed - insufficient role", { 
          userId: user.userId,
          userEmail: user.email,
          userRole: fullUser.role,
          requiredRoles: roles,
          ip: c.req.header('x-forwarded-for') || 'unknown',
          userAgent: c.req.header('user-agent')
        });
        return c.json({ error: "Insufficient permissions" }, 403);
      }

      logger.info("[AUTHZ] Authorization successful", { 
        userId: user.userId,
        userRole: fullUser.role,
        requiredRoles: roles,
        ip: c.req.header('x-forwarded-for') || 'unknown',
        userAgent: c.req.header('user-agent')
      });
      
      // Continue to the next handler
      await next();
    } catch (error) {
      logger.error("[AUTHZ] Error during authorization check", { 
        error: error instanceof Error ? error.message : 'Unknown error',
        userId: user.userId,
        ip: c.req.header('x-forwarded-for') || 'unknown',
        userAgent: c.req.header('user-agent'),
        requiredRoles: roles
      });
      return c.json({ error: "Authorization check failed" }, 500);
    }
  };
};

/**
 * Middleware to check if the user is the owner of a resource
 * Commonly used for protecting user-specific resources
 *
 * @param resourceParamName - The name of the parameter that contains the resource owner ID (default: 'id')
 * @returns {MiddlewareHandler} Hono middleware function
 *
 * This middleware:
 * 1. Gets the user from the context (set by authentication middleware)
 * 2. Compares the user ID with the resource owner ID from params
 * 3. Continues to the next handler if the user is the owner
 * 4. Returns 403 if the user doesn't own the resource
 */
export const requireOwnership = (resourceParamName: string = 'id'): MiddlewareHandler => {
  return async (c, next) => {
    const user = c.get("user");
    
    if (!user) {
      logger.warn(`[AUTHZ] Ownership check failed - no user in context`, { 
        ip: c.req.header('x-forwarded-for') || 'unknown',
        userAgent: c.req.header('user-agent'),
        resourceParam: resourceParamName
      });
      return c.json({ error: "Authentication required" }, 401);
    }

    // Get the resource owner ID from the request parameters
    const resourceOwnerId = Number(c.req.param(resourceParamName));
    
    if (isNaN(resourceOwnerId)) {
      logger.warn(`[AUTHZ] Ownership check failed - invalid resource ID`, { 
        ip: c.req.header('x-forwarded-for') || 'unknown',
        userAgent: c.req.header('user-agent'),
        resourceParam: resourceParamName,
        resourceValue: c.req.param(resourceParamName)
      });
      return c.json({ error: "Invalid resource ID" }, 400);
    }

    // Check if the user is the owner of the resource
    if (user.userId !== resourceOwnerId) {
      logger.warn(`[AUTHZ] Ownership check failed - user does not own resource`, { 
        userId: user.userId,
        userEmail: user.email,
        resourceOwnerId,
        resourceParam: resourceParamName,
        ip: c.req.header('x-forwarded-for') || 'unknown',
        userAgent: c.req.header('user-agent')
      });
      return c.json({ error: "Access denied - you don't own this resource" }, 403);
    }

    logger.info(`[AUTHZ] Ownership check passed`, { 
      userId: user.userId,
      resourceOwnerId,
      resourceParam: resourceParamName,
      ip: c.req.header('x-forwarded-for') || 'unknown',
      userAgent: c.req.header('user-agent')
    });
    
    // Continue to the next handler
    await next();
  };
};

/**
 * Middleware to allow only admin users
 *
 * @returns {MiddlewareHandler} Hono middleware function
 */
export const requireAdmin: MiddlewareHandler = requireRole(['admin']);

/**
 * Middleware to allow only seller users
 *
 * @returns {MiddlewareHandler} Hono middleware function
 */
export const requireSeller: MiddlewareHandler = requireRole(['seller']);

/**
 * Middleware to allow only buyer users
 *
 * @returns {MiddlewareHandler} Hono middleware function
 */
export const requireBuyer: MiddlewareHandler = requireRole(['buyer']);