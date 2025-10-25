/**
 * Authentication Controller
 * 
 * This controller handles all authentication-related business logic including:
 * - User registration
 * - User login
 * - Token generation and validation
 * 
 * All methods are static for easy access from route handlers.
 * The controller uses a mock in-memory database for demonstration purposes.
 * 
 * @class AuthController
 * @description Business logic layer for authentication operations
 * @author Intellicart Team
 * @version 1.0.0
 */

import { Context } from 'hono';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

// Mock in-memory database for users
// In a real application, this would be replaced with a persistent database
let users: Array<{
  id: number;
  name: string;
  email: string;
  password: string; // Hashed password
  role: string; // 'buyer' or 'seller'
  createdAt: string;
}> = [
  {
    id: 1,
    name: 'John Buyer',
    email: 'buyer@example.com',
    password: '$2a$10$8K1p/a0d44LpQqK4k8K1pOYqK4k8K1pOYqK4k8K1pOYqK4k8K1pOYq', // bcrypt hash for 'password123'
    role: 'buyer',
    createdAt: new Date().toISOString(),
  },
  {
    id: 2,
    name: 'Jane Seller',
    email: 'seller@example.com',
    password: '$2a$10$8K1p/a0d44LpQqK4k8K1pOYqK4k8K1pOYqK4k8K1pOYqK4k8K1pOYq', // bcrypt hash for 'password123'
    role: 'seller',
    createdAt: new Date().toISOString(),
  },
];

// In-memory "database" for storing tokens (in production, use Redis or database)
const activeTokens: Map<string, { userId: number, email: string, exp: number }> = new Map();

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
    // Extract validated request body from context
    // The body has already been validated against Zod schema in route definition
    const body = c.req.valid('json') as {
      email: string;
      password: string;
      name: string;
      role: string;
    };
    
    const { email, password, name, role } = body;

    // Check if user already exists
    const existingUser = users.find(u => u.email === email);
    if (existingUser) {
      return c.json({ error: 'User with this email already exists' }, 409);
    }

    // Hash the password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Generate new user object with auto-incremented ID and creation timestamp
    const newUser = {
      // Calculate new ID based on current highest ID in database
      id: users.length > 0 ? Math.max(...users.map(u => u.id)) + 1 : 1,
      email,
      password: hashedPassword,
      name,
      role: role || 'buyer', // default to 'buyer' if no role provided
      createdAt: new Date().toISOString(), // Add creation timestamp
    };

    // Add new user to mock database
    users.push(newUser);

    // Generate JWT token
    const token = jwt.sign(
      { userId: newUser.id, email: newUser.email },
      process.env.JWT_SECRET || 'default_secret',
      { expiresIn: '24h' }
    );

    // Add token to active tokens map
    const decodedToken = jwt.decode(token) as { exp: number };
    activeTokens.set(token, {
      userId: newUser.id,
      email: newUser.email,
      exp: decodedToken.exp
    });

    // Return user data and token (without password)
    const { password: _, ...userWithoutPassword } = newUser;
    return c.json({ 
      user: userWithoutPassword, 
      token 
    });
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
    // Extract validated request body from context
    const body = c.req.valid('json') as {
      email: string;
      password: string;
    };
    
    const { email, password } = body;

    // Find user in mock database by email
    const user = users.find(u => u.email === email);
    
    // Return 404 if user not found
    if (!user) {
      return c.json({ error: 'Invalid email or password' }, 401);
    }

    // Verify password using bcrypt
    const isPasswordValid = await bcrypt.compare(password, user.password);
    
    if (!isPasswordValid) {
      return c.json({ error: 'Invalid email or password' }, 401);
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET || 'default_secret',
      { expiresIn: '24h' }
    );

    // Add token to active tokens map
    const decodedToken = jwt.decode(token) as { exp: number };
    activeTokens.set(token, {
      userId: user.id,
      email: user.email,
      exp: decodedToken.exp
    });

    // Return user data and token (without password)
    const { password: _, ...userWithoutPassword } = user;
    return c.json({ 
      user: userWithoutPassword, 
      token 
    });
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
    // Get the user from the context (set by authentication middleware)
    const user = c.get('user');
    
    if (!user) {
      return c.json({ error: 'Unauthorized' }, 401);
    }

    // Find the full user data
    const fullUser = users.find(u => u.id === user.userId);
    
    if (!fullUser) {
      return c.json({ error: 'User not found' }, 404);
    }

    // Return user data (without password)
    const { password: _, ...userWithoutPassword } = fullUser;
    return c.json(userWithoutPassword);
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
    // Get authorization header
    const authHeader = c.req.header('Authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return c.json({ error: 'No token provided' }, 400);
    }
    
    const token = authHeader.substring(7); // Remove 'Bearer ' prefix
    
    // Remove token from active tokens
    activeTokens.delete(token);
    
    return c.json({ message: 'Successfully logged out' });
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
    // Get authorization header
    const authHeader = c.req.header('Authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return c.json({ valid: false }, 400);
    }
    
    const token = authHeader.substring(7); // Remove 'Bearer ' prefix
    
    // Check if token exists in our active tokens map
    if (!activeTokens.has(token)) {
      return c.json({ valid: false }, 401);
    }
    
    // Verify token hasn't expired
    const tokenData = activeTokens.get(token)!;
    const currentTime = Math.floor(Date.now() / 1000); // Current time in seconds
    
    if (currentTime > tokenData.exp) {
      activeTokens.delete(token); // Remove expired token
      return c.json({ valid: false }, 401);
    }
    
    return c.json({ valid: true, user: { id: tokenData.userId, email: tokenData.email } });
  }
}