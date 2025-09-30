import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';
import 'package:intellicart/core/services/database_helper.dart';
import 'package:intellicart/data/models/product_model.dart';

/// Local data source for product operations.
///
/// This class provides methods for performing product-related operations
/// using the local SQLite database.
class ProductLocalDataSource {
  final DatabaseHelper dbHelper;

  /// Creates a new product local data source.
  ProductLocalDataSource({required this.dbHelper});

  /// Gets all products from the local database.
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final db = await dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.query('products');
      return List.generate(maps.length, (i) {
        return ProductModel.fromJson(maps[i]);
      });
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to get products: ${e.toString()}');
    }
  }

  /// Gets a product by its ID from the local database.
  Future<ProductModel> getProduct(int id) async {
    try {
      final db = await dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) {
        throw ProductNotFoundException('Product with id $id not found');
      }
      return ProductModel.fromJson(maps.first);
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to get product: ${e.toString()}');
    }
  }

  /// Creates a new product in the local database.
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final db = await dbHelper.db;
      final id = await db.insert('products', product.toJson());
      return product.copyWith(id: id);
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to create product: ${e.toString()}');
    }
  }

  /// Updates an existing product in the local database.
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final db = await dbHelper.db;
      final result = await db.update(
        'products',
        product.toJson(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
      if (result == 0) {
        throw ProductNotFoundException('Product with id ${product.id} not found');
      }
      return product;
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to update product: ${e.toString()}');
    }
  }

  /// Deletes a product by its ID from the local database.
  Future<void> deleteProduct(int id) async {
    try {
      final db = await dbHelper.db;
      final result = await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result == 0) {
        throw ProductNotFoundException('Product with id $id not found');
      }
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to delete product: ${e.toString()}');
    }
  }

  /// Syncs products with the local database.
  Future<void> syncProducts(List<ProductModel> products) async {
    try {
      final db = await dbHelper.db;
      await db.transaction((txn) async {
        // Clear existing products
        await txn.delete('products');
        // Insert new products
        for (final product in products) {
          await txn.insert('products', product.toJson());
        }
      });
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to sync products: ${e.toString()}');
    }
  }
}