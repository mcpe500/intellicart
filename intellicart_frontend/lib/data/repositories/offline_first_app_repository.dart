// lib/data/repositories/offline_first_app_repository.dart
import 'package:intellicart/models/product.dart';
import 'package:intellicart/models/order.dart';
import 'package:intellicart/models/user.dart';
import 'package:intellicart/models/review.dart';
import 'package:intellicart/data/repositories/app_repository.dart';
import 'package:intellicart/data/datasources/offline_first_api_service.dart';

class OfflineFirstAppRepository implements AppRepository {
  final OfflineFirstApiService _apiService;
  
  OfflineFirstAppRepository(this._apiService);

  @override
  Future<void> setAppMode(String mode) async {
    await _apiService.setAppMode(mode);
  }

  @override
  Future<String> getAppMode() async {
    return await _apiService.getAppMode();
  }

  @override
  Future<void> setCurrentUser(String userId) async {
    await _apiService.setCurrentUser(userId);
  }

  @override
  Future<String?> getCurrentUser() async {
    return await _apiService.getLocalCurrentUser();
  }

  @override
  Future<void> insertProducts(List<Product> products) async {
    await _apiService.insertProducts(products);
  }

  @override
  Future<List<Product>> getProducts() async {
    return await _apiService.getProducts();
  }

  @override
  Future<void> insertProduct(Product product) async {
    await _apiService.addProduct(product);
  }

  @override
  Future<Product?> getProductById(int id) async {
    // This would require implementation in the API service
    // For now, return from the list of all products
    final products = await getProducts();
    try {
      return products.firstWhere((product) => int.tryParse(product.id ?? '0') == id);
    } catch (e) {
      // If not found, return null
      return null;
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _apiService.updateProduct(product);
  }

  @override
  Future<void> deleteProduct(int id) async {
    // This would need to be implemented in the API service
    // For now, we'll find the product and delete it
    final products = await getProducts();
    final product = products.firstWhere((p) => int.tryParse(p.id ?? '0') == id, orElse: () => Product(
      id: id.toString(),
      name: 'Not Found',
      description: 'Product not found',
      price: '0',
      imageUrl: '',
      reviews: [],
    ));
    await _apiService.deleteLocalProduct(product);
  }

  @override
  Future<List<Product>> getProductsPendingSync() async {
    return await _apiService.getProductsPendingSync();
  }

  @override
  Future<void> markProductAsSynced(String localId, String backendId) async {
    // Implementation in the API service
  }

  @override
  Future<void> insertOrders(List<Order> orders) async {
    // Implementation in the API service
  }

  @override
  Future<List<Order>> getOrders() async {
    return await _apiService.getSellerOrders();
  }

  @override
  Future<void> insertOrder(Order order) async {
    // Implementation in the API service
  }

  @override
  Future<List<Order>> getOrdersPendingSync() async {
    return await _apiService.getOrdersPendingSync();
  }

  @override
  Future<void> markOrderAsSynced(String localId, String backendId) async {
    // Implementation in the API service
  }

  @override
  Future<void> setLastSyncTime() async {
    await _apiService.setLastSyncTime();
  }

  @override
  Future<String?> getLastSyncTime() async {
    return await _apiService.getLastSyncTime();
  }

  @override
  Future<void> resetSyncStatus() async {
    await _apiService.resetSyncStatus();
  }

  @override
  Future<bool> syncToBackend() async {
    return await _apiService.syncToBackend();
  }

  @override
  Future<bool> syncFromBackend() async {
    return await _apiService.syncFromBackend();
  }

  @override
  Future<bool> fullSync() async {
    return await _apiService.fullSync();
  }

  @override
  Future<bool> isOnline() async {
    return await _apiService.isOnline();
  }

  @override
  Future<Map<String, dynamic>> getSyncStatus() async {
    return await _apiService.getSyncStatus();
  }

  @override
  Future<bool> retryFailedSync() async {
    return await _apiService.retryFailedSync();
  }

  @override
  Future<Product> addReviewToProduct(String productId, Review review) async {
    return await _apiService.addReviewToProduct(productId, review);
  }
}