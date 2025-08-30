import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intellicart/domain/entities/product.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('intellicart.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        imageUrl TEXT NOT NULL
      )
    ''');
  }

  Future<Product> create(Product product) async {
    final db = await instance.database;
    final id = await db.insert('products', product.toJson());
    return product.copyWith(id: id);
  }

  Future<List<Product>> readAll() async {
    final db = await instance.database;
    final maps = await db.query('products');
    
    return maps.map((map) => Product.fromJson(map)).toList();
  }

  Future<Product?> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Product.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<int> update(Product product) async {
    final db = await instance.database;
    return await db.update(
      'products',
      product.toJson(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
  
  // For testing purposes
  Future<void> clearDatabase() async {
    final db = await instance.database;
    await db.delete('products');
  }
}