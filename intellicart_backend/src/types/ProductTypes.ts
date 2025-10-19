export interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  imageUrl: string;
  sellerId: string;
  reviews: Review[];
}

export interface CreateProductInput {
  name: string;
  description: string;
  price: number;
  imageUrl: string;
}

export interface UpdateProductInput {
  name?: string;
  description?: string;
  price?: number;
  imageUrl?: string;
}

export interface Review {
  id: string;
  userId: string;
  rating: number;
  comment: string;
  createdAt: string;
}

export interface CreateReviewInput {
  rating: number;
  comment: string;
}