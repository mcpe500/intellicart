import { MiddlewareHandler } from 'hono';
import { verify } from 'hono/jwt';
import { JWTUserPayload } from '../types/AuthTypes';
import { Logger } from '../utils/logger';

export const authMiddleware: MiddlewareHandler = async (c, next) => {
  console.log("c.req.header()", c.req.header())
  const authHeader = c.req.header('Authorization');
  Logger.debug('Auth middleware: Authorization header received', { authHeader });

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    Logger.warn('Auth middleware: No token provided');
    return c.json({ error: 'Unauthorized: No token provided' }, 401);
  }

  const token = authHeader.split(' ')[1];
  Logger.debug('Auth middleware: Extracted token', { token: token ? '***REDACTED***' : 'undefined' });

  try {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
      Logger.error('JWT_SECRET not set in environment variables');
      throw new Error('JWT_SECRET not set');
    }
    Logger.debug('Auth middleware: Using JWT secret', { secretLength: secret.length });

    const decodedPayload = await verify(token, secret) as JWTUserPayload;
    Logger.debug('Auth middleware: Decoded JWT payload', { decodedPayload });

    c.set('jwtPayload', decodedPayload);
    Logger.debug('Auth middleware: Set JWT payload on context', { payloadSet: !!decodedPayload });

    await next();
  } catch (error) {
    Logger.warn('Auth middleware: Invalid token', { error: (error as Error).message });
    return c.json({ error: 'Unauthorized: Invalid token' }, 401);
  }
};