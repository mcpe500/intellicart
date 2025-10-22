// lib/data/datasources/cart_database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intellicart_frontend/data/models/cart_item.dart';

class CartDatabaseHelper {
  static const String _databaseName = 'intellicart_cart.db';
  static const int _databaseVersion = 1;

  static const String _cartTable = 'cart_items';

  static final CartDatabaseHelper instance = CartDatabaseHelper._init();

  static Database? _database;

  CartDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_cartTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        productDescription TEXT NOT NULL,
        productPrice TEXT NOT NULL,
        productImageUrl TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<int> insertCartItem(CartItem cartItem) async {
    final db = await instance.database;
    return await db.insert(_cartTable, cartItem.toMap());
  }

  Future<List<CartItem>> getCartItems() async {
    final db = await instance.database;
    final result = await db.query(_cartTable);
    return result.map((map) => CartItem.fromMap(map)).toList();
  }

  Future<int> updateCartItem(CartItem cartItem) async {
    final db = await instance.database;
    return await db.update(
      _cartTable,
      cartItem.toMap(),
      where: 'productId = ?',
      whereArgs: [cartItem.productId],
    );
 }

  Future<int> deleteCartItem(int id) async {
    final db = await instance.database;
    return await db.delete(
      _cartTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllCartItems() async {
    final db = await instance.database;
    return await db.delete(_cartTable);
  }

  Future<int> updateQuantity(String productId, int quantity) async {
    final db = await instance.database;
    return await db.update(
      _cartTable,
      {'quantity': quantity},
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<bool> cartItemExists(String productId) async {
    final db = await instance.database;
    final result = await db.query(
      _cartTable,
      where: 'productId = ?',
      whereArgs: [productId],
    );
    return result.isNotEmpty;
  }
  
  Future<int> deleteCartItemByProductId(String productId) async {
    final db = await instance.database;
    return await db.delete(
      _cartTable,
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }
}