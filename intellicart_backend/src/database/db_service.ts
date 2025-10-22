import { User, CreateUserInput, UpdateUserInput } from '../types/UserTypes';
import { Product, CreateProductInput, UpdateProductInput, Review, CreateReviewInput } from '../types/ProductTypes';
import { Order, UpdateOrderInput, CreateOrderInput } from '../types/OrderTypes';

// Abstract Database Service Interface
export interface DbService {
  // User Methods
  getUserById(id: string): Promise<User | null>;
  getUserByEmail(email: string): Promise<User | null>;
  getAllUsers(): Promise<User[]>;
  createUser(userData: CreateUserInput): Promise<User>;
  updateUser(id: string, userData: Partial<User>): Promise<User | null>;
  deleteUser(id: string): Promise<boolean>;

  // Product Methods
  getAllProducts(): Promise<Product[]>;
  getProductById(id: string): Promise<Product | null>;
  getProductsBySellerId(sellerId: string): Promise<Product[]>;
  getProductsBySellerIdWithPagination(sellerId: string, page?: number, limit?: number): Promise<{ products: Product[], pagination: any }>;
  createProduct(productData: CreateProductInput, sellerId: string): Promise<Product>;
  updateProduct(id: string, productData: UpdateProductInput): Promise<Product | null>;
  deleteProduct(id: string): Promise<boolean>;
  addProductReview(productId: string, reviewData: CreateReviewInput, userId: string): Promise<Review | null>;
  calculateAverageRating(productId: string): Promise<number>;

  // Order Methods
  createOrder(orderData: CreateOrderInput): Promise<Order>;
  getOrdersBySellerId(sellerId: string, status?: string): Promise<Order[]>;
  getOrdersByCustomerId(customerId: string, status?: string): Promise<Order[]>;
  updateOrderStatus(orderId: string, status: string): Promise<Order | null>;
}

// Singleton instance of the database service
let dbInstance: DbService;

export const initializeDb = () => {
  const mode = process.env.DATABASE_MODE || 'json';
  if (mode === 'firestore') {
    const FirestoreDbService = require('./firestore_service').default;
    dbInstance = new FirestoreDbService();
    console.log('Database initialized: Firestore mode');
  } else {
    const JsonDbService = require('./json_service').default;
    dbInstance = new JsonDbService();
    console.log('Database initialized: JSON mode');
  }
};

export const db = (): DbService => {
  if (!dbInstance) {
    console.error('Database service not initialized. Initializing now...');
    initializeDb();
  }
  return dbInstance;
};