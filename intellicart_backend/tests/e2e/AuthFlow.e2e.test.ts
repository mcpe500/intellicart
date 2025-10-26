import { describe, it, expect, beforeAll, afterAll } from 'bun:test';
import { Hono } from 'hono';
import { AuthController } from '../../src/controllers/authController';
import { UserController } from '../../src/controllers/UserController';
import { ProductController } from '../../src/controllers/ProductController';
import { OrderController } from '../../src/controllers/OrderController';
import { dbManager } from '../../src/database/Config';

// Create a test app to simulate the full server
const app = new Hono();

// Mock routes to simulate the full API
app.post('/api/auth/register', async (c) => {
  const body = await c.req.json();
  (c.req as any).valid = () => body;
  return AuthController.register(c);
});

app.post('/api/auth/login', async (c) => {
  const body = await c.req.json();
  (c.req as any).valid = () => body;
  return AuthController.login(c);
});

app.get('/api/auth/me', (c) => {
  return AuthController.getCurrentUser(c);
});

app.post('/api/auth/logout', (c) => {
  return AuthController.logout(c);
});

app.post('/api/auth/verify', (c) => {
  return AuthController.verifyToken(c);
});

app.get('/api/users', (c) => UserController.getAllUsers(c));
app.get('/api/users/:id', (c) => {
  (c.req as any).param = (name: string) => {
    if (name === 'id') return c.req.path.split('/')[3];
  };
  return UserController.getUserById(c);
});
app.post('/api/users', async (c) => {
  const body = await c.req.json();
  (c.req as any).valid = () => body;
  return UserController.createUser(c);
});

app.get('/api/products', (c) => ProductController.getAllProducts(c));
app.get('/api/products/:id', (c) => {
  (c.req as any).param = (name: string) => {
    if (name === 'id') return c.req.path.split('/')[3];
  };
  return ProductController.getProductById(c);
});
app.post('/api/products', async (c) => {
  const body = await c.req.json();
  (c.req as any).valid = () => body;
  (c as any).set = (key: string, value: any) => {
    (c as any)._context = (c as any)._context || {};
    (c as any)._context[key] = value;
  };
  (c as any).get = (key: string) => {
    return (c as any)._context?.[key];
  };
  (c as any).set('user', { userId: 1 });
  return ProductController.createProduct(c);
});

app.get('/api/orders', (c) => {
  (c as any).set = (key: string, value: any) => {
    (c as any)._context = (c as any)._context || {};
    (c as any)._context[key] = value;
  };
  (c as any).get = (key: string) => {
    return (c as any)._context?.[key];
  };
  (c as any).set('user', { userId: 1 });
  return OrderController.getSellerOrders(c);
});

