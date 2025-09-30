import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

  Future<void> _createDB(Database db, int version) async {
    // Create tables for local storage
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        image_url TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cached_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT UNIQUE NOT NULL,
        product_name TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT,
        image_url TEXT,
        category TEXT,
        last_updated TEXT NOT NULL
      )
    ''');
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table, {String? orderBy}) async {
    final db = await instance.database;
    return await db.query(table, orderBy: orderBy);
  }

  Future<Map<String, dynamic>?> queryById(String table, int id) async {
    final db = await instance.database;
    final maps = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    final db = await instance.database;
    return await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(String table, int id) async {
    final db = await instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}