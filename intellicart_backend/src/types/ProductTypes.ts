export interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  originalPrice?: number;
  imageUrl: string;
  sellerId: string;
  categoryId?: string;
  createdAt: string;
  updatedAt: string;
  reviews: Review[];
  averageRating: number;
}

export interface CreateProductInput {
  name: string;
  description: string;
  price: number;
  originalPrice?: number;
  imageUrl: string;
  categoryId?: string;
}

export interface UpdateProductInput {
  name?: string;
  description?: string;
  price?: number;
  originalPrice?: number;
  imageUrl?: string;
  categoryId?: string;
}

export interface Review {
  id: string;
  userId: string;
  title?: string;
  reviewText?: string;
  rating: number;
  userName?: string;
  createdAt: string;
}

export interface CreateReviewInput {
  rating: number;
  title?: string;
  reviewText?: string;
}