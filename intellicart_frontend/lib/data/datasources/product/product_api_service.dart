// lib/data/datasources/product/product_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intellicart/models/product.dart';
import 'package:intellicart/models/review.dart';
import 'package:intellicart/data/datasources/auth/auth_api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/services/logging_service.dart';

class ProductApiService {
  static String? _baseUrl;

  static Future<String> getBaseUrl() async {
    if (_baseUrl == null) {
      await dotenv.load(fileName: ".env");
      final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
      _baseUrl = '$apiBaseUrl/api/products';
    }
    return _baseUrl!;
  }

  // Helper method to get headers with authorization token
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthApiService.getToken();
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  Future<List<Product>> getProducts() async {
    try {
      final baseUrl = await getBaseUrl();
      loggingService.logInfo('Making API call to fetch products: $baseUrl'); // Debug log
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        loggingService.logInfo('Successfully received ${jsonDecode(response.body).length} products from API'); // Debug log
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading products: $e');
    }
  }

  Future<Product> addProduct(Product product) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getHeaders(),
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to add product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding product: $e');
    }
  }

  Future<Product> updateProduct(Product product) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.put(
        Uri.parse('$baseUrl/${product.id}'),
        headers: await _getHeaders(),
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to update product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.delete(
        Uri.parse('$baseUrl/$productId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }

  Future<List<Product>> getSellerProducts(String sellerId) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/seller/$sellerId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load seller products: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading seller products: $e');
    }
  }

  Future<Product> addReviewToProduct(String productId, Review review) async {
    try {
      final baseUrl = await getBaseUrl();
      loggingService.logInfo('Adding review to product via API: $baseUrl/$productId/reviews'); // Debug log

      // Use POST to the new reviews endpoint
      final response = await http.post(
        Uri.parse('$baseUrl/$productId/reviews'), // Correct endpoint
        headers: await _getHeaders(),
        body: jsonEncode(review.toJson()), // Send only the review data
      );

      loggingService.logInfo('Add review response status: ${response.statusCode}'); // Debug log
      loggingService.logInfo('Add review response body: ${response.body}'); // Debug log


      if (response.statusCode == 200) { // Expect 200 OK now
        final Map<String, dynamic> data = jsonDecode(response.body);
        loggingService.logInfo('Successfully added review, received updated product from API'); // Debug log
        return Product.fromJson(data); // Backend returns the updated product
      } else {
        throw Exception('Failed to add review to product: ${response.body}');
      }
    } catch (e) {
      loggingService.logError('Error in addReviewToProduct API call: $e'); // Enhanced error log
      throw Exception('Error adding review to product: $e');
    }
  }
}