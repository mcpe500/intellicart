import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { Hono } from "hono";
import { AuthController } from "../../../src/controllers/authController";
import { UserController } from "../../../src/controllers/UserController";
import { dbManager } from "../../../src/database/Config";

// Create a test app with auth routes
const app = new Hono();

// Simple mock for request validation
const mockValid = (data: any) => (source: string) => {
  if (source === "json") {
    return data;
  }
};

// Mock routes for testing
app.post("/register", async (c) => {
  const body = await c.req.json();
  (c.req as any).valid = () => body;
  return AuthController.register(c);
});

app.post("/login", async (c) => {
  const body = await c.req.json();
  (c.req as any).valid = () => body;
  return AuthController.login(c);
});

app.get("/me", (c) => {
  return AuthController.getCurrentUser(c);
});

app.post("/logout", (c) => {
  return AuthController.logout(c);
});

app.post("/verify", (c) => {
  return AuthController.verifyToken(c);
});

describe("Auth Integration Tests", () => {
  beforeAll(async () => {
    // Setup test database - using memory database for tests
    await dbManager.initialize();

    // Clean up any existing test users before running tests
    const db = dbManager.getDatabase();
    if (
      db.findAll &&
      typeof db.findAll === "function" &&
      db.delete &&
      typeof db.delete === "function"
    ) {
      try {
        const allUsers: any[] = await db.findAll("users");
        const testUsers = allUsers.filter(
          (user: any) =>
            user.email === "integration-test-unique@example.com" ||
            user.email === "integration-test2-unique@example.com",
        );

        for (const user of testUsers) {
          if (user.id) {
            await db.delete("users", user.id);
          }
        }
      } catch (e) {
        // If the approach doesn't work, proceed with tests as is
      }
    }
  });

  afterAll(async () => {
    // Clean up test database
    const db = dbManager.getDatabase();
    if (
      db.findOne &&
      typeof db.findOne === "function" &&
      db.delete &&
      typeof db.delete === "function"
    ) {
      try {
        // Find and delete first test user
        const firstUser: any = await db.findOne("users", {
          email: "integration-test-unique@example.com",
        });
        if (firstUser && firstUser.id) {
          await db.delete("users", firstUser.id);
        }

        // Find and delete second test user
        const secondUser: any = await db.findOne("users", {
          email: "integration-test2-unique@example.com",
        });
        if (secondUser && secondUser.id) {
          await db.delete("users", secondUser.id);
        }
      } catch (e) {
        // Database might not support this operation in test mode
      }
    }
    if (db.close && typeof db.close === "function") {
      await db.close();
    }
  });

  it("should register a new user successfully", async () => {
    const response = await app.request("/register", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: "integration-test-unique@example.com",
        password: "password123",
        name: "Integration Test User",
        role: "buyer",
      }),
    });

    expect(response.status).toBe(201);

    const responseBody: any = await response.json();
    expect(responseBody.user).toBeDefined();
    expect(responseBody.user.email).toBe("integration-test-unique@example.com");
    expect(responseBody.user.name).toBe("Integration Test User");
    expect(responseBody.token).toBeDefined();
  });

  it("should login user with correct credentials", async () => {
    const response = await app.request("/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: "integration-test-unique@example.com",
        password: "password123",
      }),
    });

    expect(response.status).toBe(200);

    const responseBody: any = await response.json();
    expect(responseBody.user).toBeDefined();
    expect(responseBody.user.email).toBe("integration-test-unique@example.com");
    expect(responseBody.token).toBeDefined();
  });

  it("should fail login with incorrect credentials", async () => {
    const response = await app.request("/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: "integration-test-unique@example.com",
        password: "wrongpassword",
      }),
    });

    expect(response.status).toBe(401);

    const responseBody: any = await response.json();
    expect(responseBody.error).toBe("Invalid email or password");
  });

  it("should return error for invalid token verification", async () => {
    const response = await app.request("/verify", {
      method: "POST",
      headers: {
        Authorization: `Bearer invalidtoken`,
      },
    });

    expect(response.status).toBe(401); // Invalid token should return 401

    const responseBody: any = await response.json();
    expect(responseBody.valid).toBe(false);
  });

  it("should return error for missing token verification", async () => {
    const response = await app.request("/verify", {
      method: "POST",
    });

    expect(response.status).toBe(400); // Missing token should return 400

    const responseBody: any = await response.json();
    expect(responseBody.valid).toBe(false);
  });

  it("should register user with default role when no role provided", async () => {
    const response = await app.request("/register", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: "integration-test2-unique@example.com",
        password: "password123",
        name: "Integration Test User 2",
        // no role provided, should default to 'buyer'
      }),
    });

    expect(response.status).toBe(201);

    const responseBody: any = await response.json();
    expect(responseBody.user).toBeDefined();
    expect(responseBody.user.name).toBe("Integration Test User 2");
    expect(responseBody.user.role).toBe("buyer");
  });

  it("should handle registration when user already exists", async () => {
    const response = await app.request("/register", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: "integration-test-unique@example.com", // already exists from previous test
        password: "password123",
        name: "Another User",
      }),
    });

    expect(response.status).toBe(409);

    const responseBody: any = await response.json();
    expect(responseBody.error).toBe("User with this email already exists");
  });
});
