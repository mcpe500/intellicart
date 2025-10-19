import { MiddlewareHandler } from 'hono';
import { verify } from 'hono/jwt';
import { JWTUserPayload } from '../types/AuthTypes';

export const authMiddleware: MiddlewareHandler = async (c, next) => {
  const authHeader = c.req.header('Authorization');

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Unauthorized: No token provided' }, 401);
  }

  const token = authHeader.split(' ')[1];
  
  try {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
        throw new Error("JWT_SECRET not set");
    }
    const decodedPayload = await verify(token, secret) as JWTUserPayload;
    c.set('jwtPayload', decodedPayload);
    await next();
  } catch (error) {
    return c.json({ error: 'Unauthorized: Invalid token' }, 401);
  }
};