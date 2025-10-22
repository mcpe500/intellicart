import admin from 'firebase-admin';
import { DbService } from './db_service';
import { User, CreateUserInput } from '../types/UserTypes';
import { Product, CreateProductInput, UpdateProductInput, Review, CreateReviewInput } from '../types/ProductTypes';
import { Order, OrderItem, UpdateOrderInput, CreateOrderInput } from '../types/OrderTypes';

class FirestoreDbService implements DbService {
  private db: admin.firestore.Firestore;

  constructor() {
    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.applicationDefault(),
      });
    }
    this.db = admin.firestore();
  }

  // --- User Methods ---
  async getUserById(id: string): Promise<User | null> {
    const userDoc = await this.db.collection('users').doc(id).get();
    if (!userDoc.exists) return null;
    
    const userData = userDoc.data();
    if (userData) {
      const { password, ...userWithoutPassword } = userData as any;
      return userWithoutPassword as User;
    }
    return null;
  }

  async getUserByEmail(email: string): Promise<User | null> {
    const snapshot = await this.db.collection('users').where('email', '==', email).get();
    if (snapshot.empty) return null;
    
    const doc = snapshot.docs[0];
    const userData = doc.data();
    return userData as User;
  }

  async createUser(userData: CreateUserInput): Promise<User> {
    const id = `user-${Date.now()}`;
    const now = new Date().toISOString();
    const newUser: User & { password: string } = {
      id,
      name: userData.name,
      email: userData.email,
      role: userData.role || 'buyer',
      createdAt: now,
      password: userData.password,
    };
    
    await this.db.collection('users').doc(id).set(newUser);
    
    const { password, ...userWithoutPassword } = newUser;
    return userWithoutPassword;
  }

  async updateUser(id: string, userData: Partial<User>): Promise<User | null> {
    const userRef = this.db.collection('users').doc(id);
    const doc = await userRef.get();
    
    if (!doc.exists) return null;
    
    // Update only the fields provided in userData
    await userRef.update(userData);
    
    // Fetch and return updated document
    const updatedDoc = await userRef.get();
    const updatedData = updatedDoc.data() as User;
    
    // Remove password from the returned user object
    const { password, ...userWithoutPassword } = updatedData;
    return userWithoutPassword;
  }

  // --- Product Methods ---
  async getAllProducts(): Promise<Product[]> {
    const snapshot = await this.db.collection('products').get();
    return snapshot.docs.map(doc => doc.data() as Product);
  }

  async getProductById(id: string): Promise<Product | null> {
    const productDoc = await this.db.collection('products').doc(id).get();
    return productDoc.exists ? productDoc.data() as Product : null;
  }

  async getProductsBySellerId(sellerId: string): Promise<Product[]> {
    const snapshot = await this.db.collection('products').where('sellerId', '==', sellerId).get();
    return snapshot.docs.map(doc => doc.data() as Product);
  }

  async getProductsBySellerIdWithPagination(sellerId: string, page: number = 1, limit: number = 10): Promise<{ products: Product[], pagination: any }> {
    const offset = (page - 1) * limit;
    const snapshot = await this.db.collection('products')
      .where('sellerId', '==', sellerId)
      .offset(offset)
      .limit(limit)
      .get();
    
    const products = snapshot.docs.map(doc => doc.data() as Product);
    
    // Get the total count
    const countSnapshot = await this.db.collection('products').where('sellerId', '==', sellerId).count().get();
    const total = countSnapshot.data().count;
    
    const pagination = {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit)
    };

    return { products, pagination };
  }

  async createProduct(productData: CreateProductInput, sellerId: string): Promise<Product> {
    const id = `prod-${Date.now()}`;
    const now = new Date().toISOString();
    const newProduct: Product = {
      id,
      ...productData,
      sellerId,
      createdAt: now,
      updatedAt: now,
      reviews: [],
      averageRating: 0,
    };
    
    await this.db.collection('products').doc(id).set(newProduct);
    return newProduct;
  }

  async updateProduct(id: string, productData: UpdateProductInput): Promise<Product | null> {
    const productRef = this.db.collection('products').doc(id);
    const doc = await productRef.get();
    
    if (!doc.exists) return null;
    
    const updateData = {
      ...productData,
      updatedAt: new Date().toISOString()
    };
    
    await productRef.update(updateData);
    
    // Fetch and return updated document
    const updatedDoc = await productRef.get();
    return updatedDoc.data() as Product;
  }

  async deleteProduct(id: string): Promise<boolean> {
    const productRef = this.db.collection('products').doc(id);
    const doc = await productRef.get();
    
    if (!doc.exists) return false;
    
    await productRef.delete();
    return true;
  }

  async addProductReview(productId: string, reviewData: CreateReviewInput, userId: string): Promise<Review | null> {
    const productRef = this.db.collection('products').doc(productId);
    const productDoc = await productRef.get();
    
    if (!productDoc.exists) return null;
    
    // Get user's name for the review
    const userDoc = await this.db.collection('users').doc(userId).get();
    const userName = userDoc.exists ? (userDoc.data() as User).name : 'Anonymous';
    
    const newReview: Review = {
      id: `rev-${Date.now()}`,
      userId,
      userName,
      title: reviewData.title,
      reviewText: reviewData.reviewText,
      rating: reviewData.rating,
      createdAt: new Date().toISOString()
    };
    
    // Add review and update average rating
    const productData = productDoc.data() as Product;
    const reviews = [...(productData.reviews || []), newReview];
    const averageRating = this.calculateAverageRatingFromReviews(reviews);
    
    await productRef.update({
      reviews,
      averageRating
    });
    
    return newReview;
  }

  async calculateAverageRating(productId: string): Promise<number> {
    const productDoc = await this.db.collection('products').doc(productId).get();
    if (!productDoc.exists) return 0;
    
    const productData = productDoc.data() as Product;
    if (!productData.reviews || productData.reviews.length === 0) {
      return 0;
    }
    
    const sum = productData.reviews.reduce((acc, review) => acc + review.rating, 0);
    const average = sum / productData.reviews.length;
    return Math.round(average * 100) / 100; // Round to 2 decimal places
  }

  private calculateAverageRatingFromReviews(reviews: Review[]): number {
    if (!reviews || reviews.length === 0) {
      return 0;
    }
    
    const sum = reviews.reduce((acc, review) => acc + review.rating, 0);
    const average = sum / reviews.length;
    return Math.round(average * 100) / 100; // Round to 2 decimal places
  }

  // --- Order Methods ---
  async getOrdersBySellerId(sellerId: string, status?: string): Promise<Order[]> {
    let query = this.db.collection('orders').where('sellerId', '==', sellerId);
    
    if (status) {
      query = query.where('status', '==', status);
    }
    
    const snapshot = await query.get();
    const orders = snapshot.docs.map(doc => doc.data() as Order);
    
    // Enhance orders with customer names
    for (const order of orders) {
      const customerDoc = await this.db.collection('users').doc(order.customerId).get();
      if (customerDoc.exists) {
        const customer = customerDoc.data() as User;
        order.customerName = customer.name;
      }
    }
    
    // Enhance order items with product names
    for (const order of orders) {
      for (const item of order.items) {
        const productDoc = await this.db.collection('products').doc(item.productId).get();
        if (productDoc.exists) {
          const product = productDoc.data() as Product;
          item.productName = product.name;
        } else {
          item.productName = 'Unknown Product';
        }
      }
    }
    
    return orders;
  }

  async getOrdersByCustomerId(customerId: string, status?: string): Promise<Order[]> {
    let query = this.db.collection('orders').where('customerId', '==', customerId);
    
    if (status) {
      query = query.where('status', '==', status);
    }
    
    const snapshot = await query.get();
    const orders = snapshot.docs.map(doc => doc.data() as Order);
    
    // Enhance orders with customer names
    for (const order of orders) {
      const customerDoc = await this.db.collection('users').doc(order.customerId).get();
      if (customerDoc.exists) {
        const customer = customerDoc.data() as User;
        order.customerName = customer.name;
      }
    }
    
    // Enhance order items with product names
    for (const order of orders) {
      for (const item of order.items) {
        const productDoc = await this.db.collection('products').doc(item.productId).get();
        if (productDoc.exists) {
          const product = productDoc.data() as Product;
          item.productName = product.name;
        } else {
          item.productName = 'Unknown Product';
        }
      }
    }
    
    return orders;
  }

  async createOrder(orderData: CreateOrderInput): Promise<Order> {
    // Enhance items with product names
    const itemsWithNames = await Promise.all(orderData.items.map(async (item: OrderItem) => {
      const productDoc = await this.db.collection('products').doc(item.productId).get();
      if (productDoc.exists) {
        const product = productDoc.data() as Product;
        return {
          ...item,
          productName: product.name
        };
      } else {
        return {
          ...item,
          productName: 'Unknown Product'
        };
      }
    }));
    
    // Get customer name
    const customerDoc = await this.db.collection('users').doc(orderData.customerId).get();
    let customerName = 'Unknown Customer';
    if (customerDoc.exists) {
      const customer = customerDoc.data() as User;
      customerName = customer.name;
    }
    
    // Determine sellerId from the first product
    let sellerId = '';
    if (orderData.items.length > 0) {
      const firstProductId = orderData.items[0].productId;
      const productDoc = await this.db.collection('products').doc(firstProductId).get();
      if (productDoc.exists) {
        const product = productDoc.data() as Product;
        sellerId = product.sellerId;
      }
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
    
    await this.db.collection('orders').doc(newOrder.id).set(newOrder);
    
    return newOrder;
  }

  async updateOrderStatus(orderId: string, status: string): Promise<Order | null> {
    const orderRef = this.db.collection('orders').doc(orderId);
    const doc = await orderRef.get();
    
    if (!doc.exists) return null;
    
    await orderRef.update({ status });
    
    // Fetch and return updated document
    const updatedDoc = await orderRef.get();
    const order = updatedDoc.data() as Order;
    
    // Enhance order with customer name
    const customerDoc = await this.db.collection('users').doc(order.customerId).get();
    if (customerDoc.exists) {
      const customer = customerDoc.data() as User;
      order.customerName = customer.name;
    }
    
    // Enhance order items with product names
    for (const item of order.items) {
      const productDoc = await this.db.collection('products').doc(item.productId).get();
      if (productDoc.exists) {
        const product = productDoc.data() as Product;
        item.productName = product.name;
      } else {
        item.productName = 'Unknown Product';
      }
    }
    
    return order;
  }
}

export default FirestoreDbService;