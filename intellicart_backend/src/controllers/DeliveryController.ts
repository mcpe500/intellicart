import { Context } from 'hono';
import { z } from 'zod';
import { Delivery, CreateDeliveryInput, UpdateDeliveryInput, DeliveryUpdate } from '../types/AddressPaymentDeliveryTypes';
import { CreateDeliverySchema } from '../schemas/DeliverySchemas';
import { Logger } from '../utils/logger';

// Mock data store - in a real application, this would be replaced with database operations
let deliveries: Delivery[] = [
  {
    id: 'delivery-1',
    orderId: 'order-123',
    status: 'shipped',
    trackingNumber: 'TRK123456789',
    estimatedDelivery: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000).toISOString(), // 5 days from now
    carrier: 'FedEx',
    shippingAddress: '123 Main Street, New York, NY 10001',
    lastUpdate: new Date().toISOString(),
    updates: [
      {
        status: 'shipped',
        location: 'New York Distribution Center',
        timestamp: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(), // 1 day ago
        description: 'Package has been shipped from distribution center'
      }
    ],
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  },
  {
    id: 'delivery-2',
    orderId: 'order-456',
    status: 'delivered',
    trackingNumber: 'TRK987654321',
    estimatedDelivery: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(), // 2 days ago
    actualDelivery: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(), // 1 day ago
    carrier: 'UPS',
    shippingAddress: '456 Business Ave, New York, NY 10002',
    lastUpdate: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
    updates: [
      {
        status: 'in_transit',
        location: 'Chicago Distribution Center',
        timestamp: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString(),
        description: 'Package is in transit'
      },
      {
        status: 'delivered',
        location: 'New York',
        timestamp: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
        description: 'Package has been delivered'
      }
    ],
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }
];

export class DeliveryController {
  // Get all deliveries for a specific user
  static async getUserDeliveries(c: Context) {
    try {
      const { userId } = c.req.param();
      
      // First, we need to get the user's orders and then their associated deliveries
      // In a real implementation, this would involve looking up orders and associated deliveries
      // For mock purposes, we'll look for deliveries linked to orders associated with the user
      
      // Mock implementation - we'll return all deliveries for the given user
      const userDeliveries = deliveries; // In reality, you'd need to join with orders table
      
      if (!userDeliveries || userDeliveries.length === 0) {
        return c.json({ message: 'No deliveries found for this user' }, 404);
      }
      
      return c.json(userDeliveries, 200);
    } catch (error) {
      Logger.error('Error in getUserDeliveries:', error);
      return c.json({ message: 'Internal server error' }, 500);
    }
  }

  // Get delivery information by tracking number
  static async getDeliveryByTrackingNumber(c: Context) {
    try {
      const { trackingNumber } = c.req.param();
      
      // Find the delivery by tracking number
      const delivery = deliveries.find(d => d.trackingNumber === trackingNumber);
      
      if (!delivery) {
        return c.json({ message: 'Delivery not found' }, 404);
      }
      
      return c.json(delivery, 200);
    } catch (error) {
      Logger.error('Error in getDeliveryByTrackingNumber:', error);
      return c.json({ message: 'Internal server error' }, 500);
    }
  }

  // Create a new delivery
  static async createDelivery(c: Context) {
    try {
      const requestData = await c.req.json();
      
      // Validate request data against Zod schema
      const validationResult = CreateDeliverySchema.safeParse(requestData);
      
      if (!validationResult.success) {
        return c.json({ 
          message: 'Invalid input', 
          details: validationResult.error.flatten().fieldErrors 
        }, 400);
      }
      
      const validatedData = validationResult.data;
      
      // Check if delivery with this tracking number already exists
      if (deliveries.some(d => d.trackingNumber === validatedData.trackingNumber)) {
        return c.json({ message: 'Delivery with this tracking number already exists' }, 409);
      }
      
      const newDelivery: Delivery = {
        id: `delivery-${Date.now()}`,
        orderId: validatedData.orderId,
        status: 'processing', // Default status
        trackingNumber: validatedData.trackingNumber,
        estimatedDelivery: validatedData.estimatedDelivery,
        carrier: validatedData.carrier,
        updates: [{
          status: 'processing',
          timestamp: new Date().toISOString(),
          description: 'Order is being processed'
        }],
        lastUpdate: new Date().toISOString(),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };
      
      deliveries.push(newDelivery);
      
      return c.json(newDelivery, 201);
    } catch (error) {
      Logger.error('Error in createDelivery:', error);
      return c.json({ message: 'Internal server error' }, 500);
    }
  }

  // Update a delivery
  static async updateDelivery(c: Context) {
    try {
      const { id } = c.req.param();
      const requestData = await c.req.json();
      
      // Validate request data
      const validationResult = z.object({
        status: z.string().min(1).max(50).optional(),
        actualDelivery: z.string().datetime().optional(),
        updates: z.array(z.object({
          status: z.string().min(1).max(50),
          location: z.string().max(255).optional(),
          timestamp: z.string().datetime(),
          description: z.string().max(500).optional()
        })).optional()
      }).safeParse(requestData);
      
      if (!validationResult.success) {
        return c.json({ 
          message: 'Invalid input', 
          details: validationResult.error.flatten().fieldErrors 
        }, 400);
      }
      
      const validatedData = validationResult.data;
      
      // Find the delivery
      const deliveryIndex = deliveries.findIndex(d => d.id === id);
      if (deliveryIndex === -1) {
        return c.json({ message: 'Delivery not found' }, 404);
      }
      
      const delivery = deliveries[deliveryIndex];
      
      // Update the delivery
      const updatedDelivery = {
        ...delivery,
        ...validatedData,
        lastUpdate: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };
      
      // If new updates are provided, add them to the existing updates
      if (validatedData.updates && validatedData.updates.length > 0) {
        updatedDelivery.updates = [...delivery.updates, ...validatedData.updates];
        // Update the status to the latest update status
        updatedDelivery.status = validatedData.updates[validatedData.updates.length - 1].status;
        updatedDelivery.lastUpdate = validatedData.updates[validatedData.updates.length - 1].timestamp;
      }
      
      deliveries[deliveryIndex] = updatedDelivery;
      
      return c.json(updatedDelivery, 200);
    } catch (error) {
      Logger.error('Error in updateDelivery:', error);
      return c.json({ message: 'Internal server error' }, 500);
    }
  }

  // Delete a delivery
  static async deleteDelivery(c: Context) {
    try {
      const { id } = c.req.param();
      
      const initialLength = deliveries.length;
      deliveries = deliveries.filter(d => d.id !== id);
      
      if (deliveries.length === initialLength) {
        return c.json({ message: 'Delivery not found' }, 404);
      }
      
      return c.json({ 
        message: 'Delivery deleted successfully' 
      }, 200);
    } catch (error) {
      Logger.error('Error in deleteDelivery:', error);
      return c.json({ message: 'Internal server error' }, 500);
    }
  }
}