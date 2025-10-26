import { describe, it, expect } from 'bun:test';
import { Hono } from 'hono';
import { AuthController } from '../../../src/controllers/authController';
import { UserController } from '../../../src/controllers/UserController';
import { dbManager } from '../../../src/database/Config';

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
app.put('/api/users/:id', async (c) => {
  const body = await c.req.json();
  (c.req as any).param = (name: string) => {
    if (name === 'id') return c.req.path.split('/')[3];
  };
  (c.req as any).valid = () => body;
  return UserController.updateUser(c);
});
app.delete('/api/users/:id', (c) => {
  (c.req as any).param = (name: string) => {
    if (name === 'id') return c.req.path.split('/')[3];
  };
  return UserController.deleteUser(c);
});

describe('Complete User Management Flow E2E Tests', () => {
  let userToken: string | null = null;
  let userId: number | null = null;
  let createdUserId: number | null = null;

  beforeAll(async () => {
    // Setup test database
    await dbManager.init();
  });

  afterAll(async () => {
    // Clean up test database
    const db = dbManager.getDatabase();
    try {
      if (userId) {
        await db.delete('users', userId);
      }
      if (createdUserId) {
        await db.delete('users', createdUserId);
      }
    } catch (e) {
      // Database might not support this operation in test mode
    }

    if (db.close && typeof db.close === 'function') {
      await db.close();
    }
  });

  it('should complete the full user management flow: create -> get all -> get by id -> update -> delete', async () => {
    // First, register and login to get a token (to simulate that we're authenticated)
    const registerResponse = await app.request('/api/auth/register', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'user-mgmt-test@example.com',
        password: 'password123',
        name: 'User Mgmt Test',
        role: 'admin'
      }),
    });

    expect(registerResponse.status).toBe(201);
    const registerBody = await registerResponse.json();
    expect(registerBody.token).toBeDefined();
    userToken = registerBody.token;
    userId = registerBody.user.id;

    // Step 1: Create a new user via API
    const createUserResponse = await app.request('/api/users', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: 'E2E Created User',
        email: 'e2e-created@example.com',
        age: 25
      }),
    });

    expect(createUserResponse.status).toBe(201);
    const createUserBody = await createUserResponse.json();
    expect(createUserBody).toBeDefined();
    expect(createUserBody.name).toBe('E2E Created User');
    expect(createUserBody.email).toBe('e2e-created@example.com');
    expect(createUserBody.age).toBe(25);
    createdUserId = createUserBody.id;

    // Step 2: Get all users
    const getAllResponse = await app.request('/api/users', {
      method: 'GET',
    });

    expect(getAllResponse.status).toBe(200);
    const getAllBody = await getAllResponse.json();
    expect(Array.isArray(getAllBody)).toBe(true);
    expect(getAllBody.length).toBeGreaterThan(0);

    // Step 3: Get the specific user by ID
    const getOneResponse = await app.request(`/api/users/${createdUserId}`, {
      method: 'GET',
    });

    expect(getOneResponse.status).toBe(200);
    const getOneBody = await getOneResponse.json();
    expect(getOneBody).toBeDefined();
    expect(getOneBody.id).toBe(createdUserId);
    expect(getOneBody.name).toBe('E2E Created User');
    expect(getOneBody.email).toBe('e2e-created@example.com');

    // Step 4: Update the user
    const updateResponse = await app.request(`/api/users/${createdUserId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: 'Updated E2E Created User',
        age: 26
      }),
    });

    expect(updateResponse.status).toBe(200);
    const updateBody = await updateResponse.json();
    expect(updateBody).toBeDefined();
    expect(updateBody.id).toBe(createdUserId);
    expect(updateBody.name).toBe('Updated E2E Created User');
    expect(updateBody.age).toBe(26);
    expect(updateBody.email).toBe('e2e-created@example.com'); // Email should remain unchanged

    // Step 5: Delete the user
    const deleteResponse = await app.request(`/api/users/${createdUserId}`, {
      method: 'DELETE',
    });

    expect(deleteResponse.status).toBe(200);
    const deleteBody = await deleteResponse.json();
    expect(deleteBody.message).toBe('User deleted successfully');
    expect(deleteBody.user).toBeDefined();
    expect(deleteBody.user.id).toBe(createdUserId);

    // Verify the user is deleted by trying to get it again
    const verifyDeleteResponse = await app.request(`/api/users/${createdUserId}`, {
      method: 'GET',
    });

    expect(verifyDeleteResponse.status).toBe(404);
  });

  it('should handle creating user with duplicate email', async () => {
    // Create a user first
    const firstUserResponse = await app.request('/api/users', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: 'First User',
        email: 'duplicate-check@example.com',
        age: 30
      }),
    });

    expect(firstUserResponse.status).toBe(201);
    const firstUserBody = await firstUserResponse.json();
    expect(firstUserBody).toBeDefined();
    const duplicateUserId = firstUserBody.id;

    // Try to create another user with same email
    const duplicateUserResponse = await app.request('/api/users', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: 'Duplicate User',
        email: 'duplicate-check@example.com', // Same email
        age: 25
      }),
    });

    expect(duplicateUserResponse.status).toBe(409);
    const duplicateUserBody = await duplicateUserResponse.json();
    expect(duplicateUserBody.error).toBe('User with this email already exists');

    // Clean up: delete the first user
    if (duplicateUserId) {
      const deleteResponse = await app.request(`/api/users/${duplicateUserId}`, {
        method: 'DELETE',
      });
      expect(deleteResponse.status).toBe(200);
    }
  });

  it('should return 404 when trying to get non-existent user', async () => {
    const response = await app.request('/api/users/999999', {
      method: 'GET',
    });

    expect(response.status).toBe(404);
    const body = await response.json();
    expect(body.error).toBe('User not found');
  });

  it('should return 404 when trying to update non-existent user', async () => {
    const response = await app.request('/api/users/999999', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: 'Trying to update non-existent user'
      }),
    });

    expect(response.status).toBe(404);
    const body = await response.json();
    expect(body.error).toBe('User not found');
  });

  it('should return 404 when trying to delete non-existent user', async () => {
    const response = await app.request('/api/users/999999', {
      method: 'DELETE',
    });

    expect(response.status).toBe(404);
    const body = await response.json();
    expect(body.error).toBe('User not found');
  });
});