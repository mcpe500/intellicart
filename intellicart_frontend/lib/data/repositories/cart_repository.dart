// lib/data/repositories/cart_repository.dart
import 'package:intellicart_frontend/data/models/cart_item.dart';
import 'package:intellicart_frontend/data/datasources/cart_database_helper.dart';

abstract class CartRepository {
  Future<void> addToCart(CartItem cartItem);
  Future<List<CartItem>> getCartItems();
  Future<void> updateQuantity(String productId, int quantity);
  Future<void> removeFromCart(int id);
  Future<void> clearCart();
  Future<bool> cartItemExists(String productId);
  Future<void> updateOrAddCartItem(CartItem cartItem);
}

class CartRepositoryImpl implements CartRepository {
  final CartDatabaseHelper _dbHelper = CartDatabaseHelper.instance;

  @override
  Future<void> addToCart(CartItem cartItem) async {
    await _dbHelper.insertCartItem(cartItem);
  }

  @override
  Future<List<CartItem>> getCartItems() async {
    return await _dbHelper.getCartItems();
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) async {
    await _dbHelper.updateQuantity(productId, quantity);
  }

  @override
  Future<void> removeFromCart(int id) async {
    await _dbHelper.deleteCartItem(id);
  }

  @override
  Future<void> clearCart() async {
    await _dbHelper.deleteAllCartItems();
  }

  @override
  Future<bool> cartItemExists(String productId) async {
    return await _dbHelper.cartItemExists(productId);
  }

  @override
  Future<void> updateOrAddCartItem(CartItem cartItem) async {
    final exists = await _dbHelper.cartItemExists(cartItem.productId);
    if (exists) {
      // Update the existing item
      await _dbHelper.updateQuantity(cartItem.productId, cartItem.quantity);
    } else {
      // Add new item
      await _dbHelper.insertCartItem(cartItem);
    }
  }
}