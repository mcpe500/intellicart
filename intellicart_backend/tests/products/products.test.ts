/**
 * Products API Test Suite
 *
 * This test file covers all the products API endpoints:
 * - GET /api/products/
 * - POST /api/products/
 * - GET /api/products/{id}
 * - PUT /api/products/{id}
 * - DELETE /api/products/{id}
 * - POST /api/products/{id}/reviews
 *
 * To run: bun test tests/products/products.test.ts
 */

import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { Hono } from "hono";
import { AuthController } from "../../src/controllers/authController";
import { ProductController } from "../../src/controllers/ProductController";
import { dbManager } from "../../src/database/Config";

const productController = new ProductController();

// Create a test app with products routes
const app = new Hono();

// Mock the authentication and user context for product operations
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

// Mock the product routes
app.get("/api/products", (c) => {
  (c as any).set = (key: string, value: any) => {
    (c as any)._context = (c as any)._context || {};
    (c as any)._context[key] = value;
  };
  (c as any).get = (key: string) => {
    return (c as any)._context?.[key];
  };
  (c as any).set("user", { userId: 1 });
  return productController.getAll(c);
});
app.get("/api/products/:id", (c) => {
  (c.req as any).param = (name: string) => {
    if (name === "id") return c.req.path.split("/")[3];
  };
  return productController.getById(c);
});
app.post("/api/products", async (c) => {
  const body = await c.req.json();
  (c.req as any).valid = () => body;
  (c as any).set = (key: string, value: any) => {
    (c as any)._context = (c as any)._context || {};
    (c as any)._context[key] = value;
  };
  (c as any).get = (key: string) => {
    return (c as any)._context?.[key];
  };
  (c as any).set("user", { userId: 1 });
  return productController.create(c, body);
});
app.put("/api/products/:id", async (c) => {
  const body = await c.req.json();
  (c.req as any).param = (name: string) => {
    if (name === "id") return c.req.path.split("/")[3];
  };
  (c.req as any).valid = () => body;
  (c as any).set = (key: string, value: any) => {
    (c as any)._context = (c as any)._context || {};
    (c as any)._context[key] = value;
  };
  (c as any).get = (key: string) => {
    return (c as any)._context?.[key];
  };
  (c as any).set("user", { userId: 1 });
  return productController.update(c, body);
});
app.delete("/api/products/:id", (c) => {
  (c.req as any).param = (name: string) => {
    if (name === "id") return c.req.path.split("/")[3];
  };
  (c as any).set = (key: string, value: any) => {
    (c as any)._context = (c as any)._context || {};
    (c as any)._context[key] = value;
  };
  (c as any).get = (key: string) => {
    return (c as any)._context?.[key];
  };
  (c as any).set("user", { userId: 1 });
  return productController.delete(c);
});
app.post("/api/products/:id/reviews", async (c) => {
  const body = await c.req.json();
  (c.req as any).param = (name: string) => {
    if (name === "id") return c.req.path.split("/")[3];
  };
  (c.req as any).valid = () => body;
  (c as any).set = (key: string, value: any) => {
    (c as any)._context = (c as any)._context || {};
    (c as any)._context[key] = value;
  };
  (c as any).get = (key: string) => {
    return (c as any)._context?.[key];
  };
  (c as any).set("user", { userId: 1 });
  return ProductController.addReviewToProduct(
    c,
    Number(c.req.param("id")),
    body,
  );
});

