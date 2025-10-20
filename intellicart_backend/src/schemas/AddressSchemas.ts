import { z } from 'zod';

// Schema for address entity
export const AddressSchema = z.object({
  id: z.string().min(1).openapi({
    example: 'address-1234567890',
    description: 'Unique identifier for the address'
  }),
  userId: z.string().min(1).openapi({
    example: 'user-1234567890',
    description: 'ID of the user who owns this address'
  }),
  name: z.string().min(1).max(100).openapi({
    example: 'Home Address',
    description: 'Name for this address (e.g., Home, Work)'
  }),
  street: z.string().min(1).max(255).openapi({
    example: '123 Main Street',
    description: 'Street address'
  }),
  city: z.string().min(1).max(100).openapi({
    example: 'New York',
    description: 'City name'
  }),
  state: z.string().min(1).max(100).openapi({
    example: 'NY',
    description: 'State or province name'
  }),
  zipCode: z.string().min(1).max(20).openapi({
    example: '10001',
    description: 'ZIP or postal code'
  }),
  country: z.string().min(1).max(100).openapi({
    example: 'USA',
    description: 'Country name'
  }),
  phoneNumber: z.string().min(1).max(20).optional().openapi({
    example: '+1-555-123-4567',
    description: 'Phone number associated with this address'
  }),
  isDefault: z.boolean().default(false).openapi({
    example: true,
    description: 'Whether this is the default address for the user'
  })
});

// Schema for creating a new address
export const CreateAddressSchema = z.object({
  name: z.string().min(1).max(100).openapi({
    example: 'Home Address',
    description: 'Name for this address (e.g., Home, Work)'
  }),
  street: z.string().min(1).max(255).openapi({
    example: '123 Main Street',
    description: 'Street address'
  }),
  city: z.string().min(1).max(100).openapi({
    example: 'New York',
    description: 'City name'
  }),
  state: z.string().min(1).max(100).openapi({
    example: 'NY',
    description: 'State or province name'
  }),
  zipCode: z.string().min(1).max(20).openapi({
    example: '10001',
    description: 'ZIP or postal code'
  }),
  country: z.string().min(1).max(100).openapi({
    example: 'USA',
    description: 'Country name'
  }),
  phoneNumber: z.string().min(1).max(20).optional().openapi({
    example: '+1-555-123-4567',
    description: 'Phone number associated with this address'
  }),
  isDefault: z.boolean().optional().default(false).openapi({
    example: true,
    description: 'Whether this is the default address for the user'
  })
});

// Schema for updating an existing address
export const UpdateAddressSchema = z.object({
  name: z.string().min(1).max(100).optional().openapi({
    example: 'Home Address',
    description: 'Name for this address (e.g., Home, Work)'
  }),
  street: z.string().min(1).max(255).optional().openapi({
    example: '123 Main Street',
    description: 'Street address'
  }),
  city: z.string().min(1).max(100).optional().openapi({
    example: 'New York',
    description: 'City name'
  }),
  state: z.string().min(1).max(100).optional().openapi({
    example: 'NY',
    description: 'State or province name'
  }),
  zipCode: z.string().min(1).max(20).optional().openapi({
    example: '10001',
    description: 'ZIP or postal code'
  }),
  country: z.string().min(1).max(100).optional().openapi({
    example: 'USA',
    description: 'Country name'
  }),
  phoneNumber: z.string().min(1).max(20).optional().openapi({
    example: '+1-555-123-4567',
    description: 'Phone number associated with this address'
  }),
  isDefault: z.boolean().optional().openapi({
    example: true,
    description: 'Whether this is the default address for the user'
  })
});

// Schema for address ID parameter
export const AddressIdParamSchema = z.object({
  id: z.string().min(1).openapi({
    example: 'address-1234567890',
    description: 'Unique identifier of the address'
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
export const DeleteAddressResponseSchema = z.object({
  message: z.string().openapi({
    example: 'Address deleted successfully',
    description: 'Success message'
  })
});