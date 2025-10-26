import { describe, it, expect, beforeAll, afterAll, vi } from 'bun:test';
import { Hono } from 'hono';
import { OrderController } from '../../../src/controllers/OrderController';
import { dbManager } from '../../../src/database/Config';
import { logger } from '../../../src/utils/logger';

// Mock logger to avoid console output during tests
vi.mock('../../../src/utils/logger', () => ({
  logger: {
    info: vi.fn(),
    warn: vi.fn(),
    error: vi.fn(),
  }
}));

// Create a test app with order routes
const app = new Hono();

// Simple mock for request validation and context
const mockValid = (data: any) => (source: string) => {
  if (source === 'json') {
    return data;
  }
};

// Mock routes for testing
app.get('/orders', (c) => {
  // Mock user context 
  (c as any).set = (key: string, value: any) => {
    (c as any)._context = (c as any)._context || {};
    (c as any)._context[key] = value;
  };
  (c as any).get = (key: string) => {
    return (c as any)._context?.[key];
  };
  // Set a mock user with ID 1
  (c as any).set('user', { userId: 1 });
  return OrderController.getSellerOrders(c);
});

app.put('/orders/:id/status', async (c) => {
  const body = await c.req.json();
  (c.req as any).param = (name: string) => {
    if (name === 'id') return c.req.path.split('/')[3]; // Extract ID from path
  };
  (c.req as any).valid = () => body;
  // Mock user context 
  (c as any).set = (key: string, value: any) => {
    (c as any)._context = (c as any)._context || {};
    (c as any)._context[key] = value;
  };
  (c as any).get = (key: string) => {
    return (c as any)._context?.[key];
  };
  // Set a mock user with ID 1
  (c as any).set('user', { userId: 1 });
  return OrderController.updateOrderStatus(c);
});

describe('Order Integration Tests', () => {
  let testOrderId: number | null = null;
  
  beforeAll(async () => {
    // Setup test database - using memory database for tests
    await dbManager.init();
  });

  afterAll(async () => {
    // Clean up test database
    const db = dbManager.getDatabase();
    if (testOrderId) {
      try {
        if (db.delete && typeof db.delete === 'function') {
          await db.delete('orders', testOrderId);
        }
      } catch (e) {
        // Database might not support this operation in test mode
      }
    }
    if (db.close && typeof db.close === 'function') {
      await db.close();
    }
  });

  it('should retrieve seller orders', async () => {
    const response = await app.request('/orders', {
      method: 'GET',
    });

    expect(response.status).toBe(200);
    
    const responseBody = await response.json();
    expect(Array.isArray(responseBody)).toBe(true);
  });

  it('should update order status successfully', async () => {
    // First, create a test order in the database
    const db = dbManager.getDatabase();
    const testOrder = await db.create('orders', {
      productId: 1,
      buyerId: 2,
      status: 'pending',
      sellerId: 1,
      createdAt: new Date().toISOString()
    });
    
    testOrderId = testOrder.id;

    const response = await app.request(`/orders/${testOrderId}/status`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        status: 'shipped'
      }),
    });

    expect(response.status).toBe(200);
    
    const responseBody = await response.json();
    expect(responseBody).toBeDefined();
    expect(responseBody.id).toBe(testOrderId);
    expect(responseBody.status).toBe('shipped');
  });

  it('should return 404 when trying to update non-existent order', async () => {
    const response = await app.request('/orders/999999/status', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        status: 'shipped'
      }),
    });

    expect(response.status).toBe(404);
    
    const responseBody = await response.json();
    expect(responseBody.error).toBe('Order not found');
  });

  it('should return 403 when user is not the seller of the order', async () => {
    // Create an order with a different seller ID
    const db = dbManager.getDatabase();
    const testOrder = await db.create('orders', {
      productId: 1,
      buyerId: 2,
      status: 'pending',
      sellerId: 2, // Different seller
      createdAt: new Date().toISOString()
    });

    const response = await app.request(`/orders/${testOrder.id}/status`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        status: 'shipped'
      }),
    });

    // Clean up
    await db.delete('orders', testOrder.id);

    expect(response.status).toBe(403);
    
    const responseBody = await response.json();
    expect(responseBody.error).toBe('You can only update orders associated with your products');
  });
});