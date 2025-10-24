import { z } from 'zod';

// Schema for payment method entity
export const PaymentMethodSchema = z.object({
  id: z.string().min(1).openapi({
    example: 'payment-1234567890',
    description: 'Unique identifier for the payment method'
  }),
  userId: z.string().min(1).openapi({
    example: 'user-1234567890',
    description: 'ID of the user who owns this payment method'
  }),
  type: z.string().min(1).max(50).openapi({
    example: 'credit_card',
    description: 'Type of payment method (e.g., credit_card, debit_card, paypal)'
  }),
  cardNumber: z.string().min(1).max(20).optional().openapi({
    example: '**** **** **** 1234',
    description: 'Card number (masked for security)'
  }),
  cardHolderName: z.string().min(1).max(100).optional().openapi({
    example: 'John Doe',
    description: 'Name on the card'
  }),
  expiryMonth: z.string().min(1).max(2).optional().openapi({
    example: '12',
    description: 'Expiry month (MM format)'
  }),
  expiryYear: z.string().min(1).max(4).optional().openapi({
    example: '2025',
    description: 'Expiry year (YYYY format)'
  }),
  cvv: z.string().min(1).max(4).optional().openapi({
    example: '***',
    description: 'CVV code (masked for security)'
  }),
  isDefault: z.boolean().default(false).openapi({
    example: true,
    description: 'Whether this is the default payment method for the user'
  }),
  brand: z.string().min(1).max(50).optional().openapi({
    example: 'Visa',
    description: 'Brand of the card (e.g., Visa, Mastercard)'
  }),
  last4: z.string().min(1).max(4).optional().openapi({
    example: '1234',
    description: 'Last 4 digits of the card'
  })
});

// Schema for creating a new payment method
export const CreatePaymentMethodSchema = z.object({
  type: z.string().min(1).max(50).openapi({
    example: 'credit_card',
    description: 'Type of payment method (e.g., credit_card, debit_card, paypal)'
  }),
  cardNumber: z.string().min(13).max(19).regex(/^\d+$/, { message: 'Card number must contain only digits' }).optional().openapi({
    example: '4111111111111111',
    description: 'Full card number (will be securely stored)'
  }),
  cardHolderName: z.string().min(1).max(100).optional().openapi({
    example: 'John Doe',
    description: 'Name on the card'
  }),
  expiryMonth: z.string().min(1).max(2).regex(/^(0?[1-9]|1[0-2])$/, { message: 'Expiry month must be between 01-12' }).optional().openapi({
    example: '12',
    description: 'Expiry month (MM format)'
  }),
  expiryYear: z.string().min(4).max(4).regex(/^\d{4}$/, { message: 'Expiry year must be 4 digits' }).optional().openapi({
    example: '2025',
    description: 'Expiry year (YYYY format)'
  }),
  cvv: z.string().min(3).max(4).regex(/^\d+$/, { message: 'CVV must contain only digits' }).optional().openapi({
    example: '123',
    description: 'CVV code'
  }),
  isDefault: z.boolean().optional().default(false).openapi({
    example: true,
    description: 'Whether this is the default payment method for the user'
  })
});

// Schema for updating an existing payment method
export const UpdatePaymentMethodSchema = z.object({
  type: z.string().min(1).max(50).optional().openapi({
    example: 'credit_card',
    description: 'Type of payment method (e.g., credit_card, debit_card, paypal)'
  }),
  cardHolderName: z.string().min(1).max(100).optional().openapi({
    example: 'John Doe',
    description: 'Name on the card'
  }),
  isDefault: z.boolean().optional().openapi({
    example: true,
    description: 'Whether this is the default payment method for the user'
  })
});

// Schema for payment method ID parameter
export const PaymentMethodIdParamSchema = z.object({
  id: z.string().min(1).openapi({
    example: 'payment-1234567890',
    description: 'Unique identifier of the payment method'
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
export const DeletePaymentMethodResponseSchema = z.object({
  message: z.string().openapi({
    example: 'Payment method deleted successfully',
    description: 'Success message'
  })
});