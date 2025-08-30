import 'package:intellicart/domain/entities/product.dart';
import 'package:intellicart/domain/repositories/product_repository.dart';
import 'package:intellicart/data/datasources/api_service.dart';
import 'package:intellicart/data/datasources/database_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiService apiService;
  final DatabaseService databaseService;

  ProductRepositoryImpl({
    required this.apiService,
    required this.databaseService,
  });

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      // First, try to load from local database
      final localProducts = await databaseService.readAll();
      
      // If we have local data, return it immediately
      if (localProducts.isNotEmpty) {
        return localProducts;
      }
      
      // Then try to fetch from API
      final products = await apiService.getProducts();
      
      // Update local database with fresh data
      await _updateLocalDatabase(products);
      
      return products;
    } catch (e) {
      // If API fails, try to load from local database
      try {
        final localProducts = await databaseService.readAll();
        return localProducts;
      } catch (dbError) {
        throw Exception('Failed to load products: $e');
      }
    }
  }

  @override
  Future<Product> getProduct(int id) async {
    try {
      return await databaseService.read(id) ??
          Future.error(Exception('Product not found'));
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    try {
      // Save to local database first
      final localProduct = await databaseService.create(product);
      
      // Try to sync with API
      try {
        final newProduct = await apiService.createProduct(localProduct);
        // Update local database with product from API (which might have an updated ID)
        await databaseService.update(newProduct);
        return newProduct;
      } catch (apiError) {
        // If API fails, we still have the local product
        return localProduct;
      }
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      // Update local database first
      await databaseService.update(product);
      
      // Try to sync with API
      try {
        final updatedProduct = await apiService.updateProduct(product);
        // Update local database with product from API
        await databaseService.update(updatedProduct);
        return updatedProduct;
      } catch (apiError) {
        // If API fails, we still have the local product
        return product;
      }
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      // Delete from local database first
      await databaseService.delete(id);
      
      // Try to sync with API
      try {
        await apiService.deleteProduct(id);
      } catch (apiError) {
        // If API fails, the local deletion still happened
        // In a real app, you might want to handle this differently
        // (e.g., mark as pending deletion)
      }
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  @override
  Future<void> syncProducts(List<Product> products) async {
    try {
      await _updateLocalDatabase(products);
    } catch (e) {
      throw Exception('Failed to sync products: $e');
    }
  }

  Future<void> _updateLocalDatabase(List<Product> products) async {
    // Clear existing data
    final db = await databaseService.database;
    await db.delete('products');
    
    // Insert fresh data
    for (var product in products) {
      await databaseService.create(product);
    }
  }
}