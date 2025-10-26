/**
 * Order Data Transfer Object (DTO) Module
 * 
 * This module defines the data transfer objects for order-related operations.
 * These interfaces provide type safety and clear structure for order data
 * across the application.
 * 
 * @module OrderDTO
 * @description DTOs for order data structures
 * @author Intellicart Team
 * @version 1.0.0
 */

import { Product } from './ProductDTO';

// Interface for an Order Item
export interface OrderItem extends Product {
  quantity?: number;
}

// Interface for an Order entity
export interface Order {
  id: number;
  customerName: string;
  items: OrderItem[];
  total: number;
  status: string; // e.g., 'Pending', 'Shipped', 'Delivered'
  orderDate: string;
  sellerId: number;
  createdAt?: string;
}

// Interface for updating an order status (request)
export interface UpdateOrderStatusRequest {
  status: string;
}

// Interface for creating a new order (request)
export interface CreateOrderRequest {
  customerName: string;
  items: OrderItem[];
  total: number;
  sellerId: number;
}