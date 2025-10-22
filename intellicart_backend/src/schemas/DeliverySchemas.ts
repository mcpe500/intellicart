import { z } from 'zod';

// Schema for delivery update entity
export const DeliveryUpdateSchema = z.object({
  status: z.string().min(1).max(50).openapi({
    example: 'shipped',
    description: 'Current status of the delivery update'
  }),
  location: z.string().max(255).optional().openapi({
    example: 'New York Distribution Center',
    description: 'Current location of the shipment'
  }),
  timestamp: z.string().datetime().openapi({
    example: '2023-10-15T10:30:00.000Z',
    description: 'Timestamp of the update'
  }),
  description: z.string().max(500).optional().openapi({
    example: 'Package has been shipped from distribution center',
    description: 'Description of the update'
  })
});

// Schema for delivery entity
export const DeliverySchema = z.object({
  id: z.string().min(1).openapi({
    example: 'delivery-1234567890',
    description: 'Unique identifier for the delivery'
  }),
  orderId: z.string().min(1).openapi({
    example: 'order-1234567890',
    description: 'ID of the associated order'
  }),
  status: z.string().min(1).max(50).openapi({
    example: 'shipped',
    description: 'Current status of the delivery'
  }),
  trackingNumber: z.string().min(1).max(100).openapi({
    example: 'TRK123456789',
    description: 'Tracking number for the shipment'
  }),
  estimatedDelivery: z.string().datetime().optional().openapi({
    example: '2023-10-20T00:00:00.000Z',
    description: 'Estimated delivery date'
  }),
  actualDelivery: z.string().datetime().optional().openapi({
    example: '2023-10-19T15:30:00.000Z',
    description: 'Actual delivery date (if delivered)'
  }),
  shippingAddress: z.string().optional().openapi({
    example: '123 Main Street, New York, NY 10001',
    description: 'Shipping address for the delivery'
  }),
  carrier: z.string().min(1).max(100).optional().openapi({
    example: 'FedEx',
    description: 'Shipping carrier'
  }),
  lastUpdate: z.string().datetime().optional().openapi({
    example: '2023-10-15T10:30:00.000Z',
    description: 'Timestamp of the last update'
  }),
  updates: z.array(DeliveryUpdateSchema).optional().default([]).openapi({
    description: 'History of delivery updates'
  })
});

// Schema for creating a new delivery
export const CreateDeliverySchema = z.object({
  orderId: z.string().min(1).openapi({
    example: 'order-1234567890',
    description: 'ID of the associated order'
  }),
  trackingNumber: z.string().min(1).max(100).openapi({
    example: 'TRK123456789',
    description: 'Tracking number for the shipment'
  }),
  estimatedDelivery: z.string().datetime().optional().openapi({
    example: '2023-10-20T00:00:00.000Z',
    description: 'Estimated delivery date'
  }),
  carrier: z.string().min(1).max(100).optional().openapi({
    example: 'FedEx',
    description: 'Shipping carrier'
  })
});

// Schema for delivery ID parameter
export const DeliveryIdParamSchema = z.object({
  id: z.string().min(1).openapi({
    example: 'delivery-1234567890',
    description: 'Unique identifier of the delivery'
  })
});

// Schema for tracking number parameter
export const TrackingNumberParamSchema = z.object({
  trackingNumber: z.string().min(1).max(100).openapi({
    example: 'TRK123456789',
    description: 'Tracking number for the shipment'
  })
});

// Schema for user ID parameter
export const UserIdParamSchema = z.object({
  userId: z.string().min(1).openapi({
    example: 'user-1234567890',
    description: 'Unique identifier of the user'
  })
});

// Schema for API error responses
export const ErrorSchema = z.object({
  message: z.string().openapi({
    example: 'Invalid input',
    description: 'Error message'
  }),
  details: z.any().optional().openapi({
    description: 'Additional error details'
  })
});

// Schema for successful deletion response
export const DeleteDeliveryResponseSchema = z.object({
  message: z.string().openapi({
    example: 'Delivery deleted successfully',
    description: 'Success message'
  })
});