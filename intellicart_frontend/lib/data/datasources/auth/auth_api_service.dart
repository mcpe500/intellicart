// lib/data/datasources/auth/auth_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intellicart/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApiService {
  static const String _baseUrl = 'http://localhost:3000/api/auth'; // Update with your actual backend URL

  // Store the authentication token
  static String? _token;

  Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final User user = User.fromJson(data['user']);
        
        // Store the token for future requests
        _token = data['token'];
        await _saveToken(_token!);
        
        return user;
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  Future<User> register(String email, String password, String name, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'name': name,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final User user = User.fromJson(data['user']);
        
        // Store the token for future requests
        _token = data['token'];
        await _saveToken(_token!);
        
        return user;
      } else {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  Future<bool> logout() async {
    try {
      if (_token != null) {
        final response = await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $_token',
          },
        );
        
        if (response.statusCode == 200) {
          _token = null;
          await _clearToken();
          return true;
        }
      }
      return true; // Return true even if no token was present
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }

  Future<bool> verifyToken() async {
    try {
      if (_token == null) {
        _token = await _getToken();
      }
      
      if (_token != null) {
        final response = await http.post(
          Uri.parse('$_baseUrl/verify'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $_token',
          },
        );
        
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return data['valid'] ?? false;
        }
      }
      return false;
    } catch (e) {
      return false; // Token is invalid if there's an error
    }
  }

  // Method to get the current token
  static Future<String?> getToken() async {
    if (_token == null) {
      _token = await _getToken();
    }
    return _token;
  }

  // Private methods for token storage
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}