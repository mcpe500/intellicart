import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';

/// Use case for getting all products.
///
/// This use case encapsulates the business logic for retrieving all products
/// from the repository.
class GetAllProducts {
  final ProductRepository repository;

  /// Creates a new GetAllProducts use case.
  GetAllProducts(this.repository);

  /// Executes the use case to get all products.
  Future<List<Product>> call() async {
    return await repository.getAllProducts();
  }
}