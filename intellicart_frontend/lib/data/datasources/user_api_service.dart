// lib/data/datasources/user/user_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intellicart/models/user.dart';
import 'package:intellicart/data/datasources/auth/auth_api_service.dart';

class UserApiService {
  static const String _baseUrl = 'http://localhost:3000/api'; // Update with your actual backend URL

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

  Future<User?> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // User not found
      } else {
        throw Exception('Failed to load user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading user: $e');
    }
  }
}