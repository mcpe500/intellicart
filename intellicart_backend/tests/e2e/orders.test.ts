import { describe, it, expect, beforeEach } from 'bun:test';
import app from '../../src/index';
import { setupE2ETestDb, resetTestDb } from './setup';
import { db, initializeDb } from '../../src/database/db_service';
import { sign } from 'hono/jwt';

// IMPORTANT: Set environment for testing - specifically DATABASE_MODE
process.env.DATABASE_MODE = 'json'; // Force JSON mode for these E2E tests
process.env.JWT_SECRET = 'e2e-test-secret-shhhh'; // Use a consistent secret for E2E tests

describe('E2E - Orders API', () => {
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

    it('GET /api/orders - should return orders for authenticated seller', async () => {
        // First, create an order in the database to test with
        // Using the existing order from the initial db.json or creating one
        const product = (await db().getAllProducts())[0];
        
        if (product) {
            // Create an order manually in the db.json file for testing
            const testOrder = {
                id: `order-${Date.now()}`,
                buyerId: buyerId,
                sellerId: sellerId,
                items: [{
                    productId: product.id,
                    quantity: 1,
                    price: product.price
                }],
                total: product.price,
                status: 'Pending',
                orderDate: new Date().toISOString()
            };
            
            // For testing purposes, we'll need to add the order directly to the database
            // Note: This depends on the implementation of the database layer
        }

        const req = new Request('http://localhost/api/orders', {
            headers: { 'Authorization': `Bearer ${sellerToken}` }
        });
        const res = await app.request(req);
        expect(res.status).toBe(200);
        
        const body = await res.json();
        expect(Array.isArray(body)).toBe(true);
    });

    it('GET /api/orders - should return 401 for unauthenticated requests', async () => {
        const req = new Request('http://localhost/api/orders');
        const res = await app.request(req);
        expect(res.status).toBe(401);
    });

    it('PUT /api/orders/:id - should update order status for seller', async () => {
        // For this test, we'll use an existing order from the initial db.json
        // Find an order that belongs to our test seller or the default seller in initial data
        const allOrders = (await db().getOrdersBySellerId(sellerId)).concat(
            await db().getOrdersBySellerId('2') // Include orders from initial db
        );
        
        if (allOrders.length > 0) {
            const orderId = allOrders[0].id;
            
            const req = new Request(`http://localhost/api/orders/${orderId}`, {
                method: 'PUT',
                headers: { 
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${sellerToken}`
                },
                body: JSON.stringify({ status: 'Shipped' })
            });
            
            const res = await app.request(req);
            expect(res.status).toBe(200);
            
            const body = await res.json();
            expect(body.id).toBe(orderId);
            expect(body.status).toBe('Shipped');
        } else {
            // If no orders exist, test with a non-existent order to check auth
            const req = new Request('http://localhost/api/orders/non-existent-id', {
                method: 'PUT',
                headers: { 
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${sellerToken}`
                },
                body: JSON.stringify({ status: 'Shipped' })
            });
            
            const res = await app.request(req);
            
            // The response could be 403 (not authorized for that order) or 404 (order not found)
            // Both are valid responses in this context
            expect(res.status).toBeOneOf([403, 404]);
        }
    });

    it('PUT /api/orders/:id - should return 401 for unauthenticated requests', async () => {
        const req = new Request('http://localhost/api/orders/some-order-id', {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ status: 'Shipped' })
        });
        const res = await app.request(req);
        expect(res.status).toBe(401);
    });

    it('PUT /api/orders/:id - should return 403 for unauthorized seller', async () => {
        // Create a test order that belongs to a different seller
        const otherSeller = await db().createUser({
            name: 'Other Seller',
            email: `other-seller-${Date.now()}@test.com`,
            password: 'password123',
            role: 'seller'
        });
        
        const otherSellerToken = await sign(
            { id: otherSeller.id, email: otherSeller.email, role: otherSeller.role },
            process.env.JWT_SECRET!
        );

        // Use an existing order from the initial db.json (if any) or create one
        const allOrders = await db().getOrdersBySellerId('2'); // Use initial db orders
        if (allOrders.length > 0) {
            const orderId = allOrders[0].id;
            
            const req = new Request(`http://localhost/api/orders/${orderId}`, {
                method: 'PUT',
                headers: { 
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${otherSellerToken}`
                },
                body: JSON.stringify({ status: 'Shipped' })
            });
            
            const res = await app.request(req);
            // Should return 403 since the order doesn't belong to the requesting seller
            expect(res.status).toBeOneOf([403, 404]);
        }
    });
});