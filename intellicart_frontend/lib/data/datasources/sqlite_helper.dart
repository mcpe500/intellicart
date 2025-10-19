// lib/data/datasources/sqlite_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intellicart_frontend/models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'intellicart.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price TEXT,
        originalPrice TEXT,
        imageUrl TEXT
      )
    ''');
    // NOTE: Reviews would be in a separate table in a real app,
    // linked by a product_id foreign key. For this implementation,
    // they remain in the product model for simplicity.

    await db.execute('''
      CREATE TABLE app_state (
        id INTEGER PRIMARY KEY,
        appMode TEXT
      )
    ''');
    // Initialize with Buyer mode
    await db.insert('app_state', {'id': 1, 'appMode': 'buyer'});
    
    // Create shopping cart table
    await db.execute('''
      CREATE TABLE shopping_cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        price TEXT,
        imageUrl TEXT,
        quantity INTEGER DEFAULT 1,
        UNIQUE(productId)
      )
    ''');
    
    // Create user preferences table
    await db.execute('''
      CREATE TABLE user_preferences (
        id INTEGER PRIMARY KEY,
        language TEXT DEFAULT 'en',
        theme TEXT DEFAULT 'light',
        notifications_enabled INTEGER DEFAULT 1
      )
    ''');
    // Initialize user preferences
    await db.insert('user_preferences', {
      'id': 1, 
      'language': 'en',
      'theme': 'light',
      'notifications_enabled': 1
    });
    
    // Create recently viewed products table
    await db.execute('''
      CREATE TABLE recently_viewed (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        price TEXT,
        imageUrl TEXT,
        viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add shopping cart table
      await db.execute('''
        CREATE TABLE shopping_cart (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          price TEXT,
          imageUrl TEXT,
          quantity INTEGER DEFAULT 1,
          UNIQUE(productId)
        )
      ''');
      
      // Add user preferences table
      await db.execute('''
        CREATE TABLE user_preferences (
          id INTEGER PRIMARY KEY,
          language TEXT DEFAULT 'en',
          theme TEXT DEFAULT 'light',
          notifications_enabled INTEGER DEFAULT 1
        )
      ''');
      await db.insert('user_preferences', {
        'id': 1, 
        'language': 'en',
        'theme': 'light',
        'notifications_enabled': 1
      });
      
      // Add recently viewed products table
      await db.execute('''
        CREATE TABLE recently_viewed (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          price TEXT,
          imageUrl TEXT,
          viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    }
  }

  // --- App Mode Methods ---
  Future<void> setAppMode(String mode) async {
    final db = await database;
    await db.update(
      'app_state',
      {'appMode': mode},
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
      return maps.first['appMode'] as String;
    }
    return 'buyer'; // Default to buyer
  }

  // --- Product Methods ---
  Future<void> insertProducts(List<Product> products) async {
    final db = await database;
    Batch batch = db.batch();
    // Clear existing products to avoid duplicates on app restart
    batch.delete('products');
    for (var product in products) {
      batch.insert('products', {
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'originalPrice': product.originalPrice,
        'imageUrl': product.imageUrl,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');

    return List.generate(maps.length, (i) {
      return Product(
        name: maps[i]['name'],
        description: maps[i]['description'],
        price: maps[i]['price'],
        originalPrice: maps[i]['originalPrice'],
        imageUrl: maps[i]['imageUrl'],
        reviews: [], // Reviews would be fetched from their own table
      );
    });
  }

  // --- Shopping Cart Methods ---
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final db = await database;
    await db.insert(
      'shopping_cart',
      {
        'productId': product.id ?? product.name, // Use name as fallback if id is null
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'quantity': quantity,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Update if product already in cart
    );
  }

  Future<void> updateCartItemQuantity(String productId, int quantity) async {
    final db = await database;
    await db.update(
      'shopping_cart',
      {'quantity': quantity},
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<void> removeFromCart(String productId) async {
    final db = await database;
    await db.delete(
      'shopping_cart',
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return await db.query('shopping_cart');
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('shopping_cart');
  }

  Future<int> getCartItemCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM shopping_cart');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // --- User Preferences Methods ---
  Future<void> setLanguage(String language) async {
    final db = await database;
    await db.update(
      'user_preferences',
      {'language': language},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<String> getLanguage() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_preferences',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return maps.first['language'] as String;
    }
    return 'en'; // Default to English
  }

  Future<void> setTheme(String theme) async {
    final db = await database;
    await db.update(
      'user_preferences',
      {'theme': theme},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<String> getTheme() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_preferences',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return maps.first['theme'] as String;
    }
    return 'light'; // Default to light theme
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final db = await database;
    await db.update(
      'user_preferences',
      {'notifications_enabled': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<bool> getNotificationsEnabled() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_preferences',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return maps.first['notifications_enabled'] == 1;
    }
    return true; // Default to enabled
  }

  // --- Recently Viewed Products Methods ---
  Future<void> addRecentlyViewed(Product product) async {
    final db = await database;
    
    // First, try to delete any existing entry for this product to update the timestamp
    await db.delete(
      'recently_viewed',
      where: 'productId = ?',
      whereArgs: [product.id ?? product.name],
    );
    
    // Add the product to recently viewed
    await db.insert(
      'recently_viewed',
      {
        'productId': product.id ?? product.name, // Use name as fallback if id is null
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
      },
    );
    
    // Limit to last 20 viewed items
    final results = await db.rawQuery(
      'SELECT id FROM recently_viewed ORDER BY viewed_at DESC LIMIT -1 OFFSET 20'
    );
    if (results.isNotEmpty) {
      final ids = results.map((m) => m['id'] as int).toList();
      await db.delete(
        'recently_viewed',
        where: 'id IN (${ids.map((_) => '?').join(',')})',
        whereArgs: ids,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getRecentlyViewed() async {
    final db = await database;
    // Get the 10 most recently viewed products
    return await db.query(
      'recently_viewed', 
      orderBy: 'viewed_at DESC',
      limit: 10,
    );
  }

  Future<void> clearRecentlyViewed() async {
    final db = await database;
    await db.delete('recently_viewed');
  }
}
