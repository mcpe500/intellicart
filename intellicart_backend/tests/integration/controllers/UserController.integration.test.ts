import { describe, it, expect, beforeAll, afterAll } from 'bun:test';
import { Hono } from 'hono';
import { UserController } from '../../../src/controllers/UserController';
import { AuthController } from '../../../src/controllers/authController';
import { dbManager } from '../../../src/database/Config';

// Mock logger to avoid console output during tests
const mockedLogger = {
  info: () => {},
  warn: () => {},
  error: () => {},
};

// Create a test app with user routes
const app = new Hono();

// Simple mock for request validation
const mockValid = (data: any) => (source: string) => {
  if (source === 'json') {
    return data;
  }
};

// Mock routes for testing
app.get('/users', (c) => UserController.getAllUsers(c));

app.get('/users/:id', (c) => {
  // Mock param
  (c.req as any).param = (name: string) => {
    if (name === 'id') return c.req.path.split('/')[2]; // Extract ID from path
  };
  return UserController.getUserById(c);
});

app.post('/users', async (c) => {
  const body = await c.req.json();
  (c.req as any).valid = () => body;
  return UserController.createUser(c);
});

app.put('/users/:id', async (c) => {
  const body = await c.req.json();
  (c.req as any).param = (name: string) => {
    if (name === 'id') return c.req.path.split('/')[2]; // Extract ID from path
  };
  (c.req as any).valid = () => body;
  return UserController.updateUser(c);
});

app.delete('/users/:id', (c) => {
  (c.req as any).param = (name: string) => {
    if (name === 'id') return c.req.path.split('/')[2]; // Extract ID from path
  };
  return UserController.deleteUser(c);
});

describe('User Integration Tests', () => {
  let testUserId: number | null = null;
  
  beforeAll(async () => {
    // Setup test database - using memory database for tests
    await dbManager.initialize();
    
    // Clean up any existing test users before running tests
    const db = dbManager.getDatabase();
    try {
      const existingUser = await db.findOne('users', { email: 'integration-test-user@example.com' });
      if (existingUser && existingUser.id) {
        await db.delete('users', existingUser.id);
      }
    } catch (e) {
      // If the approach doesn't work, proceed with tests as is
    }
  });

  afterAll(async () => {
    // Clean up test database
    const db = dbManager.getDatabase();
    if (testUserId) {
      try {
        if (db.delete && typeof db.delete === 'function') {
          await db.delete('users', testUserId);
        }
      } catch (e) {
        // Database might not support this operation in test mode
      }
    }
    if (db.close && typeof db.close === 'function') {
      await db.close();
    }
  });

  it('should create a new user successfully', async () => {
    const response = await app.request('/users', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: 'Integration Test User',
        email: 'integration-test-user@example.com',
        age: 30
      }),
    });

    expect(response.status).toBe(201);
    
    const responseBody = await response.json();
    expect(responseBody).toBeDefined();
    expect(responseBody.name).toBe('Integration Test User');
    expect(responseBody.email).toBe('integration-test-user@example.com');
    expect(responseBody.age).toBe(30);
    testUserId = responseBody.id;
  });

  it('should retrieve all users', async () => {
    const response = await app.request('/users', {
      method: 'GET',
    });

    expect(response.status).toBe(200);
    
    const responseBody = await response.json();
    expect(Array.isArray(responseBody)).toBe(true);
    expect(responseBody.length).toBeGreaterThan(0);
  });

  it('should retrieve user by ID', async () => {
    if (!testUserId) {
      throw new Error('Test user ID not set');
    }
    
    const response = await app.request(`/users/${testUserId}`, {
      method: 'GET',
    });

    expect(response.status).toBe(200);
    
    const responseBody = await response.json();
    expect(responseBody).toBeDefined();
    expect(responseBody.id).toBe(testUserId);
    expect(responseBody.name).toBe('Integration Test User');
    expect(responseBody.email).toBe('integration-test-user@example.com');
  });

  it('should return 404 when retrieving non-existent user', async () => {
    const response = await app.request('/users/999999', {
      method: 'GET',
    });

    expect(response.status).toBe(404);
    
    const responseBody = await response.json();
    expect(responseBody.error).toBe('User not found');
  });

  it('should update user successfully', async () => {
    if (!testUserId) {
      throw new Error('Test user ID not set');
    }
    
    const response = await app.request(`/users/${testUserId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: 'Updated Integration Test User',
        age: 31
      }),
    });

    expect(response.status).toBe(200);
    
    const responseBody = await response.json();
    expect(responseBody).toBeDefined();
    expect(responseBody.id).toBe(testUserId);
    expect(responseBody.name).toBe('Updated Integration Test User');
    expect(responseBody.age).toBe(31);
  });

  it('should return 404 when trying to update non-existent user', async () => {
    const response = await app.request('/users/999999', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: 'Some Updated Name'
      }),
    });

    expect(response.status).toBe(404);
    
    const responseBody = await response.json();
    expect(responseBody.error).toBe('User not found');
  });

  it('should delete user successfully', async () => {
    if (!testUserId) {
      throw new Error('Test user ID not set');
    }
    
    const response = await app.request(`/users/${testUserId}`, {
      method: 'DELETE',
    });

    expect(response.status).toBe(200);
    
    const responseBody = await response.json();
    expect(responseBody.message).toBe('User deleted successfully');
    expect(responseBody.user).toBeDefined();
    expect(responseBody.user.id).toBe(testUserId);
    
    testUserId = null; // Reset for next tests if needed
  });

  it('should return 404 when trying to delete non-existent user', async () => {
    const response = await app.request('/users/999999', {
      method: 'DELETE',
    });

    expect(response.status).toBe(404);
    
    const responseBody = await response.json();
    expect(responseBody.error).toBe('User not found');
  });

  it('should handle creating user with duplicate email', async () => {
    // Create a user first
    await app.request('/users', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: 'Duplicate Test User',
        email: 'duplicate@example.com',
        age: 25
      }),
    });

    // Try to create another user with same email
    const response = await app.request('/users', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: 'Another Duplicate User',
        email: 'duplicate@example.com', // Same email as above
        age: 30
      }),
    });

    expect(response.status).toBe(409);
    
    const responseBody = await response.json();
    expect(responseBody.error).toBe('User with this email already exists');
  });
});