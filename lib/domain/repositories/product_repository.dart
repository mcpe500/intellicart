import 'package:intellicart/domain/entities/product.dart';

/// Repository interface for product operations.
///
/// This interface defines the contract for product-related operations
/// that can be performed in the application.
abstract class ProductRepository {
  /// Gets all products.
  Future<List<Product>> getAllProducts();

  /// Gets a product by its ID.
  Future<Product> getProduct(int id);

  /// Creates a new product.
  Future<Product> createProduct(Product product);

  /// Updates an existing product.
  Future<Product> updateProduct(Product product);

  /// Deletes a product by its ID.
  Future<void> deleteProduct(int id);

  /// Syncs products with a remote data source.
  Future<void> syncProducts(List<Product> products);
}