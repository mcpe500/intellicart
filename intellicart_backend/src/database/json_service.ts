import fs from 'fs/promises';
import path from 'path';
import { DbService } from './db_service';
import { User, CreateUserInput } from '../types/UserTypes';
import { Product, CreateProductInput, UpdateProductInput, Review, CreateReviewInput } from '../types/ProductTypes';
import { Order } from '../types/OrderTypes';

const dbPath = path.resolve(process.cwd(), 'src/database/db.json');

type DbData = {
  users: (User & { password?: string })[];
  products: Product[];
  orders: Order[];
};

class JsonDbService implements DbService {
  private async readDb(): Promise<DbData> {
    const data = await fs.readFile(dbPath, 'utf-8');
    return JSON.parse(data);
  }

  private async writeDb(data: DbData): Promise<void> {
    await fs.writeFile(dbPath, JSON.stringify(data, null, 2));
  }

  // --- User Methods ---
  async getUserById(id: string): Promise<User | null> {
    const db = await this.readDb();
    const user = db.users.find(u => u.id === id);
    if (!user) return null;
    const { password, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }

  async getUserByEmail(email: string): Promise<User & { password?: string } | null> {
    const db = await this.readDb();
    return db.users.find(u => u.email === email) || null;
  }

  async createUser(userData: CreateUserInput): Promise<User> {
    const db = await this.readDb();
    const newUser: User & { password?: string } = {
      id: `user-${Date.now()}`,
      name: userData.name,
      email: userData.email,
      password: userData.password, // This will be hashed in AuthController
      role: userData.role || 'buyer',
      createdAt: new Date().toISOString(),
    };
    db.users.push(newUser);
    await this.writeDb(db);
    const { password, ...userWithoutPassword } = newUser;
    return userWithoutPassword;
  }

  // --- Product Methods ---
  async getAllProducts(): Promise<Product[]> {
    const db = await this.readDb();
    return db.products;
  }

  async getProductById(id: string): Promise<Product | null> {
    const db = await this.readDb();
    return db.products.find(p => p.id === id) || null;
  }

  async getProductsBySellerId(sellerId: string): Promise<Product[]> {
    const db = await this.readDb();
    return db.products.filter(p => p.sellerId === sellerId);
  }

  async createProduct(productData: CreateProductInput, sellerId: string): Promise<Product> {
    const db = await this.readDb();
    const newProduct: Product = {
      id: `prod-${Date.now()}`,
      ...productData,
      sellerId,
      reviews: [],
    };
    db.products.push(newProduct);
    await this.writeDb(db);
    return newProduct;
  }

  async updateProduct(id: string, productData: UpdateProductInput): Promise<Product | null> {
    const db = await this.readDb();
    const index = db.products.findIndex(p => p.id === id);
    if (index === -1) return null;
    db.products[index] = { ...db.products[index], ...productData };
    await this.writeDb(db);
    return db.products[index];
  }

  async deleteProduct(id: string): Promise<boolean> {
    const db = await this.readDb();
    const initialLength = db.products.length;
    db.products = db.products.filter(p => p.id !== id);
    if (db.products.length < initialLength) {
      await this.writeDb(db);
      return true;
    }
    return false;
  }
    
  async addProductReview(productId: string, reviewData: CreateReviewInput, userId: string): Promise<Review | null> {
    const db = await this.readDb();
    const productIndex = db.products.findIndex(p => p.id === productId);
    if (productIndex === -1) return null;

    const newReview: Review = {
        id: `rev-${Date.now()}`,
        userId,
        ...reviewData,
        createdAt: new Date().toISOString()
    };
    
    db.products[productIndex].reviews.push(newReview);
    await this.writeDb(db);
    return newReview;
  }

  // --- Order Methods ---
  async getOrdersBySellerId(sellerId: string): Promise<Order[]> {
    const db = await this.readDb();
    return db.orders.filter(o => o.sellerId === sellerId);
  }

  async updateOrderStatus(orderId: string, status: string): Promise<Order | null> {
    const db = await this.readDb();
    const index = db.orders.findIndex(o => o.id === orderId);
    if (index === -1) return null;
    db.orders[index].status = status;
    await this.writeDb(db);
    return db.orders[index];
  }
}

export default JsonDbService;