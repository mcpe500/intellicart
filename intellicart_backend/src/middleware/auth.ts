import { MiddlewareHandler } from 'hono';
import { verify } from 'hono/jwt';
import { JWTUserPayload } from '../types/AuthTypes';
import { Logger } from '../utils/logger';

export const authMiddleware: MiddlewareHandler = async (c, next) => {
  const authHeader = c.req.header('Authorization');

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    Logger.warn('Auth middleware: No token provided');
    return c.json({ error: 'Unauthorized: No token provided' }, 401);
  }

  const token = authHeader.split(' ')[1];
  
  try {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
      Logger.error('JWT_SECRET not set in environment variables');
      throw new Error('JWT_SECRET not set');
    }
    const decodedPayload = await verify(token, secret) as JWTUserPayload;
    c.set('jwtPayload', decodedPayload);
    await next();
  } catch (error) {
    Logger.warn('Auth middleware: Invalid token', { error: (error as Error).message });
    return c.json({ error: 'Unauthorized: Invalid token' }, 401);
  }
};