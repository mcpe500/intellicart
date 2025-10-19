export interface Order {
  id: string;
  buyerId?: string;
  customerId: string;
  customerName: string;
  sellerId: string;
  total: number;
  status: string;
  orderDate: string;
  items: OrderItem[];
}

export interface OrderItem {
  productId: string;
  productName: string;
  quantity: number;
  price: number;
}

export interface CreateOrderInput {
  buyerId?: string;
  customerId: string;
  items: OrderItem[];
  total: number;
}

export interface UpdateOrderInput {
  status?: string;
}