import { z } from 'zod';

export const OrderItemSchema = z.object({
  productId: z.string().openapi({
    example: 'prod-1234567890',
    description: 'ID of the product'
  }),
  quantity: z.number().min(1, { message: 'Quantity must be at least 1' }).openapi({
    example: 2,
    description: 'Quantity of the product'
  }),
  price: z.number().min(0, { message: 'Price must be 0 or greater' }).openapi({
    example: 99.99,
    description: 'Price of the product at order time'
  })
});

export const OrderSchema = z.object({
  id: z.string().openapi({
    example: 'order-1234567890',
    description: 'Unique identifier for the order'
  }),
  buyerId: z.string().optional().openapi({
    example: 'user-1234567890',
    description: 'ID of the buyer (optional for customer view)'
  }),
  customerId: z.string().openapi({
    example: 'user-1234567890',
    description: 'ID of the customer'
  }),
  customerName: z.string().openapi({
    example: 'John Doe',
    description: 'Name of the customer'
  }),
  sellerId: z.string().openapi({
    example: 'user-1234567890',
    description: 'ID of the seller'
  }),
  total: z.number().min(0, { message: 'Total must be 0 or greater' }).openapi({
    example: 199.98,
    description: 'Total price of the order'
  }),
  status: z.string().openapi({
    example: 'Pending',
    description: 'Current status of the order'
  }),
  orderDate: z.string().datetime().openapi({
    example: new Date().toISOString(),
    description: 'Timestamp when the order was created'
  }),
  items: z.array(z.object({
    productId: z.string().openapi({
      example: 'prod-1234567890',
      description: 'ID of the product'
    }),
    productName: z.string().openapi({
      example: 'Wireless Headphones',
      description: 'Name of the product'
    }),
    quantity: z.number().min(1, { message: 'Quantity must be at least 1' }).openapi({
      example: 2,
      description: 'Quantity of the product'
    }),
    price: z.number().min(0, { message: 'Price must be 0 or greater' }).openapi({
      example: 99.99,
      description: 'Price of the product at order time'
    })
  })).openapi({
    description: 'Array of items in the order with product names'
  })
});

export const CreateOrderSchema = z.object({
  buyerId: z.string().optional().openapi({
    example: 'user-1234567890',
    description: 'ID of the buyer (optional)'
  }),
  customerId: z.string().openapi({
    example: 'user-1234567890',
    description: 'ID of the customer (required)'
  }),
  items: z.array(OrderItemSchema).openapi({
    description: 'Array of items in the order (required)'
  }),
  total: z.number().min(0, { message: 'Total must be 0 or greater' }).openapi({
    example: 199.98,
    description: 'Total price of the order (required, minimum 0)'
  })
});

export const UpdateOrderSchema = z.object({
  status: z.string().openapi({
    example: 'Shipped',
    description: 'New status for the order'
  })
});

export const OrderIdParamSchema = z.object({
  id: z.string().openapi({
    example: 'order-1234567890',
    description: 'Unique identifier of the order'
  })
});

export const ErrorSchema = z.object({
  error: z.string().openapi({
    example: 'Order not found',
    description: 'Error message explaining why the request failed'
  })
});

export const OrderQueryParamsSchema = z.object({
  status: z.string().optional().openapi({
    example: 'pending',
    description: 'Filter orders by status (e.g., pending, shipped, delivered)'
  }),
  page: z.string().regex(/^\d+$/).transform(Number).optional().default('1').openapi({
    example: 1,
    description: 'Page number for pagination (default: 1)'
  }),
  limit: z.string().regex(/^\d+$/).transform(Number).optional().default('10').openapi({
    example: 10,
    description: 'Number of items per page (default: 10, max: 100)'
  })
});