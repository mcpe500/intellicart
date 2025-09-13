import 'package:sqflite/sqflite.dart';
import 'package:intellicart/core/errors/app_exceptions.dart';
import 'package:intellicart/core/services/database_helper.dart';
import 'package:intellicart/data/models/cart_item_model.dart';
import 'package:intellicart/data/models/product_model.dart';

/// Local data source for cart operations.
///
/// This class provides methods for performing cart-related operations
/// using the local SQLite database.
class CartLocalDataSource {
  final DatabaseHelper dbHelper;

  /// Creates a new cart local data source.
  CartLocalDataSource({required this.dbHelper});

  /// Gets all cart items from the local database.
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final db = await dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT cart_items.id, cart_items.quantity, products.id as productId, 
               products.name, products.description, products.price, products.imageUrl
        FROM cart_items
        JOIN products ON cart_items.productId = products.id
      ''');
      
      return List.generate(maps.length, (i) {
        final map = maps[i];
        final product = ProductModel(
          id: map['productId'] as int,
          name: map['name'] as String,
          description: map['description'] as String,
          price: map['price'] as double,
          imageUrl: map['imageUrl'] as String,
        );
        
        return CartItemModel(
          id: map['id'] as int,
          product: product,
          quantity: map['quantity'] as int,
        );
      });
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to get cart items: ${e.toString()}');
    }
  }

  /// Adds an item to the cart in the local database.
  Future<CartItemModel> addItemToCart(int productId, int quantity) async {
    try {
      final db = await dbHelper.db;
      
      // Check if item already exists in cart
      final List<Map<String, dynamic>> existingItems = await db.query(
        'cart_items',
        where: 'productId = ?',
        whereArgs: [productId],
      );
      
      if (existingItems.isNotEmpty) {
        // Update existing item
        final existingId = existingItems.first['id'] as int;
        final existingQuantity = existingItems.first['quantity'] as int;
        final newQuantity = existingQuantity + quantity;
        
        await db.update(
          'cart_items',
          {'quantity': newQuantity},
          where: 'id = ?',
          whereArgs: [existingId],
        );
        
        // Get the updated item
        return await getCartItem(existingId);
      } else {
        // Create new item
        final id = await db.insert('cart_items', {
          'productId': productId,
          'quantity': quantity,
        });
        
        return await getCartItem(id);
      }
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to add item to cart: ${e.toString()}');
    }
  }

  /// Gets a cart item by its ID from the local database.
  Future<CartItemModel> getCartItem(int id) async {
    try {
      final db = await dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT cart_items.id, cart_items.quantity, products.id as productId, 
               products.name, products.description, products.price, products.imageUrl
        FROM cart_items
        JOIN products ON cart_items.productId = products.id
        WHERE cart_items.id = ?
      ''', [id]);
      
      if (maps.isEmpty) {
        throw CartException('Cart item with id $id not found');
      }
      
      final map = maps.first;
      final product = ProductModel(
        id: map['productId'] as int,
        name: map['name'] as String,
        description: map['description'] as String,
        price: map['price'] as double,
        imageUrl: map['imageUrl'] as String,
      );
      
      return CartItemModel(
        id: map['id'] as int,
        product: product,
        quantity: map['quantity'] as int,
      );
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to get cart item: ${e.toString()}');
    }
  }

  /// Updates a cart item in the local database.
  Future<CartItemModel> updateCartItem(CartItemModel item) async {
    try {
      final db = await dbHelper.db;
      final result = await db.update(
        'cart_items',
        {'quantity': item.quantity},
        where: 'id = ?',
        whereArgs: [item.id],
      );
      if (result == 0) {
        throw CartException('Cart item with id ${item.id} not found');
      }
      return item;
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to update cart item: ${e.toString()}');
    }
  }

  /// Removes an item from the cart by its ID from the local database.
  Future<void> removeItemFromCart(int id) async {
    try {
      final db = await dbHelper.db;
      final result = await db.delete(
        'cart_items',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result == 0) {
        throw CartException('Cart item with id $id not found');
      }
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to remove item from cart: ${e.toString()}');
    }
  }

  /// Clears all items from the cart in the local database.
  Future<void> clearCart() async {
    try {
      final db = await dbHelper.db;
      await db.delete('cart_items');
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to clear cart: ${e.toString()}');
    }
  }

  /// Gets the total price of all items in the cart from the local database.
  Future<double> getCartTotal() async {
    try {
      final db = await dbHelper.db;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT SUM(products.price * cart_items.quantity) as total
        FROM cart_items
        JOIN products ON cart_items.productId = products.id
      ''');
      
      if (maps.isEmpty || maps.first['total'] == null) {
        return 0.0;
      }
      
      return maps.first['total'] as double;
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to get cart total: ${e.toString()}');
    }
  }
}