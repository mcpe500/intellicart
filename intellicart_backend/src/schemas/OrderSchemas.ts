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
  buyerId: z.string().openapi({
    example: 'user-1234567890',
    description: 'ID of the buyer'
  }),
  sellerId: z.string().openapi({
    example: 'user-1234567890',
    description: 'ID of the seller'
  }),
  items: z.array(OrderItemSchema).openapi({
    description: 'Array of items in the order'
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
  })
});

export const CreateOrderSchema = z.object({
  buyerId: z.string().openapi({
    example: 'user-1234567890',
    description: 'ID of the buyer (required)'
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