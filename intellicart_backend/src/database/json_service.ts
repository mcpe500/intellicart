import fs from 'fs/promises';
import path from 'path';
import { DbService } from './db_service';
import { User, CreateUserInput } from '../types/UserTypes';
import { Product, CreateProductInput, UpdateProductInput, Review, CreateReviewInput } from '../types/ProductTypes';
import { Order, OrderItem, CreateOrderInput } from '../types/OrderTypes';

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

  async updateUser(id: string, userData: Partial<User>): Promise<User | null> {
    const db = await this.readDb();
    const userIndex = db.users.findIndex(u => u.id === id);
    if (userIndex === -1) return null;
    
    // Update the user with the provided data
    db.users[userIndex] = { 
      ...db.users[userIndex], 
      ...userData 
    };
    
    await this.writeDb(db);
    
    // Return the updated user without the password
    const { password, ...userWithoutPassword } = db.users[userIndex];
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
    const now = new Date().toISOString();
    const newProduct: Product = {
      id: `prod-${Date.now()}`,
      ...productData,
      sellerId,
      createdAt: now,
      updatedAt: now,
      reviews: [],
      averageRating: 0,
    };
    db.products.push(newProduct);
    await this.writeDb(db);
    return newProduct;
  }

  async updateProduct(id: string, productData: UpdateProductInput): Promise<Product | null> {
    const db = await this.readDb();
    const index = db.products.findIndex(p => p.id === id);
    if (index === -1) return null;
    db.products[index] = { 
      ...db.products[index], 
      ...productData, 
      updatedAt: new Date().toISOString() 
    };
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

    // Get user's name for the review
    const user = db.users.find(u => u.id === userId);
    const userName = user ? user.name : 'Anonymous';

    const newReview: Review = {
        id: `rev-${Date.now()}`,
        userId,
        userName,
        title: reviewData.title,
        reviewText: reviewData.reviewText,
        rating: reviewData.rating,
        createdAt: new Date().toISOString()
    };
    
    db.products[productIndex].reviews.push(newReview);
    await this.writeDb(db);
    
    // Update average rating
    const updatedProduct = await this.calculateAverageRating(productId);
    db.products[productIndex].averageRating = updatedProduct;
    await this.writeDb(db);
    
    return newReview;
  }

  async getProductsBySellerIdWithPagination(sellerId: string, page: number = 1, limit: number = 10): Promise<{ products: Product[], pagination: any }> {
    const db = await this.readDb();
    const allProducts = db.products.filter(p => p.sellerId === sellerId);
    const total = allProducts.length;
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + limit;
    const products = allProducts.slice(startIndex, endIndex);

    const pagination = {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit)
    };

    return { products, pagination };
  }

  async calculateAverageRating(productId: string): Promise<number> {
    const db = await this.readDb();
    const product = db.products.find(p => p.id === productId);
    if (!product || product.reviews.length === 0) {
      return 0;
    }

    const sum = product.reviews.reduce((acc, review) => acc + review.rating, 0);
    const average = sum / product.reviews.length;
    return Math.round(average * 100) / 100; // Round to 2 decimal places
  }

  // --- Order Methods ---
  async getOrdersBySellerId(sellerId: string, status?: string): Promise<Order[]> {
    const db = await this.readDb();
    let orders = db.orders.filter(o => o.sellerId === sellerId);
    
    // Apply status filter if provided
    if (status) {
      orders = orders.filter(o => o.status.toLowerCase() === status.toLowerCase());
    }
    
    // Enhance orders with customer names
    for (const order of orders) {
      const customer = db.users.find(u => u.id === order.customerId);
      if (customer) {
        order.customerName = customer.name;
      }
    }
    
    // Enhance order items with product names
    for (const order of orders) {
      for (const item of order.items) {
        const product = db.products.find(p => p.id === item.productId);
        if (product) {
          item.productName = product.name;
        } else {
          item.productName = 'Unknown Product';
        }
      }
    }
    
    return orders;
  }

  async getOrdersByCustomerId(customerId: string, status?: string): Promise<Order[]> {
    const db = await this.readDb();
    let orders = db.orders.filter(o => o.customerId === customerId);
    
    // Apply status filter if provided
    if (status) {
      orders = orders.filter(o => o.status.toLowerCase() === status.toLowerCase());
    }
    
    // Enhance orders with customer names
    for (const order of orders) {
      const customer = db.users.find(u => u.id === order.customerId);
      if (customer) {
        order.customerName = customer.name;
      }
    }
    
    // Enhance order items with product names
    for (const order of orders) {
      for (const item of order.items) {
        const product = db.products.find(p => p.id === item.productId);
        if (product) {
          item.productName = product.name;
        } else {
          item.productName = 'Unknown Product';
        }
      }
    }
    
    return orders;
  }

  async createOrder(orderData: CreateOrderInput): Promise<Order> {
    const db = await this.readDb();
    
    // Enhance items with product names
    const itemsWithNames = orderData.items.map((item: OrderItem) => {
      const product = db.products.find(p => p.id === item.productId);
      return {
        ...item,
        productName: product ? product.name : 'Unknown Product'
      };
    });
    
    // Get customer name
    const customer = db.users.find(u => u.id === orderData.customerId);
    const customerName = customer ? customer.name : 'Unknown Customer';
    
    // Determine sellerId from the first product
    let sellerId = '';
    if (orderData.items.length > 0) {
      const firstProductId = orderData.items[0].productId;
      const product = db.products.find(p => p.id === firstProductId);
      sellerId = product ? product.sellerId : '';
    }
    
    const newOrder: Order = {
      id: `order-${Date.now()}`,
      buyerId: orderData.buyerId,
      customerId: orderData.customerId,
      customerName,
      sellerId,
      total: orderData.total,
      status: 'pending', // default status
      orderDate: new Date().toISOString(),
      items: itemsWithNames
    };
    
    db.orders.push(newOrder);
    await this.writeDb(db);
    
    return newOrder;
  }

  async updateOrderStatus(orderId: string, status: string): Promise<Order | null> {
    const db = await this.readDb();
    const index = db.orders.findIndex(o => o.id === orderId);
    if (index === -1) return null;
    
    db.orders[index].status = status;
    await this.writeDb(db);
    
    // Enhance order with customer name and product names
    const order = db.orders[index];
    const customer = db.users.find(u => u.id === order.customerId);
    if (customer) {
      order.customerName = customer.name;
    }
    
    for (const item of order.items) {
      const product = db.products.find(p => p.id === item.productId);
      if (product) {
        item.productName = product.name;
      } else {
        item.productName = 'Unknown Product';
      }
    }
    
    return order;
  }
}

export default JsonDbService;