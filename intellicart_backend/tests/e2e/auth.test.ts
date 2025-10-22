import { describe, it, expect, beforeEach, vi } from 'bun:test';
import app from '../../src/index';
import { setupE2ETestDb, resetTestDb } from './setup';
import { db, initializeDb } from '../../src/database/db_service';

// IMPORTANT: Set environment for testing - specifically DATABASE_MODE
process.env.DATABASE_MODE = 'json'; // Force JSON mode for these E2E tests
process.env.JWT_SECRET = 'e2e-test-secret-shhhh'; // Use a consistent secret for E2E tests

describe('E2E - Auth API', () => {
    beforeEach(async () => {
        // Reset the database state before each test
        await setupE2ETestDb();
        // Ensure db service is initialized *after* potential file copy
        await initializeDb();
    });

    it('POST /api/auth/register - should register a new user successfully', async () => {
        const newUser = {
            name: 'E2E Test User',
            email: `e2e-${Date.now()}@test.com`, // Unique email
            password: 'password123',
            role: 'buyer'
        };

        const req = new Request('http://localhost/api/auth/register', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(newUser)
        });

        const res = await app.request(req);
        expect(res.status).toBe(201);

        const body = await res.json();
        expect(body).toHaveProperty('token');
        expect(body.user.name).toBe(newUser.name);
        expect(body.user.email).toBe(newUser.email);
        expect(body.user.role).toBe(newUser.role);
        expect(body.user.id).toBeString();

        // Verify in DB (optional, but good for E2E)
        const dbUser = await db().getUserByEmail(newUser.email);
        expect(dbUser).not.toBeNull();
        expect(dbUser?.name).toBe(newUser.name);
    });

    it('POST /api/auth/register - should return 409 if email already exists', async () => {
         // First, register a user
         const existingUser = {
            name: 'Existing E2E User',
            email: `existing-e2e-${Date.now()}@test.com`,
            password: 'password123',
         };
         await db().createUser({ ...existingUser, password: existingUser.password, role: 'buyer' });

        // Attempt to register again with the same email
        const req = new Request('http://localhost/api/auth/register', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ ...existingUser, name: "Another Name" }) // Same email
        });

        const res = await app.request(req);
        expect(res.status).toBe(409);
        const body = await res.json();
        expect(body.error).toBe('User with this email already exists');
    });

    it('POST /api/auth/register - should return 400 for invalid data', async () => {
          const invalidData = { email: 'invalid-email', password: 'sh' }; // Missing name, invalid email, short password
          const req = new Request('http://localhost/api/auth/register', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(invalidData)
          });
          const res = await app.request(req);
          expect(res.status).toBe(400); // Zod validation should fail
          
          // The exact error message depends on Hono's Zod validation middleware
          const body = await res.json();
          expect(body).toHaveProperty('error');
    });

    it('POST /api/auth/login - should login successfully with correct credentials', async () => {
         // Setup: Create a user directly in the DB for this test
         const userCreds = {
             email: `login-e2e-${Date.now()}@test.com`,
             password: 'loginPassword!',
             name: 'Login User',
             role: 'seller'
         };
         await db().createUser({
             ...userCreds,
             password: userCreds.password
         });

        const req = new Request('http://localhost/api/auth/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email: userCreds.email, password: userCreds.password })
        });

        const res = await app.request(req);
        expect(res.status).toBe(200);
        const body = await res.json();
        expect(body).toHaveProperty('token');
        expect(body.user.email).toBe(userCreds.email);
        expect(body.user.role).toBe(userCreds.role);
    });

    it('POST /api/auth/login - should return 401 for incorrect password', async () => {
         // Setup user
         const userCreds = { 
             email: `login-fail-${Date.now()}@test.com`, 
             password: 'correctPassword', 
             name: 'Fail User', 
             role: 'buyer'
         };
         await db().createUser({ 
             ...userCreds, 
             password: userCreds.password 
         });

        const req = new Request('http://localhost/api/auth/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email: userCreds.email, password: 'wrongPassword' })
        });
        const res = await app.request(req);
        expect(res.status).toBe(401);
        const body = await res.json();
        expect(body.error).toBe('Invalid email or password');
    });

    it('POST /api/auth/login - should return 401 for non-existent email', async () => {
        const req = new Request('http://localhost/api/auth/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email: 'nosuchuser@example.com', password: 'password123' })
        });
        const res = await app.request(req);
        expect(res.status).toBe(401);
        const body = await res.json();
        expect(body.error).toBe('Invalid email or password');
    });

    it('GET /api/auth/profile - should return profile for authenticated user', async () => {
          // Setup user and get token
          const userCreds = { 
              email: `profile-e2e-${Date.now()}@test.com`, 
              password: 'profilePass', 
              name: 'Profile User', 
              role: 'buyer'
          };
          const createdUser = await db().createUser({ 
              ...userCreds, 
              password: userCreds.password 
          });
          
          const loginRes = await app.request('http://localhost/api/auth/login', {
              method: 'POST', 
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ email: userCreds.email, password: userCreds.password })
          });
          
          const { token } = await loginRes.json();
          expect(token).toBeString();

          // Request profile with token
          const req = new Request('http://localhost/api/auth/profile', {
              headers: { 'Authorization': `Bearer ${token}` }
          });
          const res = await app.request(req);

          expect(res.status).toBe(200);
          const body = await res.json();
          expect(body.id).toBe(createdUser.id);
          expect(body.email).toBe(userCreds.email);
          expect(body.name).toBe(userCreds.name);
          expect(body.role).toBe(userCreds.role);
    });

    it('GET /api/auth/profile - should return 401 for missing/invalid token', async () => {
           // No token
           const reqNoToken = new Request('http://localhost/api/auth/profile');
           const resNoToken = await app.request(reqNoToken);
           expect(resNoToken.status).toBe(401);

            // Invalid token
           const reqInvalidToken = new Request('http://localhost/api/auth/profile', {
               headers: { 'Authorization': 'Bearer invalid.token.here' }
           });
           const resInvalidToken = await app.request(reqInvalidToken);
           expect(resInvalidToken.status).toBe(401);
    });
});