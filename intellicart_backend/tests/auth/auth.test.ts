/**
 * Authentication API Test - Login and Register Functionality
 *
 * This test file focuses specifically on testing the authentication endpoints:
 * - Register (POST /api/auth/register)
 * - Login (POST /api/auth/login)
 *
 * To run: bun test tests/auth/auth.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { Hono } from "hono";
import { AuthController } from "../../src/controllers/authController";
import { dbManager } from "../../src/database/Config";

// Create a test app with just the auth routes we need to test
const app = new Hono();

// Mock the request validation and context for the auth controllers
app.post("/api/auth/register", async (c) => {
  const body = await c.req.json();
  (c.req as any).valid = () => body;
  return AuthController.register(c);
});

app.post("/api/auth/login", async (c) => {
  const body = await c.req.json();
  (c.req as any).valid = () => body;
  return AuthController.login(c);
});

describe("Auth - Register and Login Tests", () => {
  const testEmail = "auth-test@example.com";
  const testPassword = "password123";
  const testName = "Auth Test User";

  let registeredUserId: number | null = null;

  beforeAll(async () => {
    // Initialize the database
    await dbManager.initialize();
  });

  afterAll(async () => {
    // Clean up: Delete the test user if it was created
    if (registeredUserId) {
      try {
        const db = dbManager.getDatabase();
        await db.delete("users", registeredUserId);
      } catch (e) {
        // Ignore cleanup errors in test environment
      }
    }

    // Close the database connection
    const db = dbManager.getDatabase();
    if (db.close) {
      await db.close();
    }
  });

  it("should register a new user successfully", async () => {
    const response = await app.request("/api/auth/register", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: testEmail,
        password: testPassword,
        name: testName,
        role: "buyer",
      }),
    });

    expect(response.status).toBe(201);

    const responseBody: any = await response.json();
    expect(responseBody.user).toBeDefined();
    expect(responseBody.user.email).toBe(testEmail);
    expect(responseBody.user.name).toBe(testName);
    expect(responseBody.user.role).toBe("buyer");
    expect(responseBody.token).toBeDefined();
    expect(responseBody.token).toBeString();

    registeredUserId = responseBody.user.id;
    expect(registeredUserId).toBeNumber();
  });

  it("should login with the registered user successfully", async () => {
    const response = await app.request("/api/auth/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: testEmail,
        password: testPassword,
      }),
    });

    expect(response.status).toBe(200);

    const responseBody: any = await response.json();
    expect(responseBody.user).toBeDefined();
    expect(responseBody.user.email).toBe(testEmail);
    expect(responseBody.token).toBeDefined();
    expect(responseBody.token).toBeString();
  });

  it("should fail to login with wrong password", async () => {
    const response = await app.request("/api/auth/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: testEmail,
        password: "wrongpassword",
      }),
    });

    expect(response.status).toBe(401);

    const responseBody: any = await response.json();
    expect(responseBody.error).toBe("Invalid email or password");
  });

  it("should fail to login with non-existent email", async () => {
    const response = await app.request("/api/auth/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: "nonexistent@example.com",
        password: testPassword,
      }),
    });

    expect(response.status).toBe(401);

    const responseBody: any = await response.json();
    expect(responseBody.error).toBe("Invalid email or password");
  });

  it("should return 409 when trying to register with existing email", async () => {
    const response = await app.request("/api/auth/register", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: testEmail,
        password: testPassword,
        name: "Another Test User",
        role: "buyer",
      }),
    });

    expect(response.status).toBe(409);

    const responseBody: any = await response.json();
    expect(responseBody.error).toBe("User with this email already exists");
  });

  it("should register user with default role when no role is provided", async () => {
    const tempEmail = "temp-user@example.com";

    const response = await app.request("/api/auth/register", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: tempEmail,
        password: testPassword,
        name: "Temp User",
        // No role provided - should default to 'buyer'
      }),
    });

    expect(response.status).toBe(201);

    const responseBody: any = await response.json();
    expect(responseBody.user).toBeDefined();
    expect(responseBody.user.email).toBe(tempEmail);
    expect(responseBody.user.role).toBe("buyer");
    expect(responseBody.token).toBeDefined();

    // Clean up by deleting the temporary user
    try {
      const db = dbManager.getDatabase();
      await db.delete("users", responseBody.user.id);
    } catch (e) {
      // Ignore cleanup errors
    }
  });
});
