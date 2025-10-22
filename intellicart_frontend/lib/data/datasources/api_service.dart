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
  String? _token;
  late String _baseUrl;
  bool _isInitialized = false;

  String? get token => _token;

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      // Wait briefly to allow initialization to complete
      await Future.delayed(const Duration(milliseconds: 100));
      // If still not initialized, wait more
      int attempts = 0;
      while (!_isInitialized && attempts < 50) { // Max 5 seconds
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
    }
  }

  ApiService() {
    _initializeDio();
  }

  Future<void> _initializeDio() async {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    _baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.intellicart.com/v1';

    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Request interceptor to add authorization header
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add Authorization header if token exists
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
      ),
    );

    // Response interceptor to handle unauthorized responses
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) async {
          return handler.next(response);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired or invalid, clear it
            clearToken();
          }
          return handler.next(error);
        },
      ),
    );

    // Error interceptor for generic error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            return handler.reject(
              DioException(
                error: error.error,
                message: "Connection timeout",
                requestOptions: error.requestOptions,
              ),
            );
          }
          return handler.next(error);
        },
      ),
    );
    _isInitialized = true;
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
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        _token = response.data['token'];
        return User.fromJson(userData);
      } else if (response.statusCode == 400) {
        throw ApiException(400, "Invalid email or password format",
          serverMessage: response.data['message'] ?? 'Invalid input');
      } else if (response.statusCode == 401) {
        throw ApiException(401, "Invalid credentials",
          serverMessage: response.data['message'] ?? 'Incorrect email or password');
      } else if (response.statusCode == 429) {
        throw ApiException(429, "Too many login attempts. Please try again later",
          serverMessage: response.data['message'] ?? 'Rate limited');
      } else {
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Login failed',
          serverMessage: '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<User> register(String email, String password, String name, String role) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
        'role': role,
      });

      if (response.statusCode == 201) {
        final userData = response.data['user'];
        _token = response.data['token'];
        return User.fromJson(userData);
      } else if (response.statusCode == 400) {
        throw ApiException(400, "Invalid registration data",
          serverMessage: response.data['message'] ?? 'Invalid input');
      } else if (response.statusCode == 409) {
        throw ApiException(409, "Email already exists",
          serverMessage: response.data['message'] ?? 'A user with this email already exists');
      } else {
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Registration failed',
          serverMessage: '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // --- PRODUCT METHODS ---
  Future<List<Product>> getProducts({int? page, int? limit, String? search, String? category}) async {
    await ensureInitialized();
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (search != null) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;

      final response = await _dio.get('/products', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> productsData = response.data['products'];
        return productsData.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 400) {
        throw ApiException(400, "Invalid query parameters",
          serverMessage: response.data['message'] ?? 'Invalid input');
      } else {
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Failed to fetch products',
          serverMessage: '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Product> addProduct(Product product) async {
    try {
      final response = await _dio.post('/products', data: product.toJson());

      if (response.statusCode == 201) {
        final productData = response.data['product'];
        return Product.fromJson(productData);
      } else if (response.statusCode == 400) {
        throw ApiException(400, "Invalid product data",
          serverMessage: response.data['message'] ?? 'Invalid input');
      } else if (response.statusCode == 401) {
        throw ApiException(response.statusCode!, "Not authorized to add products",
          serverMessage: response.data['message'] ?? 'Authentication required');
      } else if (response.statusCode == 422) {
        throw ApiException(422, "Product validation failed",
          serverMessage: response.data['message'] ?? 'Validation error');
      } else {
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Failed to add product',
          serverMessage: '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Product> updateProduct(Product product) async {
    try {
      final response = await _dio.put('/products/${product.id}', data: product.toJson());

      if (response.statusCode == 200) {
        final productData = response.data['product'];
        return Product.fromJson(productData);
      } else if (response.statusCode == 400) {
        throw ApiException(400, "Invalid product data",
          serverMessage: response.data['message'] ?? 'Invalid input');
      } else if (response.statusCode == 401) {
        throw ApiException(response.statusCode!, "Not authorized to update this product",
          serverMessage: response.data['message'] ?? 'Insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException(404, "Product not found",
          serverMessage: response.data['message'] ?? 'Product does not exist');
      } else if (response.statusCode == 422) {
        throw ApiException(422, "Product validation failed",
          serverMessage: response.data['message'] ?? 'Validation error');
      } else {
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Failed to update product',
          serverMessage: '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteProduct(Product product) async {
    try {
      final response = await _dio.delete('/products/${product.id}');

      if (response.statusCode == 204) {
        return; // Successfully deleted
      } else if (response.statusCode == 401) {
        throw ApiException(response.statusCode!, "Not authorized to delete this product",
          serverMessage: response.data['message'] ?? 'Insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException(404, "Product not found",
          serverMessage: response.data['message'] ?? 'Product does not exist');
      } else {
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Failed to delete product',
          serverMessage: '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<Product>> getSellerProducts(String sellerId, {int? page, int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dio.get('/sellers/$sellerId/products', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> productsData = response.data['products'];
        return productsData.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 400) {
        throw ApiException(400, "Invalid query parameters",
          serverMessage: response.data['message'] ?? 'Invalid input');
      } else if (response.statusCode == 401) {
        throw ApiException(response.statusCode!, "Not authorized to view seller products",
          serverMessage: response.data['message'] ?? 'Insufficient permissions');
      } else {
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Failed to fetch seller products',
          serverMessage: '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // --- ORDER METHODS ---
  Future<List<Order>> getSellerOrders({String? status, int? page, int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dio.get('/orders/seller', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> ordersData = response.data['orders'];
        return ordersData.map((json) => Order.fromJson(json)).toList();
      } else if (response.statusCode == 400) {
        throw ApiException(400, "Invalid query parameters",
          serverMessage: response.data['message'] ?? 'Invalid input');
      } else if (response.statusCode == 401) {
        throw ApiException(response.statusCode!, "Not authorized to view orders",
          serverMessage: response.data['message'] ?? 'Insufficient permissions');
      } else {
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Failed to fetch orders',
          serverMessage: '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _dio.patch('/orders/$orderId/status', data: {'status': status});

      if (response.statusCode == 200) {
        return; // Successfully updated
      } else if (response.statusCode == 400) {
        throw ApiException(400, "Invalid status value",
          serverMessage: response.data['message'] ?? 'Invalid input');
      } else if (response.statusCode == 401) {
        throw ApiException(response.statusCode!, "Not authorized to update order status",
          serverMessage: response.data['message'] ?? 'Insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException(404, "Order not found",
          serverMessage: response.data['message'] ?? 'Order does not exist');
      } else if (response.statusCode == 422) {
        throw ApiException(422, "Invalid status transition",
          serverMessage: response.data['message'] ?? 'Cannot change to this status');
      } else {
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Failed to update order status',
          serverMessage: '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // --- USER METHODS ---
  Future<User?> getUserById(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        return User.fromJson(userData);
      } else if (response.statusCode == 401) {
        throw ApiException(response.statusCode!, "Not authorized to view user",
          serverMessage: response.data['message'] ?? 'Insufficient permissions');
      } else {
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Failed to fetch user',
          serverMessage: '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<User?> getCurrentUser() async {
    await ensureInitialized();
    try {
      final response = await _dio.get('/auth/me');

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        return User.fromJson(userData);
      } else {
        clearToken(); // Clear invalid token
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Failed to fetch current user',
          serverMessage: '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // --- REVIEW METHODS ---
  Future<List<Review>> getProductReviews(String productId) async {
    try {
      final response = await _dio.get('/products/$productId/reviews');

      if (response.statusCode == 200) {
        final List<dynamic> reviewsData = response.data['reviews'];
        return reviewsData.map((json) => Review.fromJson(json)).toList();
      } else if (response.statusCode == 400) {
        throw ApiException(400, "Invalid query parameters",
          serverMessage: response.data['message'] ?? 'Invalid input');
      } else {
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Failed to fetch reviews',
          serverMessage: '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Review> submitReview(String productId, String title, String reviewText, int rating) async {
    try {
      final response = await _dio.post('/products/$productId/reviews', data: {
        'title': title,
        'reviewText': reviewText,
        'rating': rating,
      });

      if (response.statusCode == 201) {
        final reviewData = response.data['review'];
        return Review.fromJson(reviewData);
      } else if (response.statusCode == 400) {
        throw ApiException(400, "Invalid review data",
          serverMessage: response.data['message'] ?? 'Invalid input');
      } else if (response.statusCode == 401) {
        throw ApiException(401, "Not authorized to submit review",
          serverMessage: response.data['message'] ?? 'Authentication required');
      } else if (response.statusCode == 422) {
        throw ApiException(422, "Review validation failed",
          serverMessage: response.data['message'] ?? 'Validation error');
      } else {
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Failed to submit review',
          serverMessage: '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // --- USER PROFILE METHODS ---
  Future<User> updateUser(String userId, {String? name, String? phoneNumber}) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;

      final response = await _dio.patch('/users/$userId', data: updateData);

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        return User.fromJson(userData);
      } else if (response.statusCode == 400) {
        throw ApiException(400, "Invalid user data",
          serverMessage: response.data['message'] ?? 'Invalid input');
      } else if (response.statusCode == 401) {
        throw ApiException(response.statusCode!, "Not authorized to update user",
          serverMessage: response.data['message'] ?? 'Insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException(404, "User not found",
          serverMessage: response.data['message'] ?? 'User does not exist');
      } else if (response.statusCode == 422) {
        throw ApiException(422, "User validation failed",
          serverMessage: response.data['message'] ?? 'Validation error');
      } else {
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Failed to update user',
          serverMessage: '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}