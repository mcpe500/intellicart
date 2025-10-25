// lib/data/datasources/order/order_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intellicart/models/order.dart';
import 'package:intellicart/data/datasources/auth/auth_api_service.dart';

class OrderApiService {
  static const String _baseUrl = 'http://localhost:3000/api/orders'; // Update with your actual backend URL

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

  Future<List<Order>> getSellerOrders() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),  // Changed from '$_baseUrl/orders' to just _baseUrl
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading orders: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$orderId/status'),  // Changed from '$_baseUrl/orders/$orderId/status' to '$_baseUrl/$orderId/status'
        headers: await _getHeaders(),
        body: jsonEncode(<String, String>{
          'status': status,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update order status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating order status: $e');
    }
  }

  Future<void> createOrder(Order order) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: await _getHeaders(),
        body: jsonEncode(order.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }
}