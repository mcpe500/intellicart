// Address Types
export interface Address {
  id: string;
  userId: string;
  name: string;
  street: string;
  city: string;
  state: string;
  zipCode: string;
  country: string;
  phoneNumber?: string;
  isDefault: boolean;
  createdAt?: string;
  updatedAt?: string;
}

export interface CreateAddressInput {
  name: string;
  street: string;
  city: string;
  state: string;
  zipCode: string;
  country: string;
  phoneNumber?: string;
  isDefault?: boolean;
}

export interface UpdateAddressInput {
  name?: string;
  street?: string;
  city?: string;
  state?: string;
  zipCode?: string;
  country?: string;
  phoneNumber?: string;
  isDefault?: boolean;
}

// Payment Method Types
export interface PaymentMethod {
  id: string;
  userId: string;
  type: string;
  cardNumber?: string;
  cardHolderName?: string;
  expiryMonth?: string;
  expiryYear?: string;
  cvv?: string;
  isDefault: boolean;
  brand?: string;
  last4?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface CreatePaymentMethodInput {
  type: string;
  cardNumber?: string;
  cardHolderName?: string;
  expiryMonth?: string;
  expiryYear?: string;
  cvv?: string;
  isDefault?: boolean;
}

export interface UpdatePaymentMethodInput {
  type?: string;
  cardHolderName?: string;
  isDefault?: boolean;
}

// Delivery Types
export interface DeliveryUpdate {
  status: string;
  location?: string;
  timestamp: string;
  description?: string;
}

export interface Delivery {
  id: string;
  orderId: string;
  status: string;
  trackingNumber: string;
  estimatedDelivery?: string;
  actualDelivery?: string;
  shippingAddress?: string;
  carrier?: string;
  lastUpdate?: string;
  updates: DeliveryUpdate[];
  createdAt?: string;
  updatedAt?: string;
}

export interface CreateDeliveryInput {
  orderId: string;
  trackingNumber: string;
  estimatedDelivery?: string;
  carrier?: string;
}

export interface UpdateDeliveryInput {
  status?: string;
  actualDelivery?: string;
  updates?: DeliveryUpdate[];
}