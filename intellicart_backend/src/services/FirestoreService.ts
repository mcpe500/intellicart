import admin from 'firebase-admin';
import { ServiceAccount } from 'firebase-admin';
import dotenv from 'dotenv';
import { DbService } from '../database/db_service';
import { User, CreateUserInput } from '../types/UserTypes';
import { Product, CreateProductInput, UpdateProductInput, Review, CreateReviewInput } from '../types/ProductTypes';
import { Order } from '../types/OrderTypes';

// Load environment variables
dotenv.config();

class FirestoreService implements DbService {
  private db: admin.firestore.Firestore;

  constructor() {
    if (!admin.apps.length) {
      const serviceAccount: ServiceAccount = {
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: (process.env.FIREBASE_PRIVATE_KEY || '').replace(/\\n/g, '\n'),
      };
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: process.env.FIREBASE_DATABASE_URL,
      });
    }
    this.db = admin.firestore();
  }

  // --- User Methods ---
  async getUserById(id: string): Promise<User | null> {
    const doc = await this.db.collection('users').doc(id).get();
    if (!doc.exists) return null;
    const data = doc.data()!;
    // Exclude password
    const { password, ...user } = data;
    return { id: doc.id, ...user } as User;
  }

  async getUserByEmail(email: string): Promise<(User & { password?: string }) | null> {
    const snapshot = await this.db.collection('users').where('email', '==', email).limit(1).get();
    if (snapshot.empty) return null;
    const doc = snapshot.docs[0];
    return { id: doc.id, ...doc.data() } as User & { password?: string };
  }

  async createUser(userData: CreateUserInput): Promise<User> {
    const { id } = await this.db.collection('users').add({
      ...userData,
      createdAt: new Date().toISOString(),
    });
    const newUser = await this.getUserById(id);
    return newUser!;
  }

  // --- Product Methods ---
  async getAllProducts(): Promise<Product[]> {
    const snapshot = await this.db.collection('products').get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Product));
  }

  async getProductById(id: string): Promise<Product | null> {
    const doc = await this.db.collection('products').doc(id).get();
    if (!doc.exists) return null;
    return { id: doc.id, ...doc.data() } as Product;
  }

  async getProductsBySellerId(sellerId: string): Promise<Product[]> {
    const snapshot = await this.db.collection('products').where('sellerId', '==', sellerId).get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Product));
  }

  async createProduct(productData: CreateProductInput, sellerId: string): Promise<Product> {
    const docRef = await this.db.collection('products').add({
      ...productData,
      sellerId,
      reviews: [],
    });
    const newProduct = await this.getProductById(docRef.id);
    return newProduct!;
  }

  async updateProduct(id: string, productData: UpdateProductInput): Promise<Product | null> {
    const docRef = this.db.collection('products').doc(id);
    await docRef.update(productData);
    return this.getProductById(id);
  }

  async deleteProduct(id: string): Promise<boolean> {
    await this.db.collection('products').doc(id).delete();
    return true;
  }
    
  async addProductReview(productId: string, reviewData: CreateReviewInput, userId: string): Promise<Review | null> {
    const productRef = this.db.collection('products').doc(productId);
    const newReview: Review = {
        id: `rev-${Date.now()}`, // Simple ID for this example
        userId,
        ...reviewData,
        createdAt: new Date().toISOString()
    };

    await productRef.update({
        reviews: admin.firestore.FieldValue.arrayUnion(newReview)
    });
    
    return newReview;
  }

  // --- Order Methods ---
  async getOrdersBySellerId(sellerId: string): Promise<Order[]> {
    const snapshot = await this.db.collection('orders').where('sellerId', '==', sellerId).get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Order));
  }
  
  async updateOrderStatus(orderId: string, status: string): Promise<Order | null> {
      const docRef = this.db.collection('orders').doc(orderId);
      await docRef.update({ status });
      const updatedDoc = await docRef.get();
      if (!updatedDoc.exists) return null;
      return { id: updatedDoc.id, ...updatedDoc.data() } as Order;
  }
}

export default FirestoreService;