import { Context } from 'hono';
import { z } from 'zod';
import { PaymentMethod, CreatePaymentMethodInput, UpdatePaymentMethodInput } from '../types/AddressPaymentDeliveryTypes';
import { CreatePaymentMethodSchema, UpdatePaymentMethodSchema } from '../schemas/PaymentMethodSchemas';
import { Logger } from '../utils/logger';

// Mock data store - in a real application, this would be replaced with database operations
let paymentMethods: PaymentMethod[] = [
  {
    id: 'payment-1',
    userId: 'user-123',
    type: 'credit_card',
    cardNumber: '**** **** **** 1234',
    cardHolderName: 'John Doe',
    expiryMonth: '12',
    expiryYear: '2025',
    cvv: '***',
    isDefault: true,
    brand: 'Visa',
    last4: '1234',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  },
  {
    id: 'payment-2',
    userId: 'user-123',
    type: 'debit_card',
    cardNumber: '**** **** **** 5678',
    cardHolderName: 'John Doe',
    expiryMonth: '06',
    expiryYear: '2026',
    cvv: '***',
    isDefault: false,
    brand: 'Mastercard',
    last4: '5678',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }
];

export class PaymentMethodController {
  // Get all payment methods for a specific user
  static async getUserPaymentMethods(c: Context) {
    try {
      const { userId } = c.req.param();
      
      // In real implementation, fetch from database
      const userPaymentMethods = paymentMethods.filter(pm => pm.userId === userId);
      
      if (!userPaymentMethods || userPaymentMethods.length === 0) {
        return c.json({ message: 'No payment methods found for this user' }, 404);
      }
      
      return c.json(userPaymentMethods, 200);
    } catch (error) {
      Logger.error('Error in getUserPaymentMethods:', error);
      return c.json({ message: 'Internal server error' }, 500);
    }
  }

  // Add a new payment method for a user
  static async createPaymentMethod(c: Context) {
    try {
      const { userId } = c.req.param();
      const requestData = await c.req.json();
      
      // Validate request data against Zod schema
      const validationResult = CreatePaymentMethodSchema.safeParse(requestData);
      
      if (!validationResult.success) {
        return c.json({ 
          message: 'Invalid input', 
          details: validationResult.error.flatten().fieldErrors 
        }, 400);
      }
      
      const validatedData = validationResult.data;
      
      // If setting this as default, unset other defaults for the user
      if (validatedData.isDefault) {
        paymentMethods = paymentMethods.map(pm => 
          pm.userId === userId && pm.isDefault 
            ? { ...pm, isDefault: false, updatedAt: new Date().toISOString() } 
            : pm
        );
      } else if (paymentMethods.filter(pm => pm.userId === userId).length === 0) {
        // If this is the first payment method for the user, set it as default
        validatedData.isDefault = true;
      }
      
      // Process card details for storage (in real app, use secure storage)
      let cardNumber = validatedData.cardNumber;
      let last4 = '';
      let brand = '';
      
      if (cardNumber) {
        last4 = cardNumber.slice(-4);
        // Simple brand detection
        if (cardNumber.startsWith('4')) {
          brand = 'Visa';
        } else if (cardNumber.startsWith('5')) {
          brand = 'Mastercard';
        } else if (cardNumber.startsWith('3')) {
          brand = 'Amex';
        } else {
          brand = 'Unknown';
        }
        // Mask the card number for display
        cardNumber = `**** **** **** ${last4}`;
      }
      
      const newPaymentMethod: PaymentMethod = {
        id: `payment-${Date.now()}`,
        userId,
        type: validatedData.type,
        cardNumber: cardNumber || undefined,
        cardHolderName: validatedData.cardHolderName,
        expiryMonth: validatedData.expiryMonth,
        expiryYear: validatedData.expiryYear,
        cvv: validatedData.cvv ? '***' : undefined, // Don't store CVV for security
        isDefault: validatedData.isDefault || false,
        brand,
        last4,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };
      
      paymentMethods.push(newPaymentMethod);
      
      // Return without sensitive data
      const { cvv: _, ...safeReturn } = newPaymentMethod;
      
      return c.json(safeReturn, 201);
    } catch (error) {
      Logger.error('Error in createPaymentMethod:', error);
      return c.json({ message: 'Internal server error' }, 500);
    }
  }

  // Update an existing payment method
  static async updatePaymentMethod(c: Context) {
    try {
      const { id } = c.req.param();
      const requestData = await c.req.json();
      
      // Validate request data
      const validationResult = UpdatePaymentMethodSchema.safeParse(requestData);
      
      if (!validationResult.success) {
        return c.json({ 
          message: 'Invalid input', 
          details: validationResult.error.flatten().fieldErrors 
        }, 400);
      }
      
      const validatedData = validationResult.data;
      
      // Find the payment method
      const paymentMethodIndex = paymentMethods.findIndex(pm => pm.id === id);
      if (paymentMethodIndex === -1) {
        return c.json({ message: 'Payment method not found' }, 404);
      }
      
      const paymentMethod = paymentMethods[paymentMethodIndex];
      
      // If setting as default, unset other defaults for the user
      if (validatedData.isDefault) {
        paymentMethods = paymentMethods.map(pm => 
          pm.userId === paymentMethod.userId && pm.isDefault && pm.id !== id
            ? { ...pm, isDefault: false, updatedAt: new Date().toISOString() } 
            : pm
        );
      }
      
      // Update the payment method
      const updatedPaymentMethod = {
        ...paymentMethod,
        ...validatedData,
        updatedAt: new Date().toISOString()
      };
      
      paymentMethods[paymentMethodIndex] = updatedPaymentMethod;
      
      // Return without sensitive data
      const { cvv: _, ...safeReturn } = updatedPaymentMethod;
      
      return c.json(safeReturn, 200);
    } catch (error) {
      Logger.error('Error in updatePaymentMethod:', error);
      return c.json({ message: 'Internal server error' }, 500);
    }
  }

  // Delete a payment method
  static async deletePaymentMethod(c: Context) {
    try {
      const { id } = c.req.param();
      
      const initialLength = paymentMethods.length;
      paymentMethods = paymentMethods.filter(pm => pm.id !== id);
      
      if (paymentMethods.length === initialLength) {
        return c.json({ message: 'Payment method not found' }, 404);
      }
      
      return c.json({ 
        message: 'Payment method deleted successfully' 
      }, 200);
    } catch (error) {
      Logger.error('Error in deletePaymentMethod:', error);
      return c.json({ message: 'Internal server error' }, 500);
    }
  }
}