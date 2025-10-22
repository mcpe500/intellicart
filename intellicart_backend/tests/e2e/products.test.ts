import { describe, it, expect, beforeEach } from 'bun:test';
import app from '../../src/index';
import { setupE2ETestDb, resetTestDb } from './setup';
import { db, initializeDb } from '../../src/database/db_service';
import { sign } from 'hono/jwt';

// IMPORTANT: Set environment for testing - specifically DATABASE_MODE
process.env.DATABASE_MODE = 'json'; // Force JSON mode for these E2E tests
process.env.JWT_SECRET = 'e2e-test-secret-shhhh'; // Use a consistent secret for E2E tests

describe('E2E - Products API', () => {
    let sellerToken: string;
    let buyerToken: string;
    let sellerId: string;
    let buyerId: string;

    beforeEach(async () => {
        // Reset the database state before each test
        await setupE2ETestDb();
        // Ensure db service is initialized *after* potential file copy
        await initializeDb();

        // Create test users and get their tokens
        const seller = await db().createUser({
            name: 'Test Seller',
            email: `seller-${Date.now()}@test.com`,
            password: 'password123',
            role: 'seller'
        });
        
        const buyer = await db().createUser({
            name: 'Test Buyer',
            email: `buyer-${Date.now()}@test.com`,
            password: 'password123',
            role: 'buyer'
        });

        sellerId = seller.id;
        buyerId = buyer.id;

        sellerToken = await sign(
            { id: seller.id, email: seller.email, role: seller.role },
            process.env.JWT_SECRET!
        );
        
        buyerToken = await sign(
            { id: buyer.id, email: buyer.email, role: buyer.role },
            process.env.JWT_SECRET!
        );
    });

    it('GET /api/products - should return all products', async () => {
        const req = new Request('http://localhost/api/products');
        const res = await app.request(req);
        expect(res.status).toBe(200);
        
        const body = await res.json();
        expect(Array.isArray(body)).toBe(true);
        expect(body.length).toBeGreaterThan(0); // Should have initial products
    });

    it('GET /api/products/:id - should return a specific product', async () => {
        // Get an existing product ID
        const products = await db().getAllProducts();
        const productId = products[0]?.id;
        
        const req = new Request(`http://localhost/api/products/${productId}`);
        const res = await app.request(req);
        expect(res.status).toBe(200);
        
        const body = await res.json();
        expect(body.id).toBe(productId);
        expect(body).toHaveProperty('name');
        expect(body).toHaveProperty('price');
        expect(body).toHaveProperty('sellerId');
    });

    it('GET /api/products/:id - should return 404 for non-existent product', async () => {
        const req = new Request('http://localhost/api/products/non-existent-id');
        const res = await app.request(req);
        expect(res.status).toBe(404);
        
        const body = await res.json();
        expect(body.error).toBe('Product not found');
    });

    it('POST /api/products - should create a new product when authenticated as seller', async () => {
        const newProduct = {
            name: 'New Test Product',
            description: 'A new product for testing',
            price: 29.99,
            imageUrl: 'http://example.com/test-image.jpg'
        };

        const req = new Request('http://localhost/api/products', {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${sellerToken}`
            },
            body: JSON.stringify(newProduct)
        });

        const res = await app.request(req);
        expect(res.status).toBe(201);
        
        const body = await res.json();
        expect(body.id).toBeString();
        expect(body.name).toBe(newProduct.name);
        expect(body.description).toBe(newProduct.description);
        expect(body.price).toBe(newProduct.price);
        expect(body.sellerId).toBe(sellerId);
        expect(Array.isArray(body.reviews)).toBe(true);
    });

    it('POST /api/products - should return 401 for unauthenticated requests', async () => {
        const newProduct = {
            name: 'New Test Product',
            description: 'A new product for testing',
            price: 29.99,
            imageUrl: 'http://example.com/test-image.jpg'
        };

        const req = new Request('http://localhost/api/products', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(newProduct)
        });

        const res = await app.request(req);
        expect(res.status).toBe(401);
    });

    it('PUT /api/products/:id - should update an existing product', async () => {
        // First, create a product
        const createdProductRes = await app.request('http://localhost/api/products', {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${sellerToken}`
            },
            body: JSON.stringify({
                name: 'Original Product',
                description: 'Original description',
                price: 19.99,
                imageUrl: 'http://example.com/original.jpg'
            })
        });
        
        const createdProduct = await createdProductRes.json();
        expect(createdProductRes.status).toBe(201);

        // Now update the product
        const updatedData = {
            name: 'Updated Product Name',
            description: 'Updated description',
            price: 39.99
        };

        const req = new Request(`http://localhost/api/products/${createdProduct.id}`, {
            method: 'PUT',
            headers: { 
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${sellerToken}`
            },
            body: JSON.stringify(updatedData)
        });

        const res = await app.request(req);
        expect(res.status).toBe(200);
        
        const body = await res.json();
        expect(body.id).toBe(createdProduct.id);
        expect(body.name).toBe(updatedData.name);
        expect(body.description).toBe(updatedData.description);
        expect(body.price).toBe(updatedData.price);
    });

    it('DELETE /api/products/:id - should delete an existing product', async () => {
        // First, create a product
        const createdProductRes = await app.request('http://localhost/api/products', {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${sellerToken}`
            },
            body: JSON.stringify({
                name: 'Product to Delete',
                description: 'This will be deleted',
                price: 19.99,
                imageUrl: 'http://example.com/to-delete.jpg'
            })
        });
        
        const createdProduct = await createdProductRes.json();
        expect(createdProductRes.status).toBe(201);

        // Now delete the product
        const req = new Request(`http://localhost/api/products/${createdProduct.id}`, {
            method: 'DELETE',
            headers: { 
                'Authorization': `Bearer ${sellerToken}`
            }
        });

        const res = await app.request(req);
        expect(res.status).toBe(200);
        
        const body = await res.json();
        expect(body.message).toBe('Product deleted successfully');
        
        // Verify the product no longer exists
        const getProductRes = await app.request(`http://localhost/api/products/${createdProduct.id}`);
        expect(getProductRes.status).toBe(404);
    });

    it('POST /api/products/:id/reviews - should add a review to a product', async () => {
        // Get an existing product ID
        const products = await db().getAllProducts();
        const productId = products[0]?.id;
        
        const reviewData = {
            rating: 5,
            comment: 'Excellent product!'
        };

        const req = new Request(`http://localhost/api/products/${productId}/reviews`, {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${buyerToken}`
            },
            body: JSON.stringify(reviewData)
        });

        const res = await app.request(req);
        expect(res.status).toBe(201);
        
        const body = await res.json();
        expect(body.id).toBeString();
        expect(body.userId).toBe(buyerId);
        expect(body.rating).toBe(reviewData.rating);
        expect(body.comment).toBe(reviewData.comment);
        expect(body.createdAt).toBeString();

        // Verify the review was added to the product
        const getProductRes = await app.request(`http://localhost/api/products/${productId}`);
        const getProductBody = await getProductRes.json();
        expect(getProductRes.status).toBe(200);
        expect(getProductBody.reviews).toBeArray();
        expect(getProductBody.reviews).toContainEqual(body);
    });

    it('POST /api/products/:id/reviews - should return 400 for invalid rating', async () => {
        // Get an existing product ID
        const products = await db().getAllProducts();
        const productId = products[0]?.id;
        
        const reviewData = {
            rating: 6, // Invalid rating
            comment: 'Good product!'
        };

        const req = new Request(`http://localhost/api/products/${productId}/reviews`, {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${buyerToken}`
            },
            body: JSON.stringify(reviewData)
        });

        const res = await app.request(req);
        expect(res.status).toBe(400);
        
        const body = await res.json();
        expect(body.error).toBe('Rating must be between 1 and 5');
    });
});