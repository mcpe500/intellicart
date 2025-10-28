import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { Hono } from "hono";
import { ProductController } from "../../../src/controllers/ProductController";
import { dbManager } from "../../../src/database/Config";

const productController = new ProductController();

// Mock logger to avoid console output during tests
const mockedLogger = {
  info: () => {},
  warn: () => {},
  error: () => {},
};

// Create a test app with product routes
const app = new Hono();

// Simple mock for request validation and context
const mockValid = (data: any) => (source: string) => {
  if (source === "json") {
    return data;
  }
};

// Mock routes for testing
app.get("/products", (c) => productController.getAll(c));

app.get("/products/:id", (c) => {
  (c.req as any).param = (name: string) => {
    if (name === "id") return c.req.path.split("/").pop(); // Extract ID from path
  };
  return productController.getById(c);
});

app.post("/products", async (c) => {
  const body = await c.req.json();
  (c.req as any).valid = () => body;
  // Mock user context for seller ID
  (c as any).set = (key: string, value: any) => {
    (c as any)._context = (c as any)._context || {};
    (c as any)._context[key] = value;
  };
  (c as any).get = (key: string) => {
    return (c as any)._context?.[key];
  };
  // Set a mock user with ID 1
  (c as any).set("user", { userId: 1 });
  return productController.create(c, body);
});

app.put("/products/:id", async (c) => {
  const body = await c.req.json();
  (c.req as any).param = (name: string) => {
    if (name === "id") return c.req.path.split("/").pop(); // Extract ID from path
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
  (c as any).set("user", { userId: 1 });
  return productController.update(c, body);
});

app.delete("/products/:id", (c) => {
  (c.req as any).param = (name: string) => {
    if (name === "id") return c.req.path.split("/").pop(); // Extract ID from path
  };
  // Mock user context
  (c as any).set = (key: string, value: any) => {
    (c as any)._context = (c as any)._context || {};
    (c as any)._context[key] = value;
  };
  (c as any).get = (key: string) => {
    return (c as any)._context?.[key];
  };
  // Set a mock user with ID 1
  (c as any).set("user", { userId: 1 });
  return productController.delete(c);
});

app.get("/products/seller/:sellerId", (c) => {
  (c.req as any).param = (name: string) => {
    if (name === "sellerId") return c.req.path.split("/").pop(); // Extract seller ID from path
  };
  // Mock user context
  (c as any).set = (key: string, value: any) => {
    (c as any)._context = (c as any)._context || {};
    (c as any)._context[key] = value;
  };
  (c as any).get = (key: string) => {
    return (c as any)._context?.[key];
  };
  // Set a mock user with ID matching seller ID
  const sellerId = c.req.path.split("/").pop();
  (c as any).set("user", { userId: parseInt(sellerId || "1") });
  return productController.getSellerProducts(c);
});

describe("Product Integration Tests", () => {
  let testProductId: number | null = null;

  beforeAll(async () => {
    // Setup test database - using memory database for tests
    await dbManager.initialize();
  });

  afterAll(async () => {
    // Clean up test database
    const db = dbManager.getDatabase();
    if (testProductId) {
      try {
        if (db.delete && typeof db.delete === "function") {
          await db.delete("products", testProductId);
        }
      } catch (e) {
        // Database might not support this operation in test mode
      }
    }
    if (db.close && typeof db.close === "function") {
      await db.close();
    }
  });

  it("should create a new product successfully", async () => {
    const response = await app.request("/products", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        name: "Test Product",
        description: "Test Product Description",
        price: "19.99",
        imageUrl: "https://example.com/test-product.jpg",
      }),
    });

    expect(response.status).toBe(201);

    const responseBody: any = await response.json();
    expect(responseBody).toBeDefined();
    expect(responseBody.name).toBe("Test Product");
    expect(responseBody.description).toBe("Test Product Description");
    expect(responseBody.price).toBe("19.99");
    expect(responseBody.imageUrl).toBe("https://example.com/test-product.jpg");
    expect(responseBody.sellerId).toBe(1); // Mock user ID
    testProductId = responseBody.id;
  });

  it("should retrieve all products", async () => {
    const response = await app.request("/products", {
      method: "GET",
    });

    expect(response.status).toBe(200);

    const responseBody: any = await response.json();
    expect(Array.isArray(responseBody)).toBe(true);
    expect(responseBody.length).toBeGreaterThan(0);
  });

  it("should retrieve product by ID", async () => {
    if (!testProductId) {
      throw new Error("Test product ID not set");
    }

    const response = await app.request(`/products/${testProductId}`, {
      method: "GET",
    });

    expect(response.status).toBe(200);

    const responseBody: any = await response.json();
    expect(responseBody).toBeDefined();
    expect(responseBody.id).toBe(testProductId);
    expect(responseBody.name).toBe("Test Product");
  });

  it("should return 404 when retrieving non-existent product", async () => {
    const response = await app.request("/products/999999", {
      method: "GET",
    });

    expect(response.status).toBe(404);

    const responseBody: any = await response.json();
    expect(responseBody.error).toBe("Product not found");
  });

  it("should update product successfully", async () => {
    if (!testProductId) {
      throw new Error("Test product ID not set");
    }

    const response = await app.request(`/products/${testProductId}`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        name: "Updated Test Product",
        price: "29.99",
      }),
    });

    expect(response.status).toBe(200);

    const responseBody: any = await response.json();
    expect(responseBody).toBeDefined();
    expect(responseBody.id).toBe(testProductId);
    expect(responseBody.name).toBe("Updated Test Product");
    expect(responseBody.price).toBe("29.99");
  });

  it("should return 404 when trying to update non-existent product", async () => {
    const response = await app.request("/products/999999", {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        name: "Some Updated Product",
      }),
    });

    expect(response.status).toBe(404);

    const responseBody: any = await response.json();
    expect(responseBody.error).toBe("Product not found");
  });

  it("should retrieve products by seller ID", async () => {
    const response = await app.request("/products/seller/1", {
      method: "GET",
    });

    expect(response.status).toBe(200);

    const responseBody: any = await response.json();
    expect(Array.isArray(responseBody)).toBe(true);
  });

  it("should delete product successfully", async () => {
    if (!testProductId) {
      throw new Error("Test product ID not set");
    }

    const response = await app.request(`/products/${testProductId}`, {
      method: "DELETE",
    });

    expect(response.status).toBe(200);

    const responseBody: any = await response.json();
    expect(responseBody.message).toBe("Product deleted successfully");
    expect(responseBody.product).toBeDefined();
    expect(responseBody.product.id).toBe(testProductId);

    testProductId = null; // Reset for next tests if needed
  });

  it("should return 404 when trying to delete non-existent product", async () => {
    const response = await app.request("/products/999999", {
      method: "DELETE",
    });

    expect(response.status).toBe(404);

    const responseBody: any = await response.json();
    expect(responseBody.error).toBe("Product not found");
  });
});
