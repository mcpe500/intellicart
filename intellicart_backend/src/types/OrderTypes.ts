export interface Order {
  id: string;
  buyerId: string;
  sellerId: string;
  items: OrderItem[];
  total: number;
  status: string;
  orderDate: string;
}

export interface OrderItem {
  productId: string;
  quantity: number;
  price: number;
}

export interface CreateOrderInput {
  buyerId: string;
  items: OrderItem[];
  total: number;
}

export interface UpdateOrderInput {
  status?: string;
}