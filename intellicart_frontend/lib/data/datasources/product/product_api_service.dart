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

      // If there are images, we need to upload them first and get URLs
      List<String>? imageUrls;
      if (review.images != null && review.images!.isNotEmpty) {
        try {
          imageUrls = await _uploadReviewImages(review.images!);
        } catch (e) {
          loggingService.logWarning('Failed to upload images, proceeding without them: $e');
          // Proceed without images if upload fails
          imageUrls = null;
        }
      }
      
      // Create a copy of the review with the uploaded image URLs (or null if upload failed)
      final reviewWithUrls = Review(
        title: review.title,
        reviewText: review.reviewText,
        rating: review.rating,
        timeAgo: review.timeAgo,
        images: imageUrls, // Use the uploaded image URLs or null
      );

      final response = await http.post(
        Uri.parse('$baseUrl/$productId/reviews'), // Reviews endpoint
        headers: await _getHeaders(),
        body: jsonEncode(reviewWithUrls.toJson()),
      );

      loggingService.logInfo('Add review response status: ${response.statusCode}'); // Debug log
      loggingService.logInfo('Add review response body: ${response.body}'); // Debug log

      if (response.statusCode == 201) { // Handle 201 Created status
        final Map<String, dynamic> data = jsonDecode(response.body);
        loggingService.logInfo('Successfully added review and received full product with all reviews'); // Debug log
        
        // Return the full product with all reviews (including the new one) that was sent by the backend
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to add review to product: ${response.body}');
      }
    } catch (e) {
      loggingService.logError('Error in addReviewToProduct API call: $e'); // Enhanced error log
      throw Exception('Error adding review to product: $e');
    }
  }

  // Helper method to upload images and return URLs
  Future<List<String>?> _uploadReviewImages(List<String> imagePaths) async {
    try {
      final imageBaseUrl = await _getImageBaseUrl();
      final headers = await _getHeaders(); // Use the same headers as other API calls
      
      List<String> uploadedUrls = [];
      
      // Upload each image individually
      for (String imagePath in imagePaths) {
        var request = http.MultipartRequest('POST', Uri.parse('$imageBaseUrl/upload'));
        
        // Add the authentication headers
        request.headers.addAll(headers);
        
        // Add the image file to the request
        final file = await http.MultipartFile.fromPath('image', imagePath);
        request.files.add(file);
        
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          if (responseData['success'] == true && responseData['url'] != null) {
            uploadedUrls.add(responseData['url']);
          } else {
            loggingService.logError('Image upload failed: ${response.body}');
          }
        } else {
          loggingService.logError('Image upload failed with status ${response.statusCode}: ${response.body}');
        }
      }
      
      return uploadedUrls.isEmpty ? null : uploadedUrls;
    } catch (e) {
      loggingService.logError('Error uploading review images: $e');
      throw Exception('Error uploading review images: $e');
    }
  }

  static Future<String> _getImageBaseUrl() async {
    await dotenv.load(fileName: ".env");
    final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
    return '$apiBaseUrl/api/images';
  }
}