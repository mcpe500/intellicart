// lib/data/repositories/app_repository_impl.dart
<<<<<<< HEAD
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/data/repositories/app_repository.dart';

class AppRepositoryImpl implements AppRepository {
  static const String _appModeKey = 'app_mode';
  static const String _productsKey = 'products';
=======
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intellicart_frontend/models/product.dart';
import 'package:intellicart_frontend/models/order.dart';
import 'package:intellicart_frontend/data/repositories/app_repository.dart';
import 'package:intellicart_frontend/data/datasources/api_service.dart';
import 'package:intellicart_frontend/data/datasources/sqlite_helper.dart';
import 'package:flutter/foundation.dart'; // For platform detection

class AppRepositoryImpl implements AppRepository {
  static const String _appModeKey = 'app_mode';
  final ApiService _apiService;
  
  AppRepositoryImpl({ApiService? apiService}) : _apiService = apiService ?? ApiService();
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
  
  @override
  Future<void> setAppMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appModeKey, mode);
  }

  @override
  Future<String> getAppMode() async {
<<<<<<< HEAD
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_appModeKey) ?? 'buyer';
=======
    // On web, always use SharedPreferences
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_appModeKey) ?? 'buyer';
    }
    
    // On mobile, try to get from SQLite first, fallback to SharedPreferences
    try {
      final dbHelper = DatabaseHelper();
      return await dbHelper.getAppMode();
    } catch (e) {
      // If SQLite fails, fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_appModeKey) ?? 'buyer';
    }
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
  }

  @override
  Future<void> insertProducts(List<Product> products) async {
<<<<<<< HEAD
    final prefs = await SharedPreferences.getInstance();
    final productList = products.map((product) => {
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'originalPrice': product.originalPrice,
      'imageUrl': product.imageUrl,
    }).toList();
    await prefs.setStringList(_productsKey, productList.map((p) => 
      "${p['name']},${p['description']},${p['price']},${p['originalPrice']},${p['imageUrl']}").toList());
=======
    // Use the API service to add products to the backend
    for (final product in products) {
      try {
        await _apiService.addProduct(product);
      } catch (e) {
        // If API fails, at least store in local database
        print('Failed to add product to API: $e, storing locally instead');
        // In a real implementation, we might want to queue these for later sync
      }
    }
    
    // On mobile, also store in local database
    if (!kIsWeb) {
      try {
        final dbHelper = DatabaseHelper();
        await dbHelper.insertProducts(products);
      } catch (e) {
        print('Failed to store products locally: $e');
      }
    }
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
  }

  @override
  Future<List<Product>> getProducts() async {
<<<<<<< HEAD
    final prefs = await SharedPreferences.getInstance();
    final productList = prefs.getStringList(_productsKey) ?? [];
    
    return productList.map((productString) {
      final parts = productString.split(',');
      return Product(
        name: parts[0],
        description: parts[1],
        price: parts[2],
        originalPrice: parts.length > 3 ? parts[3] : null,
        imageUrl: parts.length > 4 ? parts[4] : '',
        reviews: [], // Reviews are not persisted in this simplified implementation
      );
    }).toList();
  }
}
=======
    try {
      // First try to get fresh data from API
      final products = await _apiService.getProducts();
      // On mobile, update local cache with fresh data
      if (!kIsWeb) {
        try {
          final dbHelper = DatabaseHelper();
          await dbHelper.insertProducts(products);
        } catch (e) {
          print('Failed to update local cache: $e');
        }
      }
      return products;
    } catch (e) {
      print('Failed to fetch products from API: $e, using local cache');
      // On mobile, if API fails, return data from local database
      if (!kIsWeb) {
        try {
          final dbHelper = DatabaseHelper();
          return await dbHelper.getProducts();
        } catch (e) {
          print('Failed to fetch products from local database: $e');
          return [];
        }
      } else {
        // On web, just return empty list if API fails
        return [];
      }
    }
  }

  @override
  Future<List<Order>> getSellerOrders({String? status, int? page, int? limit}) async {
    try {
      // First try to get fresh data from API
      return await _apiService.getSellerOrders(status: status, page: page, limit: limit);
    } catch (e) {
      print('Failed to fetch seller orders from API: $e');
      // On mobile, we might want to store them in SQLite as well
      // Currently, our SQLite helper doesn't have order methods
      // So we'll just return an empty list if API fails
      return [];
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      // Try to update via API
      await _apiService.updateOrderStatus(orderId, status);
    } catch (e) {
      print('Failed to update order status via API: $e');
      // In a real app, we might want to queue this for later sync
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(Product product) async {
    try {
      // Try to delete via API
      await _apiService.deleteProduct(product);
    } catch (e) {
      print('Failed to delete product via API: $e');
      // In a real app, we might want to queue this for later sync
      rethrow;
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      // Try to update via API
      return await _apiService.updateProduct(product);
    } catch (e) {
      print('Failed to update product via API: $e');
      // In a real app, we might want to queue this for later sync
      rethrow;
    }
  }
}
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
