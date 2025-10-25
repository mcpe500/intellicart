// lib/data/datasources/api_service.dart
import 'package:intellicart/data/datasources/auth/auth_api_service.dart';
import 'package:intellicart/data/datasources/product/product_api_service.dart';
import 'package:intellicart/data/datasources/order/order_api_service.dart';
import 'package:intellicart/data/datasources/user_api_service.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/models/user.dart';
import 'package:intellicart/models/order.dart';

class ApiService {
  final AuthApiService _authService = AuthApiService();
  final ProductApiService _productService = ProductApiService();
  final OrderApiService _orderService = OrderApiService();
  final UserApiService _userService = UserApiService();

  // --- AUTHENTICATION METHODS ---
  Future<User?> login(String email, String password) async {
    return await _authService.login(email, password);
  }

  Future<User> register(String email, String password, String name, String role) async {
    return await _authService.register(email, password, name, role);
  }

  // --- PRODUCT METHODS ---
  Future<List<Product>> getProducts() async {
    return await _productService.getProducts();
  }

  Future<Product> addProduct(Product product) async {
    return await _productService.addProduct(product);
  }

  Future<Product> updateProduct(Product product) async {
    return await _productService.updateProduct(product);
  }

  Future<void> deleteProduct(Product product) async {
    return await _productService.deleteProduct(product.id ?? '');
  }

  Future<List<Product>> getSellerProducts(String sellerId) async {
    return await _productService.getSellerProducts(sellerId);
  }

  // --- ORDER METHODS ---
  Future<List<Order>> getSellerOrders() async {
    return await _orderService.getSellerOrders();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    return await _orderService.updateOrderStatus(orderId, status);
  }

  // --- USER METHODS ---
  Future<User?> getUserById(String userId) async {
    return await _userService.getUserById(userId);
  }
}