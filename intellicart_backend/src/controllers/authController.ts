/**
 * Authentication Controller
 *
 * This controller handles all authentication-related business logic including:
 * - User registration
 * - User login
 * - Token generation and validation
 *
 * All methods are static for easy access from route handlers.
 * The controller uses the DatabaseManager for user data persistence.
 *
 * @class AuthController
 * @description Business logic layer for authentication operations
 * @author Intellicart Team
 * @version 1.0.0
 */

import { Context } from "hono";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { dbManager } from "../database/Config";
import { logger } from "../utils/logger";

export class AuthController {
  /**
   * Register a new user
   *
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing the created user object and authentication token
   * @route POST /api/auth/register
   *
   * Request body:
   * {
   *   "email": "user@example.com",
   *   "password": "password123",
   *   "name": "John Doe",
   *   "role": "buyer"
   * }
   *
   * Example response:
   * {
   *   "user": {
   *     "id": 3,
   *     "email": "user@example.com",
   *     "name": "John Doe",
   *     "role": "buyer",
   *     "createdAt": "2023-01-01T00:00:00.000Z"
   *   },
   *   "token": "jwt-token-here"
   * }
   */
  static async register(c: Context) {
    try {
      const body = (await c.req.json()) as {
        email: string;
        password: string;
        name: string;
        role: string;
      };

      const { email, password, name, role } = body;

      // Log the registration attempt
      logger.info("Registration attempt received", {
        email,
        ip:
          c.req.header("x-forwarded-for") ||
          c.req.header("x-real-ip") ||
          c.req.header("x-forwarded-host") ||
          c.req.header("x-forwarded-server") ||
          c.req.header("x-forwarded-proto") ||
          c.req.header("x-forwarded-port") ||
          c.req.header("x-forwarded-by"),
        userAgent: c.req.header("user-agent"),
      });

      const db = dbManager.getDatabase<any>();

      // Check if user already exists
      const existingUser = await db.findOne("users", { email });
      if (existingUser) {
        logger.warn("Registration failed - user already exists", { email });
        return c.json({ error: "User with this email already exists" }, 409);
      }

      // Hash the password
      const saltRounds = 10;
      const hashedPassword = await bcrypt.hash(password, saltRounds);

      // Create new user object
      const newUser = {
        email,
        password: hashedPassword,
        name,
        role: role || "buyer", // default to 'buyer' if no role provided
        createdAt: new Date().toISOString(), // Add creation timestamp
      };

      const createdUser = await db.create("users", newUser);

      // Generate JWT token
      const token = jwt.sign(
        { userId: createdUser.id, email: createdUser.email },
        process.env.JWT_SECRET || "default_secret",
        { expiresIn: "24h" },
      );

      // Add token to active tokens in database
      const decodedToken = jwt.decode(token) as { exp: number };
      await db.create("tokens", {
        token,
        userId: createdUser.id,
        email: createdUser.email,
        exp: decodedToken.exp,
        createdAt: new Date().toISOString(),
      });

      // Return user data and token (without password)
      const { password: _, ...userWithoutPassword } = createdUser;

      // Log successful registration
      logger.info("User registered successfully", {
        userId: createdUser.id,
        email: createdUser.email,
      });
      return c.json(
        {
          user: userWithoutPassword,
          token,
        },
        201,
      );
    } catch (error) {
      logger.error("Error during user registration:", {
        error: error instanceof Error ? error.message : "Unknown error",
        email: body?.email,
      });
      console.error("Error during user registration:", error);
      return c.json({ error: "Internal server error" }, 500);
    }
  }

  /**
   * Login a user
   *
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing the user object and authentication token
   * @route POST /api/auth/login
   *
   * Request body:
   * {
   *   "email": "user@example.com",
   *   "password": "password123"
   * }
   *
   * Example response:
   * {
   *   "user": {
   *     "id": 1,
   *     "email": "user@example.com",
   *     "name": "John Doe",
   *     "role": "buyer",
   *     "createdAt": "2023-01-01T00:00:00.000Z"
   *   },
   *   "token": "jwt-token-here"
   * }
   */
  static async login(c: Context) {
    try {
      const body = (await c.req.json()) as {
        email: string;
        password: string;
      };

      const { email, password } = body;

      // Log the login attempt
      logger.info("Login attempt received", {
        email,
        ip:
          c.req.header("x-forwarded-for") ||
          c.req.header("x-real-ip") ||
          c.req.header("x-forwarded-host") ||
          c.req.header("x-forwarded-server") ||
          c.req.header("x-forwarded-proto") ||
          c.req.header("x-forwarded-port") ||
          c.req.header("x-forwarded-by"),
        userAgent: c.req.header("user-agent"),
      });

      const db = dbManager.getDatabase<any>();

      // Find user in database by email
      const user = await db.findOne("users", { email });

      // Return 401 if user not found
      if (!user) {
        logger.warn("Login failed - user not found", { email });
        return c.json({ error: "Invalid email or password" }, 401);
      }

      // Verify password using bcrypt
      const isPasswordValid = await bcrypt.compare(password, user.password);

      if (!isPasswordValid) {
        logger.warn("Login failed - invalid password", { email });
        return c.json({ error: "Invalid email or password" }, 401);
      }

      // Generate JWT token
      const token = jwt.sign(
        { userId: user.id, email: user.email },
        process.env.JWT_SECRET || "default_secret",
        { expiresIn: "24h" },
      );

      // Add token to active tokens in database
      const decodedToken = jwt.decode(token) as { exp: number };
      await db.create("tokens", {
        token,
        userId: user.id,
        email: user.email,
        exp: decodedToken.exp,
        createdAt: new Date().toISOString(),
      });

      // Return user data and token (without password)
      const { password: _, ...userWithoutPassword } = user;

      // Log successful login
      logger.info("User logged in successfully", {
        userId: user.id,
        email: user.email,
      });
      return c.json({
        user: userWithoutPassword,
        token,
      });
    } catch (error) {
      logger.error("Error during user login:", {
        error: error instanceof Error ? error.message : "Unknown error",
        email: body?.email,
      });
      console.error("Error during user login:", error);
      return c.json({ error: "Internal server error" }, 500);
    }
  }

