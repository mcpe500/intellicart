import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intellicart/models/product.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000';
  
  // Get all products
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/products'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
  
  // Create a new product
  Future<Product> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );
      
      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return Product.fromJson(jsonData);
      } else {
        throw Exception('Failed to create product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
  
  // Health check
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}