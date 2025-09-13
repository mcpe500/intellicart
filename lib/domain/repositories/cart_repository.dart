import 'package:intellicart/domain/entities/cart_item.dart';
import 'package:intellicart/domain/entities/product.dart';

/// Repository interface for cart operations.
///
/// This interface defines the contract for cart-related operations
/// that can be performed in the application.
abstract class CartRepository {
  /// Gets all cart items.
  Future<List<CartItem>> getCartItems();

  /// Adds an item to the cart.
  Future<CartItem> addItemToCart(Product product, int quantity);

  /// Updates a cart item.
  Future<CartItem> updateCartItem(CartItem item);

  /// Removes an item from the cart by its ID.
  Future<void> removeItemFromCart(int itemId);

  /// Clears all items from the cart.
  Future<void> clearCart();

  /// Gets the total price of all items in the cart.
  Future<double> getCartTotal();
}