describe("Products API Tests", () => {
  let userToken: string | null = null;
  let userId: number | null = null;
  let testProductId: number | null = null;
  let testReviewId: number | null = null;

  beforeAll(async () => {
    // Setup test database
    await dbManager.initialize();
  });

  afterAll(async () => {
    // Clean up test database
    const db = dbManager.getDatabase();
    try {
      if (userId) {
        await db.delete("users", userId);
      }
      if (testProductId) {
        await db.delete("products", testProductId);
      }
    } catch (e) {
      // Database might not support this operation in test mode
    }

    if (db.close && typeof db.close === "function") {
      await db.close();
    }
  });

  it("should create a new user for testing", async () => {
    const response = await app.request("/api/auth/register", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: "product-test@example.com",
        password: "password123",
        name: "Product Test User",
        role: "seller",
      }),
    });

    expect(response.status).toBe(201);
    const responseBody: any = await response.json();
    expect(responseBody.user).toBeDefined();
    expect(responseBody.token).toBeDefined();
    userToken = responseBody.token;
    userId = responseBody.user.id;
  });

  it("should create a new product successfully", async () => {
    const response = await app.request("/api/products", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${userToken}`,
      },
      body: JSON.stringify({
        name: "Test Product",
        description: "This is a test product",
        price: "29.99",
        originalPrice: "39.99",
        imageUrl: "https://example.com/test-product.jpg",
      }),
    });

    expect(response.status).toBe(201);

    const responseBody: any = await response.json();
    expect(responseBody).toBeDefined();
    expect(responseBody.name).toBe("Test Product");
    expect(responseBody.description).toBe("This is a test product");
    expect(responseBody.price).toBe("29.99");
    expect(responseBody.originalPrice).toBe("39.99");
    expect(responseBody.imageUrl).toBe("https://example.com/test-product.jpg");
    expect(responseBody.sellerId).toBe(1); // Mocked user ID
    expect(responseBody.reviews).toEqual([]);
    expect(responseBody.createdAt).toBeDefined();

    testProductId = responseBody.id;
  });

  it("should retrieve all products successfully", async () => {
    const response = await app.request("/api/products", {
      method: "GET",
    });

    expect(response.status).toBe(200);

    const responseBody: any = await response.json();
    expect(Array.isArray(responseBody)).toBe(true);
    expect(responseBody.length).toBeGreaterThan(0);

    // Check that the test product is in the list
    const createdProduct = responseBody.find(
      (p: any) => p.id === testProductId,
    );
    expect(createdProduct).toBeDefined();
    expect(createdProduct.name).toBe("Test Product");
  });

  it("should retrieve a specific product by ID successfully", async () => {
    if (!testProductId) {
      throw new Error("Test product ID not set");
    }

    const response = await app.request(`/api/products/${testProductId}`, {
      method: "GET",
    });

    expect(response.status).toBe(200);

    const responseBody: any = await response.json();
    expect(responseBody).toBeDefined();
    expect(responseBody.id).toBe(testProductId);
    expect(responseBody.name).toBe("Test Product");
    expect(responseBody.description).toBe("This is a test product");
    expect(responseBody.price).toBe("29.99");
    expect(responseBody.sellerId).toBe(1);
  });

  it("should return 404 when retrieving non-existent product", async () => {
    const response = await app.request("/api/products/999999", {
      method: "GET",
    });

    expect(response.status).toBe(404);

    const responseBody: any = await response.json();
    expect(responseBody.error).toBe("Product not found");
  });

  it("should update an existing product successfully", async () => {
    if (!testProductId) {
      throw new Error("Test product ID not set");
    }

    const response = await app.request(`/api/products/${testProductId}`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${userToken}`,
      },
      body: JSON.stringify({
        name: "Updated Test Product",
        description: "This is an updated test product",
        price: "39.99",
        originalPrice: "49.99",
      }),
    });

    expect(response.status).toBe(200);

    const responseBody: any = await response.json();
    expect(responseBody).toBeDefined();
    expect(responseBody.id).toBe(testProductId);
    expect(responseBody.name).toBe("Updated Test Product");
    expect(responseBody.description).toBe("This is an updated test product");
    expect(responseBody.price).toBe("39.99");
    expect(responseBody.originalPrice).toBe("49.99");
  });

  it("should return 404 when trying to update non-existent product", async () => {
    const response = await app.request("/api/products/999999", {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${userToken}`,
      },
      body: JSON.stringify({
        name: "Non-existent Product",
        description: "Trying to update a non-existent product",
      }),
    });

    expect(response.status).toBe(404);

    const responseBody: any = await response.json();
    expect(responseBody.error).toBe("Product not found");
  });

  it("should add a review to the product successfully", async () => {
    if (!testProductId) {
      throw new Error("Test product ID not set");
    }

    const response = await app.request(
      `/api/products/${testProductId}/reviews`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${userToken}`,
        },
        body: JSON.stringify({
          title: "Great Product!",
          text: "This product is amazing and works perfectly",
          rating: 5,
        }),
      },
    );

    expect(response.status).toBe(200);

    const responseBody: any = await response.json();
    expect(responseBody).toBeDefined();
    expect(responseBody.id).toBe(testProductId);
    expect(responseBody.reviews).toBeDefined();
    expect(Array.isArray(responseBody.reviews)).toBe(true);
    expect(responseBody.reviews.length).toBe(1);

    const review = responseBody.reviews[0];
    expect(review.title).toBe("Great Product!");
    expect(review.text).toBe("This product is amazing and works perfectly");
    expect(review.rating).toBe(5);

    // Check that other product properties remain unchanged
    expect(responseBody.name).toBe("Updated Test Product");
    expect(responseBody.price).toBe("39.99");
  });

  it("should return 404 when trying to add review to non-existent product", async () => {
    const response = await app.request("/api/products/999999/reviews", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${userToken}`,
      },
      body: JSON.stringify({
        title: "Review for non-existent product",
        text: "This product does not exist",
        rating: 3,
      }),
    });

    expect(response.status).toBe(404);

    const responseBody: any = await response.json();
    expect(responseBody.error).toBe("Product not found");
  });

  it("should delete the product successfully", async () => {
    if (!testProductId) {
      throw new Error("Test product ID not set");
    }

    const response = await app.request(`/api/products/${testProductId}`, {
      method: "DELETE",
      headers: {
        Authorization: `Bearer ${userToken}`,
      },
    });

    expect(response.status).toBe(200);

    const responseBody: any = await response.json();
    expect(responseBody).toBeDefined();
    expect(responseBody.message).toBe("Product deleted successfully");
    expect(responseBody.product).toBeDefined();
    expect(responseBody.product.id).toBe(testProductId);
  });

  it("should return 404 when trying to retrieve the deleted product", async () => {
    if (!testProductId) {
      throw new Error("Test product ID not set");
    }

    const response = await app.request(`/api/products/${testProductId}`, {
      method: "GET",
    });

    expect(response.status).toBe(404);

    const responseBody: any = await response.json();
    expect(responseBody.error).toBe("Product not found");
  });

  it("should return 404 when trying to delete non-existent product", async () => {
    const response = await app.request("/api/products/999999", {
      method: "DELETE",
      headers: {
        Authorization: `Bearer ${userToken}`,
      },
    });

    expect(response.status).toBe(404);

    const responseBody: any = await response.json();
    expect(responseBody.error).toBe("Product not found");
  });
});
