import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';
import 'package:intellicart/data/datasources/product_local_data_source.dart';
import 'package:intellicart/data/models/product_model.dart';

/// Implementation of the product repository interface.
///
/// This class provides the concrete implementation of the product repository
/// using the local data source.
class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;

  /// Creates a new product repository implementation.
  ProductRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final productModels = await localDataSource.getAllProducts();
      return productModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Product> getProduct(int id) async {
    try {
      final productModel = await localDataSource.getProduct(id);
      return productModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      final createdModel = await localDataSource.createProduct(productModel);
      return createdModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      final updatedModel = await localDataSource.updateProduct(productModel);
      return updatedModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      return await localDataSource.deleteProduct(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> syncProducts(List<Product> products) async {
    try {
      final productModels = products.map((product) => ProductModel.fromEntity(product)).toList();
      return await localDataSource.syncProducts(productModels);
    } catch (e) {
      rethrow;
    }
  }
}