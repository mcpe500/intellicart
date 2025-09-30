import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';

/// Use case for updating an existing product.
///
/// This use case encapsulates the business logic for updating an existing product
/// in the repository.
class UpdateProduct {
  final ProductRepository repository;

  /// Creates a new UpdateProduct use case.
  UpdateProduct(this.repository);

  /// Executes the use case to update an existing product.
  Future<Product> call(Product product) async {
    // Business logic validation
    if (product.id <= 0) {
      throw ArgumentError('Product ID must be positive');
    }
    if (product.name.isEmpty) {
      throw ArgumentError('Product name cannot be empty');
    }
    return await repository.updateProduct(product);
  }
}