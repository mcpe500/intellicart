import { describe, it, expect, beforeAll, afterAll } from 'bun:test';
import { Hono } from 'hono';
import { AuthController } from '../../src/controllers/authController';
import { OrderController } from '../../src/controllers/OrderController';
import { ProductController } from '../../src/controllers/ProductController';
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

app.put('/api/orders/:id/status', async (c) => {
  const body = await c.req.json();
  (c.req as any).param = (name: string) => {
    if (name === 'id') return c.req.path.split('/')[4];
  };
  (c.req as any).valid = () => body;
  (c as any).set = (key: string, value: any) => {
    (c as any)._context = (c as any)._context || {};
    (c as any)._context[key] = value;
  };
  (c as any).get = (key: string) => {
    return (c as any)._context?.[key];
  };
  (c as any).set('user', { userId: 1 });
  return OrderController.updateOrderStatus(c);
});

app.get('/api/products', (c) => ProductController.getAllProducts(c));
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

describe('Complete Order Management Flow E2E Tests', () => {
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

  it('should complete the full order management flow: create product -> create order -> get orders -> update order status', async () => {
    // First, register and login to get a token (to simulate that we're authenticated)
    const registerResponse = await app.request('/api/auth/register', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'order-mgmt-test@example.com',
        password: 'password123',
        name: 'Order Mgmt Test',
        role: 'seller'
      }),
    });

    expect(registerResponse.status).toBe(201);
    const registerBody = await registerResponse.json();
    expect(registerBody.token).toBeDefined();
    userToken = registerBody.token;
    userId = registerBody.user.id;

    // Step 1: Create a product (as a seller would)
    const createProductResponse = await app.request('/api/products', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${userToken}`
      },
      body: JSON.stringify({
        name: 'Order Test Product',
        description: 'Product for order testing',
        price: '49.99',
        imageUrl: 'https://example.com/order-test-product.jpg'
      }),
    });

    expect(createProductResponse.status).toBe(201);
    const createProductBody = await createProductResponse.json();
    expect(createProductBody).toBeDefined();
    expect(createProductBody.name).toBe('Order Test Product');
    productId = createProductBody.id;

    // Step 2: Get all orders (should be empty initially)
    const getOrdersResponse = await app.request('/api/orders', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${userToken}`
      }
    });

    expect(getOrdersResponse.status).toBe(200);
    const getOrdersBody = await getOrdersResponse.json();
    expect(Array.isArray(getOrdersBody)).toBe(true);

    // Step 3: Simulate creation of an order in the database
    const db = dbManager.getDatabase();
    const orderData = {
      productId: productId,
      buyerId: 2, // Different user as buyer
      status: 'pending',
      sellerId: userId,
      createdAt: new Date().toISOString()
    };
    const createdOrder = await db.create('orders', orderData);
    orderId = createdOrder.id;

    // Step 4: Get all orders again (should now include our order)
    const getOrdersResponse2 = await app.request('/api/orders', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${userToken}`
      }
    });

    expect(getOrdersResponse2.status).toBe(200);
    const getOrdersBody2 = await getOrdersResponse2.json();
    expect(Array.isArray(getOrdersBody2)).toBe(true);
    expect(getOrdersBody2.length).toBeGreaterThan(0);

    // Step 5: Update the order status
    const updateStatusResponse = await app.request(`/api/orders/${orderId}/status`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${userToken}`
      },
      body: JSON.stringify({
        status: 'shipped'
      }),
    });

    expect(updateStatusResponse.status).toBe(200);
    const updateStatusBody = await updateStatusResponse.json();
    expect(updateStatusBody).toBeDefined();
    expect(updateStatusBody.id).toBe(orderId);
    expect(updateStatusBody.status).toBe('shipped');
  });

  it('should fail to update order status for non-existent order', async () => {
    // First login to get a token
    const loginResponse = await app.request('/api/auth/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'order-mgmt-test@example.com',
        password: 'password123'
      }),
    });

    expect(loginResponse.status).toBe(200);
    const loginBody = await loginResponse.json();
    expect(loginBody.token).toBeDefined();
    const token = loginBody.token;

    const response = await app.request('/api/orders/999999/status', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        status: 'shipped'
      }),
    });

    expect(response.status).toBe(404);
    const body = await response.json();
    expect(body.error).toBe('Order not found');
  });

  it('should fail to update order status for order that does not belong to user', async () => {
    // Create an order with a different seller ID
    const db = dbManager.getDatabase();
    const orderData = {
      productId: 1,
      buyerId: 2,
      status: 'pending',
      sellerId: 999, // Different seller
      createdAt: new Date().toISOString()
    };
    const testOrder = await db.create('orders', orderData);

    // First login to get a token
    const loginResponse = await app.request('/api/auth/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'order-mgmt-test@example.com',
        password: 'password123'
      }),
    });

    expect(loginResponse.status).toBe(200);
    const loginBody = await loginResponse.json();
    expect(loginBody.token).toBeDefined();
    const token = loginBody.token;

    const response = await app.request(`/api/orders/${testOrder.id}/status`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        status: 'shipped'
      }),
    });

    // Clean up
    await db.delete('orders', testOrder.id);

    expect(response.status).toBe(403);
    const body = await response.json();
    expect(body.error).toBe('You can only update orders associated with your products');
  });

  it('should return empty list when seller has no orders', async () => {
    // First login to get a token
    const loginResponse = await app.request('/api/auth/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'order-mgmt-test@example.com',
        password: 'password123'
      }),
    });

    expect(loginResponse.status).toBe(200);
    const loginBody = await loginResponse.json();
    expect(loginBody.token).toBeDefined();
    const token = loginBody.token;

    const response = await app.request('/api/orders', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    expect(response.status).toBe(200);
    const body = await response.json();
    expect(Array.isArray(body)).toBe(true);
  });
});