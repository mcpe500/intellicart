import 'package:intellicart/domain/entities/cart_item.dart';
import 'package:intellicart/domain/repositories/cart_repository.dart';

/// Use case for updating a cart item.
///
/// This use case encapsulates the business logic for updating a cart item
/// in the repository.
class UpdateCartItem {
  final CartRepository repository;

  /// Creates a new UpdateCartItem use case.
  UpdateCartItem(this.repository);

  /// Executes the use case to update a cart item.
  Future<CartItem> call(CartItem item) async {
    if (item.quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }
    return await repository.updateCartItem(item);
  }
}