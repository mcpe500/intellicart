import { Context, Next } from 'hono';

export const cors = async (c: Context, next: Next) => {
  // Set CORS headers
  c.header('Access-Control-Allow-Origin', '*'); // In production, specify your frontend domain
  c.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  c.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  c.header('Access-Control-Max-Age', '86400'); // 24 hours

  // Handle preflight requests
  if (c.req.method === 'OPTIONS') {
    return c.text('', 204);
  }

  await next();
};