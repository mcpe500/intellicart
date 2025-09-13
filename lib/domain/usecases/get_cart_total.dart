import 'package:intellicart/domain/repositories/cart_repository.dart';

/// Use case for getting the cart total.
///
/// This use case encapsulates the business logic for calculating the total price
/// of all items in the cart.
class GetCartTotal {
  final CartRepository repository;

  /// Creates a new GetCartTotal use case.
  GetCartTotal(this.repository);

  /// Executes the use case to get the cart total.
  Future<double> call() async {
    return await repository.getCartTotal();
  }
}