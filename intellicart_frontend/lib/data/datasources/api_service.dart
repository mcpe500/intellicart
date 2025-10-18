// lib/data/datasources/api_service.dart
import 'package:intellicart/data/datasources/mock_backend.dart';
import 'package:intellicart/models/product.dart';

class ApiService {
  final MockBackend _mockBackend = MockBackend();

  // In a real app, this would make an HTTP request.
  // Here, it just calls the mock backend.
  Future<List<Product>> getProducts() async {
    return await _mockBackend.fetchProducts();
  }
}