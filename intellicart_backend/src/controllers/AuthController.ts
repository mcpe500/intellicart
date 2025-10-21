import { Context } from 'hono';
import { sign, verify } from 'hono/jwt';
import { db } from '../database/db_service';
import { LoginCredentials, AuthResponse, JWTUserPayload, RefreshTokenRequest, RefreshTokenResponse } from '../types/AuthTypes';
import { User } from '../types/UserTypes';
import { Logger } from '../utils/logger';

export class AuthController {
  static async login(c: Context) {
    try {
      const { email, password } = await c.req.json() as LoginCredentials;

      Logger.debug('Login request body:', { email });
      Logger.info(`Login attempt for user: ${email}`);

      if (!email || !password) {
        Logger.warn(`Login failed: Missing email or password`);
        return c.json({ error: 'Email and password are required' }, 400);
      }

      const user = await db().getUserByEmail(email);

      if (!user) {
        Logger.warn(`Login failed: Invalid credentials for email: ${email}`);
        return c.json({ error: 'Invalid email or password' }, 401);
      }

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
      } as JWTUserPayload, secret);

      const refreshToken = await sign({
        id: user.id,
        email: user.email,
        role: user.role,
        type: 'refresh'
      } as JWTUserPayload, secret + '_refresh');

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

      Logger.info(`Login successful for user: ${email}, ID: ${user.id}`);
      return c.json(response);
    } catch (error) {
      Logger.error('Login error:', { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Internal server error' }, 500);
    }
  }

  static async register(c: Context) {
    try {
      let body;
      try {
        body = await c.req.json();
        Logger.debug('Raw registration body:', body);
      } catch (parseError) {
        Logger.error('JSON parse error:', { error: (parseError as Error).message });
        return c.json({ error: 'Invalid JSON' }, 400);
      }

      const { name, email, password, role } = body as Partial<User> & { password: string };
      Logger.debug('Registration request body:', { name, email, role });
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
      } as JWTUserPayload, secret);

      const refreshToken = await sign({
        id: newUser.id,
        email: newUser.email,
        role: newUser.role,
        type: 'refresh'
      } as JWTUserPayload, secret + '_refresh');

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
      Logger.error('Registration error:', {
        error: (error as Error).message,
        stack: (error as Error).stack,
        name: (error as Error).name
      });
      return c.json({ error: 'Internal server error', details: (error as Error).message }, 500);
    }
  }

  static async getProfile(c: Context) {
    try {
      console.log("c.get('jwtPayload')")
      console.log(c.get('jwtPayload'));
      const jwtPayload = c.get('jwtPayload') as JWTUserPayload;
      if (!jwtPayload) {
        Logger.warn('Get profile failed: No JWT payload');
        return c.json({ error: 'Authentication required' }, 401);
      }

      const user = await db().getUserById(jwtPayload.id);

      if (!user) {
        Logger.warn(`Get profile failed: User not found: ${jwtPayload.id}`);
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
      Logger.error('Get profile error:', { error: (error as Error).message, stack: (error as Error).stack });
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
          Logger.warn('Refresh token failed: Invalid token type');
          return c.json({ error: 'Invalid refresh token' }, 400);
        }

        const user = await db().getUserById(decodedPayload.id);
        if (!user) {
          Logger.warn(`Refresh token failed: User not found: ${decodedPayload.id}`);
          return c.json({ error: 'User not found' }, 404);
        }

        const newToken = await sign({
          id: user.id,
          email: user.email,
          role: user.role,
        } as JWTUserPayload, secret);

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

        Logger.info(`Token refreshed for user: ${user.id}`);
        return c.json(response);
      } catch (verifyError) {
        Logger.error('Token verification error:', { error: (verifyError as Error).message });
        return c.json({ error: 'Invalid refresh token' }, 400);
      }
    } catch (error) {
      Logger.error('Refresh token error:', { error: (error as Error).message, stack: (error as Error).stack });
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
}