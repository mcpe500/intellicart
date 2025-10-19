// lib/data/datasources/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intellicart_frontend/data/exceptions/api_exception.dart';
import 'package:intellicart_frontend/models/product.dart';
import 'package:intellicart_frontend/models/user.dart';
import 'package:intellicart_frontend/models/order.dart';
import 'package:intellicart_frontend/models/review.dart';

class ApiService {
  late Dio _dio;
  String _baseUrl = '';
  String? _token;
  bool _isInitialized = false;

  // --- ADD THIS GETTER ---
  String? get token => _token;
  // -------------------------

  ApiService() {
    _initializeDio();
  }

  void _initializeDio() async {
    try {
      await dotenv.load(fileName: ".env");
      _baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.intellicart.com/v1';
      
      _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Add interceptors for token management and comprehensive error handling
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (_token != null) {
              options.headers['Authorization'] = 'Bearer $_token';
            }
            return handler.next(options);
          },
          onResponse: (response, handler) {
            // Handle different success status codes appropriately
            switch (response.statusCode) {
              case 200:
                // Standard success response
                break;
              case 201:
                // Resource created
                break;
              case 204:
                // No content (e.g., successful delete)
                break;
              default:
                // For any other success code, continue normally
                break;
            }
            return handler.next(response);
          },
          onError: (DioException error, ErrorInterceptorHandler handler) async {
            switch (error.response?.statusCode) {
              case 401:
                // Unauthorized - token might be expired
                // In a real app, you might try to refresh the token here
                clearToken();
                // Or redirect to login
                break;
              case 403:
                // Forbidden - user doesn't have permission
                break;
              case 404:
                // Resource not found
                break;
              case 429:
                // Too many requests - implement rate limiting
                // You could add a retry delay here
                break;
              case 500:
              case 502:
              case 503:
              case 504:
                // Server errors - might want to queue request for later
                break;
            }
            return handler.next(error);
          },
        ),
      );
      _isInitialized = true;
    } catch (e) {
      // Set a default configuration if .env loading fails
      _baseUrl = 'https://api.intellicart.com/v1';
      
      _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Add interceptors for token management and comprehensive error handling
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (_token != null) {
              options.headers['Authorization'] = 'Bearer $_token';
            }
            return handler.next(options);
          },
          onResponse: (response, handler) {
            return handler.next(response);
          },
          onError: (DioException error, ErrorInterceptorHandler handler) async {
            return handler.next(error);
          },
        ),
      );
      _isInitialized = true;
    }
  }

  Future<void> ensureInitialized() async {
    while (!_isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  // --- AUTHENTICATION METHODS ---
  Future<User?> login(String email, String password) async {
    await ensureInitialized();
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Handle different status codes appropriately
      switch (response.statusCode) {
        case 200:
          final userData = response.data['user'];
          _token = response.data['token'];
          
          return User.fromJson(userData);
        case 400:
          throw ApiException(400, "Invalid email or password format", 
              serverMessage: response.data['message'] ?? "Bad request");
        case 401:
          throw ApiException(401, "Invalid credentials", 
              serverMessage: response.data['message'] ?? "Unauthorized");
        case 429:
          throw ApiException(429, "Too many login attempts. Please try again later", 
              serverMessage: response.data['message'] ?? "Rate limited");
        default:
          throw ApiException(response.statusCode ?? 0, 
              "Login failed with status ${response.statusCode}", 
              serverMessage: response.data?['message'] ?? "Unknown error");
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<User> register(String email, String password, String name, String role) async {
    await ensureInitialized();
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'role': role,
        },
      );

      // Handle different status codes appropriately
      switch (response.statusCode) {
        case 201:
          final userData = response.data['user'];
          _token = response.data['token'];
          
          return User.fromJson(userData);
        case 400:
          throw ApiException(400, "Invalid registration data", 
              serverMessage: response.data['message'] ?? "Bad request");
        case 409:
          throw ApiException(409, "Email already exists", 
              serverMessage: response.data['message'] ?? "Conflict");
        default:
          throw ApiException(response.statusCode ?? 0, 
              "Registration failed with status ${response.statusCode}", 
              serverMessage: response.data?['message'] ?? "Unknown error");
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // --- PRODUCT METHODS ---
  Future<List<Product>> getProducts({int? page, int? limit, String? search, String? category}) async {
    await ensureInitialized();
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
          if (search != null) 'search': search,
          if (category != null) 'category': category,
        },
      );

      switch (response.statusCode) {
        case 200:
          final productsData = response.data['products'] as List;
          return productsData.map((json) => Product.fromJson(json)).toList();
        case 400:
          throw ApiException(400, "Invalid query parameters", 
              serverMessage: response.data['message'] ?? "Bad request");
        case 404:
          // Return empty list if no products found
          return [];
        default:
          throw ApiException(response.statusCode ?? 0, 
              "Failed to fetch products with status ${response.statusCode}", 
              serverMessage: response.data?['message'] ?? "Unknown error");
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Product> addProduct(Product product) async {
    await ensureInitialized();
    try {
      final response = await _dio.post(
        '/products',
        data: product.toJson(),
      );

      switch (response.statusCode) {
        case 201:
          final productData = response.data['product'];
          return Product.fromJson(productData);
        case 400:
          throw ApiException(400, "Invalid product data", 
              serverMessage: response.data['message'] ?? "Bad request");
        case 401:
        case 403:
          throw ApiException(response.statusCode!, "Not authorized to add products", 
              serverMessage: response.data['message'] ?? "Unauthorized");
        case 422:
          throw ApiException(422, "Product validation failed", 
              serverMessage: response.data['message'] ?? "Validation error");
        default:
          throw ApiException(response.statusCode ?? 0, 
              "Failed to add product with status ${response.statusCode}", 
              serverMessage: response.data?['message'] ?? "Unknown error");
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Product> updateProduct(Product product) async {
    await ensureInitialized();
    try {
      final response = await _dio.put(
        '/products/${product.id}',
        data: product.toJson(),
      );

      switch (response.statusCode) {
        case 200:
          final productData = response.data['product'];
          return Product.fromJson(productData);
        case 400:
          throw ApiException(400, "Invalid product data", 
              serverMessage: response.data['message'] ?? "Bad request");
        case 401:
        case 403:
          throw ApiException(response.statusCode!, "Not authorized to update this product", 
              serverMessage: response.data['message'] ?? "Unauthorized");
        case 404:
          throw ApiException(404, "Product not found", 
              serverMessage: response.data['message'] ?? "Not found");
        case 422:
          throw ApiException(422, "Product validation failed", 
              serverMessage: response.data['message'] ?? "Validation error");
        default:
          throw ApiException(response.statusCode ?? 0, 
              "Failed to update product with status ${response.statusCode}", 
              serverMessage: response.data?['message'] ?? "Unknown error");
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteProduct(Product product) async {
    await ensureInitialized();
    try {
      final response = await _dio.delete('/products/${product.id}');

      switch (response.statusCode) {
        case 204:
          // Successfully deleted
          return;
        case 401:
        case 403:
          throw ApiException(response.statusCode!, "Not authorized to delete this product", 
              serverMessage: response.data['message'] ?? "Unauthorized");
        case 404:
          throw ApiException(404, "Product not found", 
              serverMessage: response.data['message'] ?? "Not found");
        default:
          throw ApiException(response.statusCode ?? 0, 
              "Failed to delete product with status ${response.statusCode}", 
              serverMessage: response.data?['message'] ?? "Unknown error");
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<Product>> getSellerProducts(String sellerId, {int? page, int? limit}) async {
    await ensureInitialized();
    try {
      final response = await _dio.get(
        '/products/seller/$sellerId',
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );

      switch (response.statusCode) {
        case 200:
          final productsData = response.data['products'] as List;
          return productsData.map((json) => Product.fromJson(json)).toList();
        case 400:
          throw ApiException(400, "Invalid query parameters", 
              serverMessage: response.data['message'] ?? "Bad request");
        case 401:
        case 403:
          throw ApiException(response.statusCode!, "Not authorized to view seller products", 
              serverMessage: response.data['message'] ?? "Unauthorized");
        case 404:
          // Return empty list if no products found for seller
          return [];
        default:
          throw ApiException(response.statusCode ?? 0, 
              "Failed to fetch seller products with status ${response.statusCode}", 
              serverMessage: response.data?['message'] ?? "Unknown error");
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // --- ORDER METHODS ---
  Future<List<Order>> getSellerOrders({String? status, int? page, int? limit}) async {
    await ensureInitialized();
    try {
      final response = await _dio.get(
        '/orders/seller',
        queryParameters: {
          if (status != null) 'status': status,
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );

      switch (response.statusCode) {
        case 200:
          final ordersData = response.data['orders'] as List;
          return ordersData.map((json) => Order.fromJson(json)).toList();
        case 400:
          throw ApiException(400, "Invalid query parameters", 
              serverMessage: response.data['message'] ?? "Bad request");
        case 401:
        case 403:
          throw ApiException(response.statusCode!, "Not authorized to view orders", 
              serverMessage: response.data['message'] ?? "Unauthorized");
        case 404:
          // Return empty list if no orders found
          return [];
        default:
          throw ApiException(response.statusCode ?? 0, 
              "Failed to fetch seller orders with status ${response.statusCode}", 
              serverMessage: response.data?['message'] ?? "Unknown error");
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await ensureInitialized();
    try {
      final response = await _dio.put(
        '/orders/$orderId/status',
        data: {'status': status},
      );

      switch (response.statusCode) {
        case 200:
          // Successfully updated
          return;
        case 400:
          throw ApiException(400, "Invalid status value", 
              serverMessage: response.data['message'] ?? "Bad request");
        case 401:
        case 403:
          throw ApiException(response.statusCode!, "Not authorized to update order status", 
              serverMessage: response.data['message'] ?? "Unauthorized");
        case 404:
          throw ApiException(404, "Order not found", 
              serverMessage: response.data['message'] ?? "Not found");
        case 422:
          throw ApiException(422, "Invalid status transition", 
              serverMessage: response.data['message'] ?? "Unprocessable entity");
        default:
          throw ApiException(response.statusCode ?? 0, 
              "Failed to update order status with status ${response.statusCode}", 
              serverMessage: response.data?['message'] ?? "Unknown error");
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<User?> getUserById(String userId) async {
    await ensureInitialized();
    try {
      final response = await _dio.get('/users/$userId');

      switch (response.statusCode) {
        case 200:
          final userData = response.data['user'];
          return User.fromJson(userData);
        case 401:
        case 403:
          throw ApiException(response.statusCode!, "Not authorized to view user", 
              serverMessage: response.data['message'] ?? "Unauthorized");
        case 404:
          // User not found
          return null;
        default:
          throw ApiException(response.statusCode ?? 0, 
              "Failed to fetch user with status ${response.statusCode}", 
              serverMessage: response.data?['message'] ?? "Unknown error");
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // --- REVIEW METHODS ---
  Future<List<Review>> getProductReviews(String productId) async {
    await ensureInitialized();
    try {
      final response = await _dio.get('/reviews/product/$productId');

      switch (response.statusCode) {
        case 200:
          final reviewsData = response.data['reviews'] as List;
          return reviewsData.map((json) => Review.fromJson(json)).toList();
        case 400:
          throw ApiException(400, "Invalid query parameters", 
              serverMessage: response.data['message'] ?? "Bad request");
        case 404:
          // No reviews found for this product
          return [];
        default:
          throw ApiException(response.statusCode ?? 0, 
              "Failed to fetch product reviews with status ${response.statusCode}", 
              serverMessage: response.data?['message'] ?? "Unknown error");
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Review> submitReview(String productId, String title, String reviewText, int rating) async {
    await ensureInitialized();
    try {
      final response = await _dio.post(
        '/reviews',
        data: {
          'productId': productId,
          'title': title,
          'reviewText': reviewText,
          'rating': rating,
        },
      );

      switch (response.statusCode) {
        case 201:
          final reviewData = response.data['review'];
          return Review.fromJson(reviewData);
        case 400:
          throw ApiException(400, "Invalid review data", 
              serverMessage: response.data['message'] ?? "Bad request");
        case 401:
          throw ApiException(401, "Not authorized to submit review", 
              serverMessage: response.data['message'] ?? "Unauthorized");
        case 422:
          throw ApiException(422, "Review validation failed", 
              serverMessage: response.data['message'] ?? "Validation error");
        default:
          throw ApiException(response.statusCode ?? 0, 
              "Failed to submit review with status ${response.statusCode}", 
              serverMessage: response.data?['message'] ?? "Unknown error");
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}