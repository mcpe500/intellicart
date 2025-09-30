import 'package:intellicart/domain/entities/cart_item.dart';
import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/cart_repository.dart';

/// Use case for adding an item to the cart.
///
/// This use case encapsulates the business logic for adding an item to the cart.
class AddItemToCart {
  final CartRepository repository;

  /// Creates a new AddItemToCart use case.
  AddItemToCart(this.repository);

  /// Executes the use case to add an item to the cart.
  Future<CartItem> call(Product product, int quantity) async {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }
    return await repository.addItemToCart(product, quantity);
  }
}