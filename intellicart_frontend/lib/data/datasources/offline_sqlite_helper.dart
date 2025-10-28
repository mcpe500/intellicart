// lib/data/datasources/offline_sqlite_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/models/order.dart';
import 'package:intellicart/models/review.dart';
import 'dart:convert';

class OfflineDatabaseHelper {
  static final OfflineDatabaseHelper _instance = OfflineDatabaseHelper._internal();
  factory OfflineDatabaseHelper() => _instance;
  OfflineDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'intellicart_offline.db');
    return await openDatabase(
      path,
      version: 4, // Increased version to clean up any old duplicate data
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        role TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        external_id TEXT, -- For sync with backend, UNIQUE constraint added in version 3
        name TEXT NOT NULL,
        description TEXT,
        price TEXT NOT NULL,
        original_price TEXT,
        image_url TEXT,
        seller_id TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0, -- 0 = not synced, 1 = synced
        sync_status TEXT DEFAULT 'pending' -- pending, synced, error
      )
    ''');

    // Reviews table (separate for better normalization)
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        title TEXT,
        review_text TEXT,
        rating INTEGER,
        time_ago TEXT,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        external_id TEXT, -- For sync with backend, UNIQUE constraint added in version 3
        customer_name TEXT NOT NULL,
        total REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        order_date TEXT,
        seller_id TEXT,
        items_json TEXT, -- JSON representation of items
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0, -- 0 = not synced, 1 = synced
        sync_status TEXT DEFAULT 'pending' -- pending, synced, error
      )
    ''');

    // App state table
    await db.execute('''
      CREATE TABLE app_state (
        id INTEGER PRIMARY KEY,
        app_mode TEXT,
        last_sync_time TEXT,
        user_id TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Pending reviews table for offline submissions
    await db.execute('''
      CREATE TABLE pending_reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT NOT NULL,
        title TEXT NOT NULL,
        review_text TEXT NOT NULL,
        rating INTEGER NOT NULL,
        user_id TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    
    // Initialize app state
    await db.insert('app_state', {
      'id': 1,
      'app_mode': 'buyer',
      'last_sync_time': null,
      'user_id': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle schema upgrades if needed
    if (oldVersion < 2) {
      // Add any new columns or tables for version 2
      await db.execute('ALTER TABLE products ADD COLUMN external_id TEXT UNIQUE');
      await db.execute('ALTER TABLE products ADD COLUMN is_synced INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE products ADD COLUMN sync_status TEXT DEFAULT "pending"');
      
      await db.execute('ALTER TABLE orders ADD COLUMN external_id TEXT UNIQUE');
      await db.execute('ALTER TABLE orders ADD COLUMN is_synced INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE orders ADD COLUMN sync_status TEXT DEFAULT "pending"');
    }
    if (oldVersion < 4) {
      // Add pending_reviews table for version 4
      await db.execute('''
        CREATE TABLE pending_reviews (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id TEXT NOT NULL,
          title TEXT NOT NULL,
          review_text TEXT NOT NULL,
          rating INTEGER NOT NULL,
          user_id TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  // --- App State Methods ---
  Future<void> setAppMode(String mode) async {
    final db = await database;
    await db.update(
      'app_state',
      {
        'app_mode': mode,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<String> getAppMode() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_state',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return maps.first['app_mode'] as String;
    }
    return 'buyer'; // Default to buyer
  }

  Future<void> setCurrentUser(String userId) async {
    final db = await database;
    await db.update(
      'app_state',
      {
        'user_id': userId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<String?> getCurrentUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_state',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return maps.first['user_id'] as String?;
    }
    return null;
  }

  Future<void> setLastSyncTime() async {
    final db = await database;
    await db.update(
      'app_state',
      {
        'last_sync_time': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<String?> getLastSyncTime() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_state',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return maps.first['last_sync_time'] as String?;
    }
    return null;
  }

  // --- Product Methods ---
  Future<void> insertProducts(List<Product> products) async {
    final db = await database;
    
    // Wrap in a transaction to ensure consistency
    await db.transaction((txn) async {
      // Clear existing products and reviews to avoid duplicates on sync
      await txn.delete('reviews');
      await txn.delete('products');
      
      // Insert all products and their reviews
      for (var product in products) {
        // Insert product individually to get its local ID
        int localProductId = await txn.insert('products', {
          'external_id': product.id?.toString(),
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'original_price': product.originalPrice,
          'image_url': product.imageUrl,
          'seller_id': product.sellerId,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_synced': 1, // These come from backend, so they're synced
          'sync_status': 'synced',
        });
        
        // Insert all reviews for this product
        for (var review in product.reviews) {
          await txn.insert('reviews', {
            'product_id': localProductId,
            'title': review.title,
            'review_text': review.reviewText,
            'rating': review.rating,
            'time_ago': review.timeAgo,
          });
        }
      }
    });
  }

  Future<void> insertProduct(Product product, {bool isLocal = true}) async {
    final db = await database;
    Batch batch = db.batch();
    
    // Insert product
    int productId = await db.insert('products', {
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'original_price': product.originalPrice,
      'image_url': product.imageUrl,
      'seller_id': product.sellerId,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': isLocal ? 0 : 1, // Local changes need sync
      'sync_status': isLocal ? 'pending' : 'synced',
    });
    
    // Insert reviews
    for (var review in product.reviews) {
      batch.insert('reviews', {
        'product_id': productId,
        'title': review.title,
        'review_text': review.reviewText,
        'rating': review.rating,
        'time_ago': review.timeAgo,
      });
    }
    
    await batch.commit();
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    
    // Join products with reviews
    final List<Map<String, dynamic>> productMaps = await db.query('products');
    List<Product> products = [];
    
    for (var productMap in productMaps) {
      // Get reviews for this product
      final List<Map<String, dynamic>> reviewMaps = await db.query(
        'reviews',
        where: 'product_id = ?',
        whereArgs: [productMap['id']],
      );
      
      List<Review> reviews = reviewMaps.map((reviewMap) => Review(
        title: reviewMap['title'],
        reviewText: reviewMap['review_text'],
        rating: reviewMap['rating'],
        timeAgo: reviewMap['time_ago'],
      )).toList();
      
      products.add(Product(
        id: productMap['external_id'] ?? productMap['id'].toString(),
        name: productMap['name'],
        description: productMap['description'],
        price: productMap['price'],
        originalPrice: productMap['original_price'],
        imageUrl: productMap['image_url'],
        sellerId: productMap['seller_id'],
        reviews: reviews,
      ));
    }
    
    return products;
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    
    final List<Map<String, dynamic>> productMaps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (productMaps.isEmpty) return null;
    
    var productMap = productMaps.first;
    
    // Get reviews for this product
    final List<Map<String, dynamic>> reviewMaps = await db.query(
      'reviews',
      where: 'product_id = ?',
      whereArgs: [id],
    );
    
    List<Review> reviews = reviewMaps.map((reviewMap) => Review(
      title: reviewMap['title'],
      reviewText: reviewMap['review_text'],
      rating: reviewMap['rating'],
      timeAgo: reviewMap['time_ago'],
    )).toList();
    
    return Product(
      id: productMap['external_id'] ?? productMap['id'].toString(),
      name: productMap['name'],
      description: productMap['description'],
      price: productMap['price'],
      originalPrice: productMap['original_price'],
      imageUrl: productMap['image_url'],
      sellerId: productMap['seller_id'],
      reviews: reviews,
    );
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    
    await db.update(
      'products',
      {
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'original_price': product.originalPrice,
        'image_url': product.imageUrl,
        'seller_id': product.sellerId,
        'updated_at': DateTime.now().toIso8601String(),
        'is_synced': 0, // Mark as needing sync
        'sync_status': 'pending',
      },
      where: 'external_id = ? OR id = ?',
      whereArgs: [product.id, int.tryParse(product.id ?? '')],
    );
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    
    // Delete associated reviews
    await db.delete('reviews', where: 'product_id = ?', whereArgs: [id]);
    
    // Delete product
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Get products that need to be synced to the backend
  Future<List<Product>> getProductsPendingSync() async {
    final db = await database;
    final List<Map<String, dynamic>> productMaps = await db.query(
      'products',
      where: 'is_synced = ? AND sync_status = ?',
      whereArgs: [0, 'pending'],
    );
    
    List<Product> products = [];
    for (var productMap in productMaps) {
      // Get reviews for this product
      final List<Map<String, dynamic>> reviewMaps = await db.query(
        'reviews',
        where: 'product_id = ?',
        whereArgs: [productMap['id']],
      );
      
      List<Review> reviews = reviewMaps.map((reviewMap) => Review(
        title: reviewMap['title'],
        reviewText: reviewMap['review_text'],
        rating: reviewMap['rating'],
        timeAgo: reviewMap['time_ago'],
      )).toList();
      
      products.add(Product(
        id: productMap['id'].toString(), // Use local ID for pending sync
        name: productMap['name'],
        description: productMap['description'],
        price: productMap['price'],
        originalPrice: productMap['original_price'],
        imageUrl: productMap['image_url'],
        sellerId: productMap['seller_id'],
        reviews: reviews,
      ));
    }
    
    return products;
  }

  // Mark a product as synced
  Future<void> markProductAsSynced(String localId, String backendId) async {
    final db = await database;
    
    await db.update(
      'products',
      {
        'external_id': backendId,
        'is_synced': 1,
        'sync_status': 'synced',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // Mark a product sync as failed
  Future<void> markProductSyncFailed(String localId) async {
    final db = await database;
    
    await db.update(
      'products',
      {
        'sync_status': 'error',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // --- Pending Review Methods ---
  Future<void> addPendingReview(String productId, Review review, String userId) async {
    final db = await database;
    await db.insert('pending_reviews', {
      'product_id': productId,
      'title': review.title,
      'review_text': review.reviewText,
      'rating': review.rating,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingReviews() async {
    final db = await database;
    return await db.query('pending_reviews');
  }

  Future<void> deletePendingReview(int id) async {
    final db = await database;
    await db.delete('pending_reviews', where: 'id = ?', whereArgs: [id]);
  }

  // --- Order Methods ---
  Future<void> insertOrders(List<Order> orders) async {
    final db = await database;
    
    for (var order in orders) {
      await db.insert('orders', {
        'external_id': order.id,
        'customer_name': order.customerName,
        'total': order.total,
        'status': order.status,
        'order_date': order.orderDate.toIso8601String(),
        'seller_id': order.sellerId,
        'items_json': jsonEncode(order.items.map((item) => item.toJson()).toList()),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_synced': 1, // These come from backend, so they're synced
        'sync_status': 'synced',
      });
    }
  }

  Future<void> insertOrder(Order order, {bool isLocal = true}) async {
    final db = await database;
    
    await db.insert('orders', {
      'customer_name': order.customerName,
      'total': order.total,
      'status': order.status,
      'order_date': order.orderDate.toIso8601String(),
      'seller_id': order.sellerId,
      'items_json': jsonEncode(order.items.map((item) => item.toJson()).toList()),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': isLocal ? 0 : 1, // Local changes need sync
      'sync_status': isLocal ? 'pending' : 'synced',
    });
  }

  Future<List<Order>> getOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> orderMaps = await db.query('orders');
    
    List<Order> orders = [];
    for (var orderMap in orderMaps) {
      List<dynamic> itemsJson = jsonDecode(orderMap['items_json'] as String);
      
      List<Product> items = itemsJson.map((itemJson) => Product.fromJson(itemJson)).toList();
      
      orders.add(Order(
        id: orderMap['external_id'] ?? orderMap['id'].toString(),
        customerName: orderMap['customer_name'],
        total: orderMap['total'],
        status: orderMap['status'],
        orderDate: orderMap['order_date'] != null ? DateTime.parse(orderMap['order_date']) : DateTime.now(),
        sellerId: orderMap['seller_id'],
        items: items,
      ));
    }
    
    return orders;
  }

  // Get orders that need to be synced to the backend
  Future<List<Order>> getOrdersPendingSync() async {
    final db = await database;
    final List<Map<String, dynamic>> orderMaps = await db.query(
      'orders',
      where: 'is_synced = ? AND sync_status = ?',
      whereArgs: [0, 'pending'],
    );
    
    List<Order> orders = [];
    for (var orderMap in orderMaps) {
      List<dynamic> itemsJson = jsonDecode(orderMap['items_json'] as String);
      List<Product> items = itemsJson.map((itemJson) => Product.fromJson(itemJson)).toList();
      
      orders.add(Order(
        id: orderMap['id'].toString(), // Use local ID for pending sync
        customerName: orderMap['customer_name'],
        total: orderMap['total'],
        status: orderMap['status'],
        orderDate: orderMap['order_date'] != null ? DateTime.parse(orderMap['order_date']) : DateTime.now(),
        sellerId: orderMap['seller_id'],
        items: items,
      ));
    }
    
    return orders;
  }

  // Mark an order as synced
  Future<void> markOrderAsSynced(String localId, String backendId) async {
    final db = await database;
    
    await db.update(
      'orders',
      {
        'external_id': backendId,
        'is_synced': 1,
        'sync_status': 'synced',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // Mark an order sync as failed
  Future<void> markOrderSyncFailed(String localId) async {
    final db = await database;
    
    await db.update(
      'orders',
      {
        'sync_status': 'error',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // --- Sync Utilities ---
  Future<void> resetSyncStatus() async {
    final db = await database;
    
    // Reset all pending sync items to pending status
    await db.update('products', {'sync_status': 'pending', 'is_synced': 0}, where: 'sync_status = ?', whereArgs: ['error']);
    await db.update('orders', {'sync_status': 'pending', 'is_synced': 0}, where: 'sync_status = ?', whereArgs: ['error']);
  }
}