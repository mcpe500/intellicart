// lib/data/datasources/auth/auth_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intellicart/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/services/logging_service.dart';

class AuthApiService {
  static String? _baseUrl;

  static Future<String> getBaseUrl() async {
    if (_baseUrl == null) {
      await dotenv.load(fileName: ".env");
      final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
      _baseUrl = '$apiBaseUrl/api/auth';
    }
    return _baseUrl!;
  }

  // Store the authentication token
  static String? _token;

  Future<User?> login(String email, String password) async {
    try {
      loggingService.logInfo('AuthApiService.login called with email: $email');
      final baseUrl = await getBaseUrl();
      loggingService.logInfo('Login API Base URL: $baseUrl');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );
      
      loggingService.logInfo('Login response status: ${response.statusCode}');
      loggingService.logInfo('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final User user = User.fromJson(data['user']);
        
        // Store the token for future requests
        _token = data['token'];
        await _saveToken(_token!);
        
        loggingService.logInfo('Login successful, user: ${user.name}, token stored');
        return user;
      } else {
        loggingService.logError('Login failed with status: ${response.statusCode}, body: ${response.body}');
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      loggingService.logError('Error during login: $e');
      throw Exception('Error during login: $e');
    }
  }

  Future<User> register(String email, String password, String name, String role) async {
    try {
      loggingService.logInfo('AuthApiService.register called with email: $email, name: $name, role: $role');
      final baseUrl = await getBaseUrl();
      loggingService.logInfo('Register API Base URL: $baseUrl');
      
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
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
      
      loggingService.logInfo('Register response status: ${response.statusCode}');
      loggingService.logInfo('Register response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final User user = User.fromJson(data['user']);
        
        // Store the token for future requests
        _token = data['token'];
        await _saveToken(_token!);
        
        loggingService.logInfo('Registration successful, user: ${user.name}, token stored');
        return user;
      } else {
        loggingService.logError('Registration failed with status: ${response.statusCode}, body: ${response.body}');
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      loggingService.logError('Error during registration: $e');
      throw Exception('Error during registration: $e');
    }
  }

  Future<bool> logout() async {
    try {
      if (_token != null) {
        final baseUrl = await getBaseUrl();
        final response = await http.post(
          Uri.parse('$baseUrl/logout'),
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
      _token ??= await _getToken();
      
      if (_token != null) {
        final baseUrl = await getBaseUrl();
        final response = await http.post(
          Uri.parse('$baseUrl/verify'),
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
    _token ??= await _getToken();
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
  
  // Get current user using the stored token
  Future<User?> getCurrentUser() async {
    try {
      final token = await AuthApiService.getToken();
      if (token == null) {
        return null;
      }
      
      // We would call an endpoint like /api/auth/me to get user info
      // For now, I'll add a method to the routes and controller
      final response = await http.get(
        Uri.parse('${await getBaseUrl()}/me'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      loggingService.logError('Error getting current user: $e');
      return null;
    }
  }
}