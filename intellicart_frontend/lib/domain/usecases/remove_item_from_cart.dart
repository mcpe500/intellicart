import 'package:intellicart/domain/repositories/cart_repository.dart';

/// Use case for removing an item from the cart.
///
/// This use case encapsulates the business logic for removing an item from the cart
/// in the repository.
class RemoveItemFromCart {
  final CartRepository repository;

  /// Creates a new RemoveItemFromCart use case.
  RemoveItemFromCart(this.repository);

  /// Executes the use case to remove an item from the cart.
  Future<void> call(int itemId) async {
    if (itemId <= 0) {
      throw ArgumentError('Item ID must be positive');
    }
    return await repository.removeItemFromCart(itemId);
  }
}