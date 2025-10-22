// lib/data/repositories/auth_repository.dart
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthRepository {
  Future<bool> isAuthenticated();
  Future<void> saveAuthentication(String token, String userId);
  Future<void> clearAuthentication();
  Future<String?> getAuthToken();
  Future<String?> getUserId();
}

class AuthRepositoryImpl implements AuthRepository {
  static const String _isAuthenticatedKey = 'is_authenticated';
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  @override
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAuthenticatedKey) ?? false;
  }

  @override
  Future<void> saveAuthentication(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAuthenticatedKey, true);
    await prefs.setString(_authTokenKey, token);
    await prefs.setString(_userIdKey, userId);
  }

  @override
  Future<void> clearAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isAuthenticatedKey);
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userIdKey);
  }

  @override
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  @override
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
}