describe('Complete Authentication Flow E2E Tests', () => {
  let userToken: string | null = null;
  let userId: number | null = null;
  let productId: number | null = null;
  let orderId: number | null = null;

  beforeAll(async () => {
    // Setup test database
    await dbManager.initialize();
  });

  afterAll(async () => {
    // Clean up test database
    const db = dbManager.getDatabase();
    try {
      if (userId) {
        await db.delete('users', userId);
      }
      if (productId) {
        await db.delete('products', productId);
      }
      if (orderId) {
        await db.delete('orders', orderId);
      }
    } catch (e) {
      // Database might not support this operation in test mode
    }

    if (db.close && typeof db.close === 'function') {
      await db.close();
    }
  });

  it('should complete the full authentication flow: register -> login -> get profile -> verify token -> logout', async () => {
    // Step 1: Register a new user
    const registerResponse = await app.request('/api/auth/register', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'e2e-test@example.com',
        password: 'password123',
        name: 'E2E Test User',
        role: 'buyer'
      }),
    });

    expect(registerResponse.status).toBe(201);
    const registerBody = await registerResponse.json();
    expect(registerBody.user).toBeDefined();
    expect(registerBody.user.email).toBe('e2e-test@example.com');
    expect(registerBody.token).toBeDefined();
    userId = registerBody.user.id;

    // Step 2: Login with the new user
    const loginResponse = await app.request('/api/auth/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'e2e-test@example.com',
        password: 'password123'
      }),
    });

    expect(loginResponse.status).toBe(200);
    const loginBody = await loginResponse.json();
    expect(loginBody.user).toBeDefined();
    expect(loginBody.user.email).toBe('e2e-test@example.com');
    expect(loginBody.token).toBeDefined();
    userToken = loginBody.token;

    // Step 3: Get user profile with valid token
    const profileResponse = await app.request('/api/auth/me', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${userToken}`
      }
    });

    expect(profileResponse.status).toBe(200);
    const profileBody = await profileResponse.json();
    expect(profileBody.email).toBe('e2e-test@example.com');
    expect(profileBody.name).toBe('E2E Test User');

    // Step 4: Verify token
    const verifyResponse = await app.request('/api/auth/verify', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${userToken}`
      }
    });

    expect(verifyResponse.status).toBe(200);
    const verifyBody = await verifyResponse.json();
    expect(verifyBody.valid).toBe(true);
    expect(verifyBody.user).toBeDefined();
    expect(verifyBody.user.email).toBe('e2e-test@example.com');

    // Step 5: Logout
    const logoutResponse = await app.request('/api/auth/logout', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${userToken}`
      }
    });

    expect(logoutResponse.status).toBe(200);
    const logoutBody = await logoutResponse.json();
    expect(logoutBody.message).toBe('Successfully logged out');
  });

  it('should allow user to interact with other resources after authentication', async () => {
    // First, login to get a token
    const loginResponse = await app.request('/api/auth/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'e2e-test@example.com',
        password: 'password123'
      }),
    });

    expect(loginResponse.status).toBe(200);
    const loginBody = await loginResponse.json();
    expect(loginBody.token).toBeDefined();
    const token = loginBody.token;

    // Create a product with the authenticated user
    const productResponse = await app.request('/api/products', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        name: 'E2E Test Product',
        description: 'Test product for E2E flow',
        price: '29.99',
        imageUrl: 'https://example.com/e2e-test-product.jpg'
      }),
    });

    expect(productResponse.status).toBe(201);
    const productBody = await productResponse.json();
    expect(productBody.name).toBe('E2E Test Product');
    expect(productBody.sellerId).toBe(1); // Mocked user ID
    productId = productBody.id;

    // Get all products
    const allProductsResponse = await app.request('/api/products', {
      method: 'GET',
    });

    expect(allProductsResponse.status).toBe(200);
    const allProductsBody = await allProductsResponse.json();
    expect(Array.isArray(allProductsBody)).toBe(true);

    // Get the specific product by ID
    const specificProductResponse = await app.request(`/api/products/${productId}`, {
      method: 'GET',
    });

    expect(specificProductResponse.status).toBe(200);
    const specificProductBody = await specificProductResponse.json();
    expect(specificProductBody.id).toBe(productId);
    expect(specificProductBody.name).toBe('E2E Test Product');

    // Get user's orders (should be empty initially)
    const ordersResponse = await app.request('/api/orders', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    expect(ordersResponse.status).toBe(200);
    const ordersBody = await ordersResponse.json();
    expect(Array.isArray(ordersBody)).toBe(true);
  });

  it('should fail authentication with invalid credentials', async () => {
    const loginResponse = await app.request('/api/auth/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'e2e-test@example.com',
        password: 'wrongpassword'
      }),
    });

    expect(loginResponse.status).toBe(401);
    const loginBody = await loginResponse.json();
    expect(loginBody.error).toBe('Invalid email or password');
  });

  it('should fail to get profile with invalid token', async () => {
    const profileResponse = await app.request('/api/auth/me', {
      method: 'GET',
      headers: {
        'Authorization': 'Bearer invalidtoken'
      }
    });

    expect(profileResponse.status).toBe(401);
    const profileBody = await profileResponse.json();
    expect(profileBody.error).toBe('Unauthorized');
  });

  it('should handle logout with invalid token gracefully', async () => {
    const logoutResponse = await app.request('/api/auth/logout', {
      method: 'POST',
      headers: {
        'Authorization': 'Bearer invalidtoken'
      }
    });

    expect(logoutResponse.status).toBe(400);
    const logoutBody = await logoutResponse.json();
    expect(logoutBody.error).toBe('No token provided');
  });
});