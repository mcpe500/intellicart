// lib/data/datasources/offline_first_api_service.dart
import 'package:intellicart/data/datasources/api_service.dart';
import 'package:intellicart/data/datasources/offline_sqlite_helper.dart';
import 'package:intellicart/data/datasources/sync_service.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/models/user.dart';
import 'package:intellicart/models/order.dart';
import 'package:intellicart/models/review.dart';

class OfflineFirstApiService {
  final ApiService _onlineService = ApiService();
  final OfflineDatabaseHelper _dbHelper = OfflineDatabaseHelper();
  final SyncService _syncService = SyncService();
  
  // --- AUTHENTICATION METHODS ---
  Future<User?> login(String email, String password) async {
    try {
      // Try online first
      final user = await _onlineService.login(email, password);
      if (user != null) {
        // Update local state
        await _dbHelper.setCurrentUser(user.id!);
        await _dbHelper.setAppMode(user.role == 'seller' ? 'seller' : 'buyer');
        return user;
      }
      return null;
    } catch (e) {
      // If online fails, we can't login offline since credentials need to be verified
      rethrow;
    }
  }

  Future<User> register(String email, String password, String name, String role) async {
    try {
      // Try online first
      final user = await _onlineService.register(email, password, name, role);
      if (user != null) {
        // Update local state
        await _dbHelper.setCurrentUser(user.id!);
        await _dbHelper.setAppMode(user.role == 'seller' ? 'seller' : 'buyer');
        return user;
      }
      throw Exception('Registration failed');
    } catch (e) {
      // If online fails, we can't register offline since it needs backend verification
      rethrow;
    }
  }

  // --- PRODUCT METHODS ---
  Future<List<Product>> getProducts() async {
    try {
      // Try to sync from backend first
      await _syncService.syncFromBackend();
      
      // Return local data (which is now up to date)
      return await _dbHelper.getProducts();
    } catch (e) {
      // If online sync fails, return local data
      print('Online sync failed, returning local data: ${e.toString()}');
      return await _dbHelper.getProducts();
    }
  }

  Future<Product> addProduct(Product product) async {
    try {
      // Try online first
      final createdProduct = await _onlineService.addProduct(product);
      
      // Update local database
      await _dbHelper.insertProduct(createdProduct, isLocal: false);
      
      return createdProduct;
    } catch (e) {
      print('Online product creation failed, saving locally: ${e.toString()}');
      
      // If online fails, save locally and mark for sync
      await _dbHelper.insertProduct(product, isLocal: true);
      
      // Try to sync later
      _attemptBackgroundSync();
      
      return product;
    }
  }

  Future<Product> updateProduct(Product product) async {
    try {
      // Try online first
      final updatedProduct = await _onlineService.updateProduct(product);
      
      // Update local database
      await _dbHelper.updateProduct(updatedProduct);
      
      return updatedProduct;
    } catch (e) {
      print('Online product update failed, updating locally: ${e.toString()}');
      
      // If online fails, update locally and mark for sync
      await _dbHelper.updateProduct(product);
      
      // Try to sync later
      _attemptBackgroundSync();
      
      return product;
    }
  }

  Future<void> deleteProduct(Product product) async {
    try {
      // Try online first
      await _onlineService.deleteProduct(product);
      
      // Update local database
      await _dbHelper.deleteProduct(int.tryParse(product.id ?? '0') ?? 0);
    } catch (e) {
      print('Online product deletion failed: ${e.toString()}');
      
      // If online fails, try to mark locally for deletion (in a real app you'd want a delete queue)
      // For now, just delete locally
      await _dbHelper.deleteProduct(int.tryParse(product.id ?? '0') ?? 0);
      
      // Try to sync later
      _attemptBackgroundSync();
    }
  }

  Future<List<Product>> getSellerProducts(String sellerId) async {
    try {
      // Try online first
      final products = await _onlineService.getSellerProducts(sellerId);
      
      // Update local database
      await _dbHelper.insertProducts(products);
      
      return products;
    } catch (e) {
      print('Online seller products fetch failed, returning local data: ${e.toString()}');
      
      // If online fails, return local data
      return await _dbHelper.getProducts();
    }
  }

  Future<Product> addReviewToProduct(String productId, Review review) async {
    try {
      // Try online first
      final updatedProduct = await _onlineService.productService.addReviewToProduct(productId, review);
      
      // Update local database
      await _dbHelper.updateProduct(updatedProduct);
      
      return updatedProduct;
    } catch (e) {
      print('Online review submission failed, attempting local update: ${e.toString()}');
      
      // If online fails, we can't submit the review locally since it needs online verification
      rethrow;
    }
  }

