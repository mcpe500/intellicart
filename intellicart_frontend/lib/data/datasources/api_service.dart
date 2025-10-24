// lib/data/datasources/api_service.dart
import 'dart:developer';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intellicart_frontend/data/exceptions/api_exception.dart';
import 'package:intellicart_frontend/models/product.dart';
import 'package:intellicart_frontend/models/user.dart';
import 'package:intellicart_frontend/models/order.dart';
import 'package:intellicart_frontend/models/review.dart';
import 'package:intellicart_frontend/utils/service_locator.dart';
import 'package:intellicart_frontend/data/repositories/auth_repository.dart';

class ApiService {
  late Dio _dio;
  String? _token;
  late String _baseUrl;
  Completer<void>? _initializationCompleter;

  String? get token => _token;

  Future<void> ensureInitialized() async {
    if (_initializationCompleter == null) {
      _initializeDio();
    }
    await _initializationCompleter!.future;
  }

  ApiService() {
    _initializeDio();
  }

  Future<void> _initializeDio() async {
    _initializationCompleter ??= Completer<void>();
    
    try {
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

      // Load the token from storage during initialization
      final authRepo = serviceLocator.authRepository;
      final token = await authRepo.getAuthToken();
      if (token != null) {
        _token = token;
      }

      // Request interceptor to add authorization header
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            print('DEBUG: Request interceptor called for ${options.path}');
            // Ensure initialization is complete before making request
            await ensureInitialized();
            
            // First, if we have a token in memory (_token), use it
            // Otherwise, try to get from storage
            if (_token == null) {
              final authRepo = serviceLocator.authRepository;
              final storedToken = await authRepo.getAuthToken();
              print('DEBUG: Checking storage for token - found: ${storedToken != null ? "yes" : "no"}');
              if (storedToken != null) {
                _token = storedToken;
                print('DEBUG: Token loaded from storage');
              } else {
                print('DEBUG: No token found in storage either');
              }
            } else {
              print('DEBUG: Using token already in memory');
            }
            
            // Add Authorization header if token exists
            if (_token != null) {
              options.headers['Authorization'] = 'Bearer $_token';
              print('DEBUG: Authorization header set with token');
            } else {
              print('DEBUG: No token available to set in authorization header');
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
            // Log the full error for debugging
            print('API Error: ${error.requestOptions.path}');
            print('Error Type: ${error.type}');
            print('Status Code: ${error.response?.statusCode}');
            print('Error Message: ${error.message}');
            if (error.response != null) {
              print('Response Data: ${error.response?.data}');
            }
            
            if (error.response?.statusCode == 401) {
              // Token expired or invalid, clear it
              clearToken(); // This will be called in the background
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
              print('Connection Timeout Error: ${error.requestOptions.path} - ${error.message}');
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
      
      // Safely complete the initialization, ignore if already completed
      if (!_initializationCompleter!.isCompleted) {
        _initializationCompleter!.complete();
      }
    } catch (e) {
      // In case of error, still complete the initialization to avoid hanging
      if (!_initializationCompleter!.isCompleted) {
        _initializationCompleter!.completeError(e);
      }
      rethrow;
    }
  }

  Future<void> setToken(String token) async {
    _token = token;
    // Also save the token to storage
    final authRepo = serviceLocator.authRepository;
    await authRepo.setAuthToken(token);
  }

  Future<void> clearToken() async {
    _token = null;
    // Also clear the token from storage
    final authRepo = serviceLocator.authRepository;
    await authRepo.removeAuthToken();
  }

  // --- AUTHENTICATION METHODS ---
  Future<User?> login(String email, String password) async {
    await ensureInitialized();
    try {
      print('API: Attempting login for user: $email');
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        await setToken(response.data['token']);
        print('API: Login successful for user: $email');
        return User.fromJson(userData);
      } else if (response.statusCode == 400) {
        print('API: Login failed - Invalid credentials format for user: $email, Status: ${response.statusCode}');
        throw ApiException(400, "Invalid email or password format",
          serverMessage: response.data['message'] ?? 'Invalid input');
      } else if (response.statusCode == 401) {
        print('API: Login failed - Invalid credentials for user: $email, Status: ${response.statusCode}');
        throw ApiException(401, "Invalid credentials",
          serverMessage: response.data['message'] ?? 'Incorrect email or password');
      } else if (response.statusCode == 429) {
        print('API: Login failed - Rate limited for user: $email, Status: ${response.statusCode}');
        throw ApiException(429, "Too many login attempts. Please try again later",
          serverMessage: response.data['message'] ?? 'Rate limited');
      } else {
        print('API: Login failed - Unexpected status for user: $email, Status: ${response.statusCode}');
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Login failed',
          serverMessage: '');
      }
    } on DioException catch (e) {
      print('API: Network error during login for user: $email - ${e.message}');
      throw ApiException.fromDioException(e);
    } catch (e) {
      print('API: Unexpected error during login for user: $email - $e');
      rethrow;
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
      print('API: Fetching products with params - page: $page, limit: $limit, search: $search, category: $category');
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (search != null) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;

      final response = await _dio.get('/products', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> productsData = response.data['products'];
        print('API: Successfully fetched ${productsData.length} products');
        return productsData.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 400) {
        print('API: Get products failed - Invalid query parameters, Status: ${response.statusCode}');
        throw ApiException(400, "Invalid query parameters",
          serverMessage: response.data['message'] ?? 'Invalid input');
      } else {
        print('API: Get products failed - Unexpected status: ${response.statusCode}');
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Failed to fetch products',
          serverMessage: '');
      }
    } on DioException catch (e) {
      print('API: Network error during product fetch - ${e.message}');
      throw ApiException.fromDioException(e);
    } catch (e) {
      print('API: Unexpected error during product fetch - $e');
      rethrow;
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
      log('Get User Response: ${response.data}');
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
      print('API: Fetching current user profile');
      final response = await _dio.get('/auth/me');

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        if (userData != null) {
          print('API: Successfully fetched current user: ${userData['name'] ?? 'Unknown User'}');
          return User.fromJson(userData);
        } else {
          print('API: User data is null in response');
          return null;
        }
      } else {
        print('API: Fetch current user failed - Status: ${response.statusCode}');
        clearToken(); // Clear invalid token (async call)
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Failed to fetch current user',
          serverMessage: '');
      }
    } on DioException catch (e) {
      print('API: Network error during current user fetch - ${e.message}');
      throw ApiException.fromDioException(e);
    } catch (e) {
      print('API: Unexpected error during current user fetch - $e');
      rethrow;
    }
  }

  // --- REVIEW METHODS ---
  Future<List<Review>> getProductReviews(String productId) async {
    try {
      print('API: Fetching reviews for product: $productId');
      final response = await _dio.get('/reviews/product/$productId');

      if (response.statusCode == 200) {
        final responseData = response.data;
        final List<dynamic> reviewsData = responseData['data'] is List ? responseData['data'] : [];
        print('API: Successfully fetched ${reviewsData.length} reviews for product: $productId');
        return reviewsData.map((json) => Review.fromJson(json)).toList();
      } else if (response.statusCode == 400) {
        print('API: Get product reviews failed - Invalid query parameters, Status: ${response.statusCode}');
        throw ApiException(400, "Invalid query parameters",
          serverMessage: response.data['message'] ?? 'Invalid input');
      } else if (response.statusCode == 404) {
        print('API: Get product reviews returned 404 - Product not found or no reviews found for product: $productId');
        return []; // Return empty list instead of throwing for 404 if no reviews exist
      } else {
        print('API: Get product reviews failed - Unexpected status: ${response.statusCode}');
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Failed to fetch reviews',
          serverMessage: '');
      }
    } on DioException catch (e) {
      print('API: Network error during product reviews fetch for product: $productId - ${e.message}');
      throw ApiException.fromDioException(e);
    } catch (e) {
      print('API: Unexpected error during product reviews fetch for product: $productId - $e');
      rethrow;
    }
  }

  Future<Review> submitReview(String productId, String title, String reviewText, int rating) async {
    try {
      print('API: Submitting review for product: $productId');
      final response = await _dio.post('/reviews', data: {
        'productId': productId,  // Send productId in the request body as per API contract
        'comment': reviewText,   // Send comment as per API contract
        'rating': rating,        // Send rating as per API contract
        // Note: userId will be determined server-side from the authentication token
      });

      if (response.statusCode == 201) {
        final responseData = response.data;
        final reviewData = responseData['data'];
        print('API: Successfully submitted review for product: $productId');
        return Review.fromJson(reviewData);
      } else if (response.statusCode == 400) {
        print('API: Submit review failed - Invalid review data for product: $productId, Status: ${response.statusCode}');
        throw ApiException(400, "Invalid review data",
          serverMessage: response.data['message'] ?? 'Invalid input');
      } else if (response.statusCode == 401) {
        print('API: Submit review failed - Not authorized for product: $productId, Status: ${response.statusCode}');
        throw ApiException(401, "Not authorized to submit review",
          serverMessage: response.data['message'] ?? 'Authentication required');
      } else if (response.statusCode == 422) {
        print('API: Submit review failed - Validation error for product: $productId, Status: ${response.statusCode}');
        throw ApiException(422, "Review validation failed",
          serverMessage: response.data['message'] ?? 'Validation error');
      } else {
        print('API: Submit review failed - Unexpected status: ${response.statusCode} for product: $productId');
        throw ApiException(response.statusCode ?? 0,
          response.data['message'] ?? 'Failed to submit review',
          serverMessage: '');
      }
    } on DioException catch (e) {
      print('API: Network error during review submission for product: $productId - ${e.message}');
      throw ApiException.fromDioException(e);
    } catch (e) {
      print('API: Unexpected error during review submission for product: $productId - $e');
      rethrow;
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