// lib/data/datasources/api_service.dart
import 'package:intellicart/data/datasources/mock_backend.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/models/user.dart';
import 'package:intellicart/models/order.dart';

class ApiService {
  final MockBackend _mockBackend = MockBackend();

  // --- AUTHENTICATION METHODS ---
  Future<User?> login(String email, String password) async {
    // In a real app, this would make an HTTP request to a backend API
    // Here, it just calls the mock backend
    return await _mockBackend.login(email, password);
  }

  Future<User> register(String email, String password, String name, String role) async {
    // In a real app, this would make an HTTP request to a backend API
    // Here, it just calls the mock backend
    return await _mockBackend.register(email, password, name, role);
  }

  // --- PRODUCT METHODS ---
  Future<List<Product>> getProducts() async {
    // In a real app, this would make an HTTP request to a backend API
    // Here, it just calls the mock backend
    return await _mockBackend.fetchProducts();
  }

  Future<Product> addProduct(Product product) async {
    // In a real app, this would make an HTTP request to a backend API
    // Here, it just calls the mock backend
    return await _mockBackend.addProduct(product);
  }

  Future<Product> updateProduct(Product product) async {
    // In a real app, this would make an HTTP request to a backend API
    // Here, it just calls the mock backend
    return await _mockBackend.updateProduct(product);
  }

  Future<void> deleteProduct(Product product) async {
    // In a real app, this would make an HTTP request to a backend API
    // Here, it just calls the mock backend
    return await _mockBackend.deleteProduct(product);
  }

  Future<List<Product>> getSellerProducts(String sellerId) async {
    // In a real app, this would make an HTTP request to a backend API
    // Here, it just calls the mock backend
    return await _mockBackend.fetchSellerProducts(sellerId);
  }

  // --- ORDER METHODS ---
  Future<List<Order>> getSellerOrders() async {
    // In a real app, this would make an HTTP request to a backend API
    // Here, it just calls the mock backend
    return await _mockBackend.fetchSellerOrders();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    // In a real app, this would make an HTTP request to a backend API
    // Here, it just calls the mock backend
    return await _mockBackend.updateOrderStatus(orderId, status);
  }

  Future<User?> getUserById(String userId) async {
    // In a real app, this would make an HTTP request to a backend API
    // Here, it just calls the mock backend
    return await _mockBackend.getUserById(userId);
  }
}