// lib/data/repositories/wishlist_repository.dart
import 'package:intellicart_frontend/data/models/wishlist_item.dart';
import 'package:intellicart_frontend/data/datasources/wishlist_database_helper.dart';

abstract class WishlistRepository {
  Future<void> addToWishlist(WishlistItem wishlistItem);
  Future<List<WishlistItem>> getWishlistItems();
  Future<void> removeFromWishlist(String productId);
  Future<void> clearWishlist();
  Future<bool> wishlistItemExists(String productId);
}

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistDatabaseHelper _dbHelper = WishlistDatabaseHelper.instance;

  @override
  Future<void> addToWishlist(WishlistItem wishlistItem) async {
    await _dbHelper.insertWishlistItem(wishlistItem);
  }

  @override
  Future<List<WishlistItem>> getWishlistItems() async {
    return await _dbHelper.getWishlistItems();
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    await _dbHelper.deleteWishlistItem(productId);
  }

  @override
  Future<void> clearWishlist() async {
    await _dbHelper.deleteAllWishlistItems();
  }

  @override
  Future<bool> wishlistItemExists(String productId) async {
    return await _dbHelper.wishlistItemExists(productId);
  }
}