import { describe, it, expect, beforeEach } from 'bun:test';
import { Hono } from 'hono';
import { authMiddleware } from '../../../../src/middleware/auth';

describe('Auth Middleware', () => {
  let app: Hono;
  let originalEnv: NodeJS.ProcessEnv;

  beforeEach(() => {
    // Store original environment
    originalEnv = { ...process.env };
    // Set JWT secret for tests
    process.env.JWT_SECRET = 'test-secret-key-12345';
    
    app = new Hono();
    
    // Apply middleware and a simple final handler to check context
    app.use('*', authMiddleware);
    app.get('/protected', (c) => {
      const payload = c.get('jwtPayload');
      return c.json({ ok: true, payload });
    });
  });

  afterEach(() => {
    // Restore environment
    process.env = originalEnv;
  });

  it('should return 401 if Authorization header is missing', async () => {
    const req = new Request('http://localhost/protected');
    const res = await app.request(req);
    expect(res.status).toBe(401);
    const body = await res.json();
    expect(body).toEqual({ error: 'Unauthorized: No token provided' });
  });

  it('should return 401 if Authorization header is not Bearer', async () => {
    const req = new Request('http://localhost/protected', {
      headers: { Authorization: 'Basic someauth' },
    });
    const res = await app.request(req);
    expect(res.status).toBe(401);
    const body = await res.json();
    expect(body).toEqual({ error: 'Unauthorized: No token provided' });
  });
});