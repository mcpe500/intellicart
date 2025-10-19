import { User, CreateUserInput, UpdateUserInput } from '../types/UserTypes';
import { Product, CreateProductInput, UpdateProductInput, Review, CreateReviewInput } from '../types/ProductTypes';
import { Order, UpdateOrderInput } from '../types/OrderTypes';

// Abstract Database Service Interface
export interface DbService {
  // User Methods
  getUserById(id: string): Promise<User | null>;
  getUserByEmail(email: string): Promise<User | null>;
  createUser(userData: CreateUserInput): Promise<User>;

  // Product Methods
  getAllProducts(): Promise<Product[]>;
  getProductById(id: string): Promise<Product | null>;
  getProductsBySellerId(sellerId: string): Promise<Product[]>;
  createProduct(productData: CreateProductInput, sellerId: string): Promise<Product>;
  updateProduct(id: string, productData: UpdateProductInput): Promise<Product | null>;
  deleteProduct(id: string): Promise<boolean>;
  addProductReview(productId: string, reviewData: CreateReviewInput, userId: string): Promise<Review | null>;

  // Order Methods
  getOrdersBySellerId(sellerId: string): Promise<Order[]>;
  updateOrderStatus(orderId: string, status: string): Promise<Order | null>;
}

// Singleton instance of the database service
let dbInstance: DbService;

export const initializeDb = () => {
  const mode = process.env.DATABASE_MODE;
  if (mode === 'firestore') {
    const FirestoreDbService = require('./firestore_service').default;
    dbInstance = new FirestoreDbService();
  } else {
    const JsonDbService = require('./json_service').default;
    dbInstance = new JsonDbService();
  }
};

export const db = (): DbService => {
  if (!dbInstance) {
    throw new Error('Database service not initialized. Call initializeDb() first.');
  }
  return dbInstance;
};