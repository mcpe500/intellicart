import 'package:intellicart/domain/repositories/cart_repository.dart';

/// Use case for clearing the cart.
///
/// This use case encapsulates the business logic for clearing all items from the cart
/// in the repository.
class ClearCart {
  final CartRepository repository;

  /// Creates a new ClearCart use case.
  ClearCart(this.repository);

  /// Executes the use case to clear the cart.
  Future<void> call() async {
    return await repository.clearCart();
  }
}