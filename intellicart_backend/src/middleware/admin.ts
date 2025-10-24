import { Context } from 'hono';
import { Logger } from '../utils/logger';

export const adminMiddleware = async (c: Context, next: Function) => {
  const jwtPayload = c.get('jwtPayload');
  
  if (!jwtPayload) {
    Logger.warn('Admin access failed: No JWT payload');
    return c.json({ error: 'Authentication required' }, 401);
  }
  
  if (jwtPayload.role !== 'admin') {
    Logger.warn(`Admin access denied: User ${jwtPayload.id} with role ${jwtPayload.role} attempted admin access`);
    return c.json({ error: 'Admin access required' }, 403);
  }
  
  await next();
};