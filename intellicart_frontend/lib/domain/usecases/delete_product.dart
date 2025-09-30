import 'package:intellicart/domain/repositories/product_repository.dart';

/// Use case for deleting a product.
///
/// This use case encapsulates the business logic for deleting a product
/// from the repository.
class DeleteProduct {
  final ProductRepository repository;

  /// Creates a new DeleteProduct use case.
  DeleteProduct(this.repository);

  /// Executes the use case to delete a product.
  Future<void> call(int productId) async {
    if (productId <= 0) {
      throw ArgumentError('Product ID must be positive');
    }
    return await repository.deleteProduct(productId);
  }
}