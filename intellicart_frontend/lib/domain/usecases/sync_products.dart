import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';

/// Use case for syncing products with a remote data source.
///
/// This use case encapsulates the business logic for syncing products
/// with a remote data source.
class SyncProducts {
  final ProductRepository repository;

  /// Creates a new SyncProducts use case.
  SyncProducts(this.repository);

  /// Executes the use case to sync products.
  Future<void> call(List<Product> products) async {
    return await repository.syncProducts(products);
  }
}