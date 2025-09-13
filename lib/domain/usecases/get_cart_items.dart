import 'package:intellicart/domain/entities/cart_item.dart';
import 'package:intellicart/domain/repositories/cart_repository.dart';

/// Use case for getting all cart items.
///
/// This use case encapsulates the business logic for retrieving all cart items
/// from the repository.
class GetCartItems {
  final CartRepository repository;

  /// Creates a new GetCartItems use case.
  GetCartItems(this.repository);

  /// Executes the use case to get all cart items.
  Future<List<CartItem>> call() async {
    return await repository.getCartItems();
  }
}