  /**
   * Get current user profile (requires valid token)
   *
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response containing the current user object
   * @route GET /api/auth/me
   */
  static async getCurrentUser(c: Context) {
    try {
      // Get the user from the context (set by authentication middleware)
      const user = c.get("user");

      if (!user) {
        return c.json({ error: "Unauthorized" }, 401);
      }

      const db = dbManager.getDatabase<any>();

      // Find the full user data
      const fullUser = await db.findById("users", user.userId);

      if (!fullUser) {
        // If token exists but user doesn't, the user was likely deleted
        // In this case, we should remove the token and return unauthorized
        const dbTokens = dbManager.getDatabase<any>();
        const tokenHeader = c.req.header("Authorization");
        if (tokenHeader && tokenHeader.startsWith("Bearer ")) {
          const token = tokenHeader.substring(7);
          try {
            const activeTokens = await dbTokens.findAll("tokens");
            const tokenRecord = activeTokens.find((t: any) => t.token === token);
            if (tokenRecord) {
              await dbTokens.delete("tokens", tokenRecord.id);
            }
          } catch (error) {
            // Ignore errors during cleanup
          }
        }
        return c.json({ error: "Unauthorized" }, 401);
      }

      // Return user data (without password)
      const { password: _, ...userWithoutPassword } = fullUser;
      return c.json(userWithoutPassword);
    } catch (error) {
      console.error("Error retrieving current user:", error);
      return c.json({ error: "Internal server error" }, 500);
    }
  }

  /**
   * Logout user (invalidate token)
   *
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response confirming logout
   * @route POST /api/auth/logout
   */
  static async logout(c: Context) {
    try {
      // Get authorization header
      const authHeader = c.req.header("Authorization");

      if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return c.json({ error: "No token provided" }, 400);
      }

      const token = authHeader.substring(7); // Remove 'Bearer ' prefix

      // Decode token to get user information for logging
      let userId: number | undefined;
      let userEmail: string | undefined;
      try {
        const decodedToken = jwt.decode(token) as {
          userId: number;
          email: string;
        } | null;
        if (decodedToken) {
          userId = decodedToken.userId;
          userEmail = decodedToken.email;
        }
      } catch (decodeError) {
        console.error("Error decoding token for logout logging:", decodeError);
      }

      // Log the logout attempt
      logger.info("Logout attempt received", {
        userId,
        userEmail,
        ip:
          c.req.header("x-forwarded-for") ||
          c.req.header("x-real-ip") ||
          c.req.header("x-forwarded-host") ||
          c.req.header("x-forwarded-server") ||
          c.req.header("x-forwarded-proto") ||
          c.req.header("x-forwarded-port") ||
          c.req.header("x-forwarded-by"),
        userAgent: c.req.header("user-agent"),
      });

      // Remove token from active tokens in database
      const db = dbManager.getDatabase<any>();
      let activeTokens;
      try {
        activeTokens = await db.findAll("tokens");
      } catch (error) {
        // If the tokens table doesn't exist, create an empty array
        activeTokens = [];
      }

      const tokenRecord = activeTokens.find((t) => t.token === token);

      if (tokenRecord) {
        await db.delete("tokens", tokenRecord.id);
      }

      // Log successful logout
      logger.info("User logged out successfully", { userId, userEmail });
      return c.json({ message: "Successfully logged out" });
    } catch (error) {
      logger.error("Error during user logout:", {
        error: error instanceof Error ? error.message : "Unknown error",
      });
      console.error("Error during logout:", error);
      return c.json({ error: "Internal server error" }, 500);
    }
  }

  /**
   * Verify if a token is valid
   *
   * @static
   * @async
   * @param {Context} c - Hono context object containing request/response information
   * @returns {Promise} JSON response confirming token validity
   * @route POST /api/auth/verify
   */
  static async verifyToken(c: Context) {
    try {
      // Get authorization header
      const authHeader = c.req.header("Authorization");

      if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return c.json({ valid: false }, 400);
      }

      const token = authHeader.substring(7); // Remove 'Bearer ' prefix

      // Check if token exists in our active tokens in database
      const db = dbManager.getDatabase<any>();
      let activeTokens;
      try {
        activeTokens = await db.findAll("tokens");
      } catch (error) {
        // If the tokens table doesn't exist, create an empty array
        activeTokens = [];
      }

      const tokenRecord = activeTokens.find((t) => t.token === token);
      if (!tokenRecord) {
        return c.json({ valid: false }, 401);
      }

      // Verify token hasn't expired
      const currentTime = Math.floor(Date.now() / 1000); // Current time in seconds

      if (currentTime > tokenRecord.exp) {
        // Remove expired token from database
        await db.delete("tokens", tokenRecord.id);
        return c.json({ valid: false }, 401);
      }

      return c.json({
        valid: true,
        user: { id: tokenRecord.userId, email: tokenRecord.email },
      });
    } catch (error) {
      console.error("Error verifying token:", error);
      return c.json({ error: "Internal server error" }, 500);
    }
  }
}
