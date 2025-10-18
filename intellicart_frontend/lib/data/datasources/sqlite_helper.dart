// lib/data/datasources/sqlite_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intellicart/models/product.dart';

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
      version: 1,
      onCreate: _onCreate,
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
}