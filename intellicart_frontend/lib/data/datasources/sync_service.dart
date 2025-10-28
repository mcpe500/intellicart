// lib/data/datasources/sync_service.dart
import 'package:intellicart/data/datasources/offline_sqlite_helper.dart';
import 'package:intellicart/data/datasources/api_service.dart';
import 'package:intellicart/models/review.dart';
import 'package:intellicart/core/services/logging_service.dart';

class SyncService {
  final OfflineDatabaseHelper _dbHelper = OfflineDatabaseHelper();
  final ApiService _apiService = ApiService();
  
  // Sync all pending changes to the backend
  Future<bool> syncToBackend() async {
    try {
      bool success = true;
      
      // Sync products
      final productsToSync = await _dbHelper.getProductsPendingSync();
      for (final product in productsToSync) {
        try {
          // For new products, use addProduct; for updates, use updateProduct
          if (product.id?.startsWith('local_') ?? true) {
            // This is a local product that needs to be created on the backend
            final createdProduct = await _apiService.addProduct(product);
            await _dbHelper.markProductAsSynced(product.id!, createdProduct.id!);
          } else {
            // This is an existing product that needs to be updated
            await _apiService.updateProduct(product);
            await _dbHelper.markProductAsSynced(product.id!, product.id!);
          }
        } catch (e) {
          loggingService.logWarning('Failed to sync product: ${e.toString()}');
          await _dbHelper.markProductSyncFailed(product.id!);
          success = false;
        }
      }
      
      // Sync orders
      final ordersToSync = await _dbHelper.getOrdersPendingSync();
      for (final order in ordersToSync) {
        try {
          // For now, we'll just create new orders or update existing ones
          // In a real app, you might have specific logic for order creation vs updates
          if (order.id?.startsWith('local_') ?? true) {
            // This is a local order that needs to be created on the backend
            // For this example, we'll just mark it as synced if it exists
            await _dbHelper.markOrderAsSynced(order.id!, order.id!);
          } else {
            // This is an existing order that might need to be updated
            await _dbHelper.markOrderAsSynced(order.id!, order.id!);
          }
        } catch (e) {
          loggingService.logWarning('Failed to sync order: ${e.toString()}');
          await _dbHelper.markOrderSyncFailed(order.id!);
          success = false;
        }
      }

      // Sync pending reviews
      final reviewsToSync = await _dbHelper.getPendingReviews();
      for (final reviewData in reviewsToSync) {
        try {
          final review = Review(
            title: reviewData['title'],
            reviewText: reviewData['review_text'],
            rating: reviewData['rating'],
            timeAgo: 'Just now', // This will be updated by the backend
          );
          await _apiService.productService.addReviewToProduct(reviewData['product_id'], review);
          await _dbHelper.deletePendingReview(reviewData['id']);
        } catch (e) {
          loggingService.logWarning('Failed to sync review: ${e.toString()}');
          success = false;
        }
      }
      
      // Update last sync time if successful
      if (success) {
        await _dbHelper.setLastSyncTime();
      }
      
      return success;
    } catch (e) {
      loggingService.logError('Sync error: ${e.toString()}');
      return false;
    }
  }
  
  // Fetch all data from the backend and update local database
  Future<bool> syncFromBackend() async {
    try {
      // Get current user to determine which data to fetch
      final currentUser = await _dbHelper.getCurrentUser();
      if (currentUser == null) {
        // If no user is logged in, we can't sync personalized data
        // But we can still sync public data like products
        final products = await _apiService.getProducts();
        await _dbHelper.insertProducts(products);
        return true;
      }
      
      // Fetch and update products
      final products = await _apiService.getProducts();
      try {
        await _dbHelper.insertProducts(products);
      } catch (e) {
        // Check if this is a unique constraint error by examining the error message
        if (e.toString().contains('UNIQUE constraint failed') && e.toString().contains('products.external_id')) {
          loggingService.logWarning('Unique constraint error detected, clearing database and retrying sync...');
          // Clear the local database and try again
          await _clearLocalDatabase();
          await _dbHelper.insertProducts(products);
        } else {
          rethrow;
        }
      }
      
      // If user is a seller, fetch seller-specific data
      if (await _dbHelper.getAppMode() == 'seller') {
        final sellerOrders = await _apiService.getSellerOrders();
        await _dbHelper.insertOrders(sellerOrders);
      }
      
      // Update last sync time
      await _dbHelper.setLastSyncTime();
      return true;
    } catch (e) {
      loggingService.logError('Sync from backend error: ${e.toString()}');
      return false;
    }
  }
  
  // Helper method to clear local database completely
  Future<void> _clearLocalDatabase() async {
    loggingService.logInfo('Clearing local database completely to resolve constraint issues...');
    // Clear all data - this should force a clean sync
    await _dbHelper.insertProducts([]); // This will clear all products and reviews
  }
  
  // Perform full bidirectional sync
  Future<bool> fullSync() async {
    // First, sync local changes to backend
    bool toBackendSuccess = await syncToBackend();
    
    // Then, sync backend changes to local
    bool fromBackendSuccess = await syncFromBackend();
    
    return toBackendSuccess && fromBackendSuccess;
  }
  
  // Check if device is online
  Future<bool> isOnline() async {
    // This is a simplified check - in a real app you'd want a more robust solution
    try {
      // Try to make a simple request to the API
      await _apiService.getCurrentUser();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Get sync status information
  Future<Map<String, dynamic>> getSyncStatus() async {
    final productsToSync = await _dbHelper.getProductsPendingSync();
    final ordersToSync = await _dbHelper.getOrdersPendingSync();
    final reviewsToSync = await _dbHelper.getPendingReviews();
    final lastSyncTime = await _dbHelper.getLastSyncTime();
    
    return {
      'productsToSync': productsToSync.length,
      'ordersToSync': ordersToSync.length,
      'reviewsToSync': reviewsToSync.length,
      'lastSyncTime': lastSyncTime,
    };
  }
  
  // Retry failed sync operations
  Future<bool> retryFailedSync() async {
    await _dbHelper.resetSyncStatus();
    return await syncToBackend();
  }
}