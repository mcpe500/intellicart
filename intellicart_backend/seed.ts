/**
 * Database Seed Script
 * 
 * This script populates the database with realistic product data for Intellicart.
 * It creates various products across different categories to provide realistic
 * data for the frontend to consume.
 * 
 * @file Product seed script
 * @author Intellicart Team
 * @version 1.0.0
 */

import { dbManager } from './src/database/Config';
import bcrypt from 'bcryptjs';

async function seedDatabase() {
  try {
    console.log('Starting database seeding...');

    // Initialize the database
    await dbManager.initialize();
    const db = dbManager.getDatabase();

    // Clear existing data using the new clearTable method (cast to JSONDatabase to access it)
    await (db as any).clearTable('products');
    await (db as any).clearTable('users');
    await (db as any).clearTable('orders');

    // Create sample users (let the database assign IDs)
    const passwordHash = await bcrypt.hash('password123', 10);
    const adminUser = {
      name: 'Admin User',
      email: 'admin@intellicart.com',
      password: passwordHash,
      role: 'admin',
      createdAt: new Date().toISOString(),
    };

    const sellerUser = {
      name: 'Seller User',
      email: 'seller@intellicart.com',
      password: passwordHash,
      role: 'seller',
      createdAt: new Date().toISOString(),
    };

    const buyerUser = {
      name: 'Buyer User',
      email: 'buyer@intellicart.com',
      password: passwordHash,
      role: 'buyer',
      createdAt: new Date().toISOString(),
    };

    const createdAdmin = await db.create('users', adminUser);
    const createdSeller = await db.create('users', sellerUser);
    const createdBuyer = await db.create('users', buyerUser);

    // Use the dynamically created seller ID
    const sellerId = createdSeller.id;

    // Create realistic product data (let the database assign IDs)
    const products = [
      {
        name: 'Wireless Bluetooth Headphones',
        description: 'High-quality wireless headphones with noise cancellation technology, premium sound quality, and 30-hour battery life. Perfect for music lovers and professionals.',
        price: '89.99',
        originalPrice: '129.99',
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
        sellerId: sellerId,
        reviews: [
          { id: 1, title: 'Excellent sound quality', reviewText: 'Best headphones I have ever used. Sound quality is amazing.', rating: 5, timeAgo: '2 days ago' },
          { id: 2, title: 'Great battery life', reviewText: 'Battery lasts all day, very comfortable for long listening sessions.', rating: 4, timeAgo: '1 week ago' }
        ],
        createdAt: new Date().toISOString()
      },
      {
        name: 'Smart Fitness Watch',
        description: 'Advanced fitness tracking watch with heart rate monitor, GPS, sleep tracking, and smartphone notifications. Water resistant up to 50 meters.',
        price: '149.99',
        originalPrice: '199.99',
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
        sellerId: sellerId,
        reviews: [
          { id: 1, title: 'Perfect for workouts', reviewText: 'Accurate tracking and comfortable to wear during exercise.', rating: 5, timeAgo: '3 days ago' },
          { id: 2, title: 'Great features', reviewText: 'Love all the health tracking features.', rating: 4, timeAgo: '1 week ago' }
        ],
        createdAt: new Date().toISOString()
      },
      {
        name: 'Professional Coffee Maker',
        description: 'Premium espresso machine with built-in grinder, milk frother, and programmable settings. Creates café-quality coffee at home.',
        price: '299.99',
        originalPrice: '399.99',
        imageUrl: 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
        sellerId: sellerId,
        reviews: [
          { id: 1, title: 'Best coffee maker', reviewText: 'Produces amazing espresso every time.', rating: 5, timeAgo: '5 days ago' },
          { id: 2, title: 'Worth the investment', reviewText: 'Definitely improved my morning routine.', rating: 5, timeAgo: '2 weeks ago' }
        ],
        createdAt: new Date().toISOString()
      },
      {
        name: 'Gaming Mechanical Keyboard',
        description: 'RGB backlit mechanical keyboard with blue switches, programmable macro keys, and durable construction. Perfect for gaming enthusiasts.',
        price: '79.99',
        originalPrice: '99.99',
        imageUrl: 'https://images.unsplash.com/photo-1544036738-871b5eabc8d0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
        sellerId: sellerId,
        reviews: [
          { id: 1, title: 'Great for gaming', reviewText: 'Perfect feel and responsive keys for fast gaming.', rating: 5, timeAgo: '1 day ago' },
          { id: 2, title: 'Quality construction', reviewText: 'Built to last with premium materials.', rating: 4, timeAgo: '4 days ago' }
        ],
        createdAt: new Date().toISOString()
      },
      {
        name: 'Ergonomic Office Chair',
        description: 'Comfortable ergonomic office chair with lumbar support, adjustable height, and breathable mesh back. Reduces back pain during long work sessions.',
        price: '199.99',
        originalPrice: '249.99',
        imageUrl: 'https://images.unsplash.com/photo-1592078615290-033ee584e267?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
        sellerId: sellerId,
        reviews: [
          { id: 1, title: 'Perfect for work', reviewText: 'Comfortable for long hours at desk.', rating: 5, timeAgo: '1 week ago' },
          { id: 2, title: 'Good support', reviewText: 'Helped reduce my back pain significantly.', rating: 4, timeAgo: '2 weeks ago' }
        ],
        createdAt: new Date().toISOString()
      },
      {
        name: '4K Ultra HD Smart TV',
        description: '55-inch 4K Ultra HD Smart TV with HDR, smart streaming apps, and voice control. Provides stunning picture quality and immersive viewing experience.',
        price: '499.99',
        originalPrice: '699.99',
        imageUrl: 'https://images.unsplash.com/photo-1593305841991-05c297ba4575?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
        sellerId: sellerId,
        reviews: [
          { id: 1, title: 'Amazing picture quality', reviewText: 'Colors are vibrant and picture is crystal clear.', rating: 5, timeAgo: '3 days ago' },
          { id: 2, title: 'Great value for money', reviewText: 'High quality TV at a reasonable price.', rating: 5, timeAgo: '1 week ago' }
        ],
        createdAt: new Date().toISOString()
      },
      {
        name: 'Professional DSLR Camera',
        description: '24.2 MP DSLR camera with 4K video, built-in WiFi, and 45-point autofocus system. Perfect for photography enthusiasts and professionals.',
        price: '599.99',
        originalPrice: '799.99',
        imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
        sellerId: sellerId,
        reviews: [
          { id: 1, title: 'Professional quality', reviewText: 'Takes stunning photos with excellent detail.', rating: 5, timeAgo: '1 day ago' },
          { id: 2, title: 'Great for beginners too', reviewText: 'Easy to use with excellent automatic modes.', rating: 4, timeAgo: '5 days ago' }
        ],
        createdAt: new Date().toISOString()
      },
      {
        name: 'Stainless Steel Cookware Set',
        description: '10-piece professional cookware set with stainless steel construction, even heat distribution, and oven safe up to 500°F. Perfect for home chefs.',
        price: '149.99',
        originalPrice: '199.99',
        imageUrl: 'https://images.unsplash.com/photo-1605275852543-b4656e22d784?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80',
        sellerId: sellerId,
        reviews: [
          { id: 1, title: 'Excellent cooking performance', reviewText: 'Heats evenly and cleans easily.', rating: 5, timeAgo: '2 days ago' },
          { id: 2, title: 'Great set for the price', reviewText: 'All the pots and pans I need for cooking.', rating: 4, timeAgo: '1 week ago' }
        ],
        createdAt: new Date().toISOString()
      }
    ];

    // Insert products into the database
    for (const product of products) {
      await db.create('products', product);
    }

    console.log('Database seeding completed successfully!');
    console.log(`Created ${products.length} products`);
    console.log(`Created 3 users (IDs: ${createdAdmin.id}, ${createdSeller.id}, ${createdBuyer.id})`);
    
    // Close the database connection
    if (db.close) {
      await db.close();
    }
  } catch (error) {
    console.error('Error during database seeding:', error);
    process.exit(1);
  }
}

// Run the seed function
seedDatabase();