  // --- ORDER METHODS ---
  Future<List<Order>> getSellerOrders() async {
    try {
      // Try online first
      final orders = await _onlineService.getSellerOrders();
      
      // Update local database
      await _dbHelper.insertOrders(orders);
      
      return orders;
    } catch (e) {
      print('Online seller orders fetch failed, returning local data: ${e.toString()}');
      
      // If online fails, return local data
      return await _dbHelper.getOrders();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      // Try online first
      await _onlineService.updateOrderStatus(orderId, status);
      
      // In a full implementation, you would update the local order status
      // For now, we'll just sync from backend after the update
      await _syncService.syncFromBackend();
    } catch (e) {
      print('Online order status update failed: ${e.toString()}');
      
      // If online fails, we can't update offline since status updates need backend
      // But we could queue the update for later sync
      rethrow;
    }
  }

  // --- USER METHODS ---
  Future<User?> getUserById(String userId) async {
    try {
      return await _onlineService.getUserById(userId);
    } catch (e) {
      // User data typically can't be stored offline since it's sensitive
      rethrow;
    }
  }
  
  // Additional methods for repository compatibility
  Future<void> setCurrentUser(String userId) async {
    await _dbHelper.setCurrentUser(userId);
  }

  Future<String?> getLocalCurrentUser() async {
    return await _dbHelper.getCurrentUser();
  }

  Future<void> insertProducts(List<Product> products) async {
    await _dbHelper.insertProducts(products);
  }
  
  // Get current user using the stored token (online)
  Future<User?> getCurrentUser() async {
    try {
      return await _onlineService.getCurrentUser();
    } catch (e) {
      // Current user data can't be stored offline
      rethrow;
    }
  }

  Future<void> insertProduct(Product product) async {
    await _dbHelper.insertProduct(product, isLocal: true);
    _attemptBackgroundSync();
  }

  Future<void> deleteLocalProduct(Product product) async {
    int? productId = int.tryParse(product.id ?? '');
    if (productId != null) {
      await _dbHelper.deleteProduct(productId);
      _attemptBackgroundSync();
    }
  }

  Future<List<Product>> getProductsPendingSync() async {
    return await _dbHelper.getProductsPendingSync();
  }

  Future<List<Order>> getOrdersPendingSync() async {
    return await _dbHelper.getOrdersPendingSync();
  }

  // --- PRIVATE HELPER METHODS ---
  void _attemptBackgroundSync() {
    // Try to sync in the background
    Future.microtask(() async {
      try {
        await _syncService.syncToBackend();
      } catch (e) {
        print('Background sync failed: ${e.toString()}');
      }
    });
  }
  
  // Sync in both directions
  Future<bool> fullSync() {
    return _syncService.fullSync();
  }
  
  // Check if the app is online
  Future<bool> isOnline() {
    return _syncService.isOnline();
  }
  
  // Get sync status
  Future<Map<String, dynamic>> getSyncStatus() {
    return _syncService.getSyncStatus();
  }
  
  // Additional methods required by the repository interface
  Future<void> setAppMode(String mode) async {
    await _dbHelper.setAppMode(mode);
  }

  Future<String> getAppMode() async {
    return await _dbHelper.getAppMode();
  }



  Future<void> insertOrder(Order order) async {
    await _dbHelper.insertOrder(order, isLocal: true);
    _attemptBackgroundSync();
  }

  Future<void> setLastSyncTime() async {
    await _dbHelper.setLastSyncTime();
  }

  Future<String?> getLastSyncTime() async {
    return await _dbHelper.getLastSyncTime();
  }

  Future<void> resetSyncStatus() async {
    await _dbHelper.resetSyncStatus();
  }
  
  Future<List<Order>> getOrders() async {
    try {
      // Try online first
      final orders = await _onlineService.getSellerOrders();
      
      // Update local database
      await _dbHelper.insertOrders(orders);
      
      return orders;
    } catch (e) {
      print('Online seller orders fetch failed, returning local data: ${e.toString()}');
      
      // If online fails, return local data
      return await _dbHelper.getOrders();
    }
  }
  
  Future<bool> syncToBackend() async {
    return await _syncService.syncToBackend();
  }

  Future<bool> syncFromBackend() async {
    return await _syncService.syncFromBackend();
  }

  Future<bool> retryFailedSync() async {
    return await _syncService.retryFailedSync();
  }
}