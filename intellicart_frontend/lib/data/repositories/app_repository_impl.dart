// lib/data/repositories/app_repository_impl.dart
import 'package:intellicart/models/product.dart';
import 'package:intellicart/models/order.dart';
import 'package:intellicart/models/review.dart';
import 'package:intellicart/data/repositories/app_repository.dart';
import 'package:intellicart/data/datasources/offline_first_api_service.dart';
import 'package:intellicart/data/datasources/offline_sqlite_helper.dart';
import 'package:intellicart/data/datasources/sync_service.dart';

class AppRepositoryImpl implements AppRepository {
  final OfflineFirstApiService? _apiService;

  AppRepositoryImpl([this._apiService]);

  @override
  Future<void> setAppMode(String mode) async {
    final apiService = _apiService;
    if (apiService != null) {
      await apiService.setAppMode(mode);
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      await dbHelper.setAppMode(mode);
    }
  }

  @override
  Future<String> getAppMode() async {
    final apiService = _apiService;
    if (apiService != null) {
      return await apiService.getAppMode();
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      return await dbHelper.getAppMode();
    }
  }

  @override
  Future<void> setCurrentUser(String userId) async {
    final apiService = _apiService;
    if (apiService != null) {
      await apiService.setCurrentUser(userId);
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      await dbHelper.setCurrentUser(userId);
    }
  }

  @override
  Future<String?> getCurrentUser() async {
    final apiService = _apiService;
    if (apiService != null) {
      return await apiService.getLocalCurrentUser();
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      return await dbHelper.getCurrentUser();
    }
  }

  @override
  Future<void> insertProducts(List<Product> products) async {
    final apiService = _apiService;
    if (apiService != null) {
      await apiService.insertProducts(products);
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      await dbHelper.insertProducts(products);
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    final apiService = _apiService;
    if (apiService != null) {
      return await apiService.getProducts();
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      return await dbHelper.getProducts();
    }
  }

  @override
  Future<void> insertProduct(Product product) async {
    final apiService = _apiService;
    if (apiService != null) {
      await apiService.insertProduct(product);
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      await dbHelper.insertProduct(product);
    }
  }

  @override
  Future<Product?> getProductById(int id) async {
    final products = await getProducts();
    try {
      return products.firstWhere((product) => int.tryParse(product.id ?? '0') == id);
    } catch (e) {
      return null; // Return null if product not found
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    final apiService = _apiService;
    if (apiService != null) {
      await apiService.updateProduct(product);
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      await dbHelper.updateProduct(product);
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    final apiService = _apiService;
    if (apiService != null) {
      final products = await getProducts();
      final product = products.firstWhere((p) => int.tryParse(p.id ?? '0') == id, orElse: () => Product(
        id: id.toString(),
        name: '',
        description: '',
        price: '',
        imageUrl: '',
        reviews: [],
      ));
      await apiService.deleteProduct(product);
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      await dbHelper.deleteProduct(id);
    }
  }

  @override
  Future<List<Product>> getProductsPendingSync() async {
    final apiService = _apiService;
    if (apiService != null) {
      return await apiService.getProductsPendingSync();
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      return await dbHelper.getProductsPendingSync();
    }
  }

  @override
  Future<void> markProductAsSynced(String localId, String backendId) async {
    if (_apiService != null) {
      // This would be handled by the API service
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      await dbHelper.markProductAsSynced(localId, backendId);
    }
  }

  @override
  Future<Product> addReviewToProduct(String productId, Review review) async {
    final apiService = _apiService;
    if (apiService != null) {
      return await apiService.addReviewToProduct(productId, review);
    } else {
      // For offline implementation, we would need more complex handling
      throw Exception("API service is required for adding reviews");
    }
  }

  @override
  Future<void> insertOrders(List<Order> orders) async {
    if (_apiService != null) {
      // This would be handled by the API service
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      await dbHelper.insertOrders(orders);
    }
  }

  @override
  Future<List<Order>> getOrders() async {
    final apiService = _apiService;
    if (apiService != null) {
      return await apiService.getOrders();
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      return await dbHelper.getOrders();
    }
  }

  @override
  Future<void> insertOrder(Order order) async {
    final apiService = _apiService;
    if (apiService != null) {
      await apiService.insertOrder(order);
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      await dbHelper.insertOrder(order);
    }
  }

  @override
  Future<List<Order>> getOrdersPendingSync() async {
    final apiService = _apiService;
    if (apiService != null) {
      return await apiService.getOrdersPendingSync();
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      return await dbHelper.getOrdersPendingSync();
    }
  }

  @override
  Future<void> markOrderAsSynced(String localId, String backendId) async {
    if (_apiService != null) {
      // This would be handled by the API service
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      await dbHelper.markOrderAsSynced(localId, backendId);
    }
  }

  @override
  Future<void> setLastSyncTime() async {
    final apiService = _apiService;
    if (apiService != null) {
      await apiService.setLastSyncTime();
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      await dbHelper.setLastSyncTime();
    }
  }

  @override
  Future<String?> getLastSyncTime() async {
    final apiService = _apiService;
    if (apiService != null) {
      return await apiService.getLastSyncTime();
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      return await dbHelper.getLastSyncTime();
    }
  }

  @override
  Future<void> resetSyncStatus() async {
    final apiService = _apiService;
    if (apiService != null) {
      await apiService.resetSyncStatus();
    } else {
      // Fallback to direct database operation if no API service provided
      final dbHelper = OfflineDatabaseHelper();
      await dbHelper.resetSyncStatus();
    }
  }

  @override
  Future<bool> syncToBackend() async {
    final apiService = _apiService;
    if (apiService != null) {
      return await apiService.syncToBackend();
    } else {
      // Fallback to direct database operation if no API service provided
      final syncService = SyncService();
      return await syncService.syncToBackend();
    }
  }

  @override
  Future<bool> syncFromBackend() async {
    final apiService = _apiService;
    if (apiService != null) {
      return await apiService.syncFromBackend();
    } else {
      // Fallback to direct database operation if no API service provided
      final syncService = SyncService();
      return await syncService.syncFromBackend();
    }
  }

  @override
  Future<bool> fullSync() async {
    final apiService = _apiService;
    if (apiService != null) {
      return await apiService.fullSync();
    } else {
      // Fallback to direct database operation if no API service provided
      final syncService = SyncService();
      return await syncService.fullSync();
    }
  }

  @override
  Future<bool> isOnline() async {
    final apiService = _apiService;
    if (apiService != null) {
      return await apiService.isOnline();
    } else {
      // Fallback to direct database operation if no API service provided
      final syncService = SyncService();
      return await syncService.isOnline();
    }
  }

  @override
  Future<Map<String, dynamic>> getSyncStatus() async {
    final apiService = _apiService;
    if (apiService != null) {
      return await apiService.getSyncStatus();
    } else {
      // Fallback to direct database operation if no API service provided
      final syncService = SyncService();
      return await syncService.getSyncStatus();
    }
  }

  @override
  Future<bool> retryFailedSync() async {
    final apiService = _apiService;
    if (apiService != null) {
      return await apiService.retryFailedSync();
    } else {
      // Fallback to direct database operation if no API service provided
      final syncService = SyncService();
      return await syncService.retryFailedSync();
    }
  }
}