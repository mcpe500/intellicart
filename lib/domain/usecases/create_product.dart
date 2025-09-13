import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';

/// Use case for creating a new product.
///
/// This use case encapsulates the business logic for creating a new product
/// in the repository.
class CreateProduct {
  final ProductRepository repository;

  /// Creates a new CreateProduct use case.
  CreateProduct(this.repository);

  /// Executes the use case to create a new product.
  Future<Product> call(Product product) async {
    // Business logic validation
    if (product.name.isEmpty) {
      throw ArgumentError('Product name cannot be empty');
    }
    if (product.price < 0) {
      throw ArgumentError('Product price must be positive');
    }
    return await repository.createProduct(product);
  }
}