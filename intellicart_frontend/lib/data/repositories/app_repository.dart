// lib/data/repositories/app_repository.dart
import 'package:intellicart/models/product.dart';
import 'package:intellicart/models/order.dart';
import 'package:intellicart/models/review.dart';

abstract class AppRepository {
  // App Mode Methods
  Future<void> setAppMode(String mode);
  Future<String> getAppMode();
  
  // Current User Methods
  Future<void> setCurrentUser(String userId);
  Future<String?> getCurrentUser();
  
  // Product Methods
  Future<void> insertProducts(List<Product> products);
  Future<List<Product>> getProducts();
  Future<void> insertProduct(Product product);
  Future<Product?> getProductById(int id);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(int id);
  Future<List<Product>> getProductsPendingSync();
  Future<void> markProductAsSynced(String localId, String backendId);
  Future<Product> addReviewToProduct(String productId, Review review);
  
  // Order Methods
  Future<void> insertOrders(List<Order> orders);
  Future<List<Order>> getOrders();
  Future<void> insertOrder(Order order);
  Future<List<Order>> getOrdersPendingSync();
  Future<void> markOrderAsSynced(String localId, String backendId);
  
  // Sync Methods
  Future<void> setLastSyncTime();
  Future<String?> getLastSyncTime();
  Future<void> resetSyncStatus();
  
  // Network Sync Methods
  Future<bool> syncToBackend();
  Future<bool> syncFromBackend();
  Future<bool> fullSync();
  Future<bool> isOnline();
  Future<Map<String, dynamic>> getSyncStatus();
  Future<bool> retryFailedSync();
}