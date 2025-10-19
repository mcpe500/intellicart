import { Context } from 'hono';
import { sign, verify } from 'hono/jwt';
import { db } from '../database/db_service';
import { LoginCredentials, AuthResponse, JWTUserPayload, RefreshTokenRequest, RefreshTokenResponse } from '../types/AuthTypes';
import { User } from '../types/UserTypes';
import { Logger } from '../utils/logger';

export class AuthController {
  static async login(c: Context) {
    try {
      const { email } = await c.req.json() as LoginCredentials;
      Logger.info(`Login attempt for user: ${email}`);
      
      const { email: reqEmail, password } = await c.req.json() as LoginCredentials;
      
      if (!reqEmail || !password) {
        Logger.warn(`Login failed: Missing email or password for IP: ${c.req.header('x-forwarded-for') || c.req.header('x-real-ip') || c.req.raw.url}`);
        return c.json({ error: 'Email and password are required' }, 400);
      }

      const user = await db().getUserByEmail(reqEmail);
      
      if (!user) { // In a real app, you'd hash passwords and compare
        Logger.warn(`Login failed: Invalid credentials for email: ${reqEmail}`);
        return c.json({ error: 'Invalid email or password' }, 401);
      }

      // For now, we'll assume the password is valid if the user exists
      // In a real implementation, you'd compare the hashed password
      // if (user.password !== password) { // This line would need to be implemented with proper password hashing
      //   return c.json({ error: 'Invalid email or password' }, 401);
      // }

      // Create JWT token
      const secret = process.env.JWT_SECRET;
      if (!secret) {
        Logger.error('JWT_SECRET not set in environment variables');
        throw new Error('JWT_SECRET not set in environment variables');
      }

      const token = await sign({
        id: user.id,
        email: user.email,
        role: user.role,
      } as JWTUserPayload, secret); // Removed exp to avoid potential conflicts with middleware

      // Generate a refresh token (in a real implementation, this should be stored securely)
      const refreshToken = await sign({
        id: user.id,
        email: user.email,
        role: user.role,
        type: 'refresh'
      } as JWTUserPayload, process.env.JWT_SECRET + '_refresh'); // In production, use a separate secret

      const response: AuthResponse = {
        token,
        refreshToken,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          createdAt: user.createdAt // assuming the user object has this property
        }
      };

      Logger.info(`Login successful for user: ${reqEmail}, ID: ${user.id}`);
      return c.json(response);
    } catch (error) {
      Logger.error('Login error:', { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  static async register(c: Context) {
    try {
      const { name, email, password, role } = await c.req.json() as Partial<User> & { password: string };
      
      Logger.info(`Registration attempt for user: ${email}`);
      
      if (!name || !email || !password) {
        Logger.warn(`Registration failed: Missing required fields for email: ${email}`);
        return c.json({ error: 'Name, email, and password are required' }, 400);
      }

      // Check if user already exists
      const existingUser = await db().getUserByEmail(email);
      if (existingUser) {
        Logger.warn(`Registration failed: Email already exists: ${email}`);
        return c.json({ error: 'User with this email already exists' }, 409);
      }

      // Create new user
      const newUser = await db().createUser({
        name,
        email,
        password, // In a real app, you'd hash this
        role: role || 'buyer'
      });

      // Create JWT token
      const secret = process.env.JWT_SECRET;
      if (!secret) {
        Logger.error('JWT_SECRET not set in environment variables');
        throw new Error('JWT_SECRET not set in environment variables');
      }

      const token = await sign({
        id: newUser.id,
        email: newUser.email,
        role: newUser.role,
      } as JWTUserPayload, secret); // Removed exp to avoid potential conflicts with middleware

      // Generate a refresh token (in a real implementation, this should be stored securely)
      const refreshToken = await sign({
        id: newUser.id,
        email: newUser.email,
        role: newUser.role,
        type: 'refresh'
      } as JWTUserPayload, process.env.JWT_SECRET + '_refresh'); // In production, use a separate secret

      const response: AuthResponse = {
        token,
        refreshToken,
        user: {
          id: newUser.id,
          name: newUser.name,
          email: newUser.email,
          role: newUser.role,
          createdAt: newUser.createdAt // assuming the user object has this property
        }
      };

      Logger.info(`Registration successful for user: ${email}, ID: ${newUser.id}`);
      return c.json(response, 201);
    } catch (error) {
      Logger.error('Registration error:', { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  static async getProfile(c: Context) {
    try {
      const jwtPayload = c.get('jwtPayload') as JWTUserPayload;
      
      if (!jwtPayload) {
        return c.json({ error: 'Authentication required' }, 401);
      }
      
      const user = await db().getUserById(jwtPayload.id);
      
      if (!user) {
        return c.json({ error: 'User not found' }, 404);
      }

      return c.json({
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        createdAt: user.createdAt
      });
    } catch (error) {
      console.error('Get profile error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  static async refreshToken(c: Context) {
    try {
      const { refreshToken } = await c.req.json() as RefreshTokenRequest;
      
      if (!refreshToken) {
        return c.json({ error: 'Refresh token is required' }, 400);
      }

      try {
        // Verify the refresh token
        const secret = process.env.JWT_SECRET;
        if (!secret) {
          throw new Error('JWT_SECRET not set in environment variables');
        }

        // Verify using the refresh token secret
        const decodedPayload = await verify(refreshToken, secret + '_refresh') as JWTUserPayload;
        
        if (!decodedPayload || decodedPayload.type !== 'refresh') {
          return c.json({ error: 'Invalid refresh token' }, 400);
        }

        // Check if user still exists
        const user = await db().getUserById(decodedPayload.id);
        if (!user) {
          return c.json({ error: 'User not found' }, 404);
        }

        // Generate new access token
        const newToken = await sign({
          id: user.id,
          email: user.email,
          role: user.role,
        } as JWTUserPayload, secret);

        // Generate new refresh token
        const newRefreshToken = await sign({
          id: user.id,
          email: user.email,
          role: user.role,
          type: 'refresh'
        } as JWTUserPayload, secret + '_refresh');

        const response: RefreshTokenResponse = {
          token: newToken,
          refreshToken: newRefreshToken
        };

        return c.json(response);
      } catch (verifyError) {
        console.error('Token verification error:', verifyError);
        return c.json({ error: 'Invalid refresh token' }, 400);
      }
    } catch (error) {
      console.error('Refresh token error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
}