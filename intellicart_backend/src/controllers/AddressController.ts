import { Context } from 'hono';
import { z } from 'zod';
import { Address, CreateAddressInput, UpdateAddressInput } from '../types/AddressPaymentDeliveryTypes';
import { CreateAddressSchema, UpdateAddressSchema } from '../schemas/AddressSchemas';
import { Logger } from '../utils/logger';

// Mock data store - in a real application, this would be replaced with database operations
let addresses: Address[] = [
  {
    id: 'address-1',
    userId: 'user-123',
    name: 'Home Address',
    street: '123 Main Street',
    city: 'New York',
    state: 'NY',
    zipCode: '10001',
    country: 'USA',
    phoneNumber: '+1-555-123-4567',
    isDefault: true,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  },
  {
    id: 'address-2',
    userId: 'user-123',
    name: 'Work Address',
    street: '456 Business Ave',
    city: 'New York',
    state: 'NY',
    zipCode: '10002',
    country: 'USA',
    phoneNumber: '+1-555-987-6543',
    isDefault: false,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }
];

export class AddressController {
  // Get all addresses for a specific user
  static async getUserAddresses(c: Context) {
    try {
      const { userId } = c.req.param();
      
      // In real implementation, fetch from database
      const userAddresses = addresses.filter(address => address.userId === userId);
      
      if (!userAddresses || userAddresses.length === 0) {
        return c.json({ message: 'No addresses found for this user' }, 404);
      }
      
      return c.json(userAddresses, 200);
    } catch (error) {
      Logger.error('Error in getUserAddresses:', error);
      return c.json({ message: 'Internal server error' }, 500);
    }
  }

  // Add a new address for a user
  static async createAddress(c: Context) {
    try {
      const { userId } = c.req.param();
      const requestData = await c.req.json();
      
      // Validate request data against Zod schema
      const validationResult = CreateAddressSchema.safeParse(requestData);
      
      if (!validationResult.success) {
        return c.json({ 
          message: 'Invalid input', 
          details: validationResult.error.flatten().fieldErrors 
        }, 400);
      }
      
      const validatedData = validationResult.data;
      
      // If setting this as default, unset other defaults for the user
      if (validatedData.isDefault) {
        addresses = addresses.map(addr => 
          addr.userId === userId && addr.isDefault 
            ? { ...addr, isDefault: false, updatedAt: new Date().toISOString() } 
            : addr
        );
      } else if (addresses.filter(addr => addr.userId === userId).length === 0) {
        // If this is the first address for the user, set it as default
        validatedData.isDefault = true;
      }
      
      const newAddress: Address = {
        id: `address-${Date.now()}`,
        userId,
        name: validatedData.name,
        street: validatedData.street,
        city: validatedData.city,
        state: validatedData.state,
        zipCode: validatedData.zipCode,
        country: validatedData.country,
        phoneNumber: validatedData.phoneNumber,
        isDefault: validatedData.isDefault || false,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };
      
      addresses.push(newAddress);
      
      return c.json(newAddress, 201);
    } catch (error) {
      Logger.error('Error in createAddress:', error);
      return c.json({ message: 'Internal server error' }, 500);
    }
  }

  // Update an existing address
  static async updateAddress(c: Context) {
    try {
      const { id } = c.req.param();
      const requestData = await c.req.json();
      
      // Validate request data
      const validationResult = UpdateAddressSchema.safeParse(requestData);
      
      if (!validationResult.success) {
        return c.json({ 
          message: 'Invalid input', 
          details: validationResult.error.flatten().fieldErrors 
        }, 400);
      }
      
      const validatedData = validationResult.data;
      
      // Find the address
      const addressIndex = addresses.findIndex(addr => addr.id === id);
      if (addressIndex === -1) {
        return c.json({ message: 'Address not found' }, 404);
      }
      
      const address = addresses[addressIndex];
      
      // If setting as default, unset other defaults for the user
      if (validatedData.isDefault) {
        addresses = addresses.map(addr => 
          addr.userId === address.userId && addr.isDefault && addr.id !== id
            ? { ...addr, isDefault: false, updatedAt: new Date().toISOString() } 
            : addr
        );
      }
      
      // Update the address
      const updatedAddress = {
        ...address,
        ...validatedData,
        updatedAt: new Date().toISOString()
      };
      
      addresses[addressIndex] = updatedAddress;
      
      return c.json(updatedAddress, 200);
    } catch (error) {
      Logger.error('Error in updateAddress:', error);
      return c.json({ message: 'Internal server error' }, 500);
    }
  }

  // Delete an address
  static async deleteAddress(c: Context) {
    try {
      const { id } = c.req.param();
      
      const initialLength = addresses.length;
      addresses = addresses.filter(addr => addr.id !== id);
      
      if (addresses.length === initialLength) {
        return c.json({ message: 'Address not found' }, 404);
      }
      
      return c.json({ 
        message: 'Address deleted successfully' 
      }, 200);
    } catch (error) {
      Logger.error('Error in deleteAddress:', error);
      return c.json({ message: 'Internal server error' }, 500);
    }
  }
}