// lib/data/datasources/wishlist_database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intellicart_frontend/data/models/wishlist_item.dart';

class WishlistDatabaseHelper {
  static const String _databaseName = 'intellicart_wishlist.db';
  static const int _databaseVersion = 1;

  static const String _wishlistTable = 'wishlist_items';

  static final WishlistDatabaseHelper instance = WishlistDatabaseHelper._init();

  static Database? _database;

  WishlistDatabaseHelper._init();

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
      CREATE TABLE $_wishlistTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT NOT NULL UNIQUE,
        productName TEXT NOT NULL,
        productDescription TEXT NOT NULL,
        productPrice TEXT NOT NULL,
        productImageUrl TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertWishlistItem(WishlistItem wishlistItem) async {
    final db = await instance.database;
    try {
      return await db.insert(_wishlistTable, wishlistItem.toMap());
    } catch (e) {
      // If insert fails due to UNIQUE constraint, ignore
      print('Wishlist item already exists: ${e.toString()}');
      return -1;
    }
  }

  Future<List<WishlistItem>> getWishlistItems() async {
    final db = await instance.database;
    final result = await db.query(_wishlistTable);
    return result.map((map) => WishlistItem.fromMap(map)).toList();
  }

  Future<int> deleteWishlistItem(String productId) async {
    final db = await instance.database;
    return await db.delete(
      _wishlistTable,
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<int> deleteAllWishlistItems() async {
    final db = await instance.database;
    return await db.delete(_wishlistTable);
  }

  Future<bool> wishlistItemExists(String productId) async {
    final db = await instance.database;
    final result = await db.query(
      _wishlistTable,
      where: 'productId = ?',
      whereArgs: [productId],
    );
    return result.isNotEmpty;
  }
}