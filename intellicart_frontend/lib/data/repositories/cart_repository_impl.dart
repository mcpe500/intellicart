import 'package:intellicart/domain/entities/cart_item.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/cart_repository.dart';
import 'package:intellicart/data/datasources/cart_local_data_source.dart';
import 'package:intellicart/data/models/cart_item_model.dart';
import 'package:intellicart/data/models/product_model.dart';

/// Implementation of the cart repository interface.
///
/// This class provides the concrete implementation of the cart repository
/// using the local data source.
class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  /// Creates a new cart repository implementation.
  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<List<CartItem>> getCartItems() async {
    try {
      final cartItemModels = await localDataSource.getCartItems();
      return cartItemModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CartItem> addItemToCart(Product product, int quantity) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      final cartItemModel = await localDataSource.addItemToCart(productModel.id, quantity);
      return cartItemModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CartItem> updateCartItem(CartItem item) async {
    try {
      final cartItemModel = CartItemModel.fromEntity(item);
      final updatedModel = await localDataSource.updateCartItem(cartItemModel);
      return updatedModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeItemFromCart(int itemId) async {
    try {
      return await localDataSource.removeItemFromCart(itemId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      return await localDataSource.clearCart();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<double> getCartTotal() async {
    try {
      return await localDataSource.getCartTotal();
    } catch (e) {
      rethrow;
    }
  }
}